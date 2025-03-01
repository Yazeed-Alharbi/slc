// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/models/Material.dart';
import '../firebaseUtil/firestore.dart';
import '../models/Course.dart';
import '../models/course_enrollment.dart';

class CourseRepository {
  final FirestoreUtils _firestoreUtils;
  final FirebaseAuth _auth;

  CourseRepository({
    required FirestoreUtils firestoreUtils,
    FirebaseAuth? auth,
  })  : _firestoreUtils = firestoreUtils,
        _auth = auth ?? FirebaseAuth.instance;

  // Create a new course with all required fields
  // Add debugging to createCourse method

  Future<Course> createCourse({
    required String code,
    required String name,
    required String description,
    required CourseColor color,
    List<String>? days,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? location,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');

    print("Creating course: $name, $code for user: ${user.uid}");

    final courseId = _firestoreUtils.courses.doc().id;
    print("Generated course ID: $courseId");

    CourseSchedule? schedule;
    if (days != null && startTime != null && endTime != null) {
      schedule = CourseSchedule(
        days: days,
        startTime: startTime,
        endTime: endTime,
        location: location ?? "",
      );
      print(
          "Schedule created: ${days.join(", ")} at ${startTime.hour}:${startTime.minute}");
    }

    final course = Course(
      id: courseId,
      code: code,
      name: name,
      description: description,
      createdBy: user.uid,
      color: color,
      schedule: schedule,
    );

    try {
      print("Writing to Firestore: courses/$courseId");
      await _firestoreUtils.setDocument(
        path: 'courses/$courseId',
        data: course.toJson(),
      );

      print("Enrolling creator in course");
      // Automatically enroll the creator
      await enrollStudent(
        courseId: courseId,
        studentId: user.uid,
      );

      print("Course creation successful");
      return course;
    } catch (e) {
      print("Error in createCourse: $e");
      throw Exception('Failed to create course: $e');
    }
  }

  // Get a specific course
  Future<Course?> getCourse(String courseId) async {
    final doc = await _firestoreUtils.getDocument(path: 'courses/$courseId');
    if (!doc.exists) return null;

    return Course.fromJson({
      ...doc.data() as Map<String, dynamic>,
      'id': courseId,
    });
  }

  /// Returns a stream that emits the course data whenever it changes in Firestore
  Stream<Course?> streamCourse(String courseId) {
    print("Starting stream for course: $courseId");

    return _firestoreUtils.courses.doc(courseId).snapshots().map((doc) {
      if (!doc.exists) {
        print("Document doesn't exist for course: $courseId");
        return null;
      }

      try {
        final course = Course.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id': courseId,
        });
        print("Course streamed: ${course.name} (${course.code})");
        return course;
      } catch (e) {
        print("Error parsing course data: $e");
        throw e; // This will be caught by the StreamBuilder's error handler
      }
    });
  }

  // Enroll a student in a course with progress tracking
  Future<CourseEnrollment> enrollStudent({
    required String courseId,
    required String studentId,
  }) async {
    // Check if course exists
    final course = await getCourse(courseId);
    if (course == null) throw Exception('Course not found');

    // Add student to course's enrolled students
    await _firestoreUtils.updateDocument(
      path: 'courses/$courseId',
      data: {
        'enrolled_student_ids': FieldValue.arrayUnion([studentId]),
      },
    );

    // Create enrollment document for tracking progress
    final enrollmentId = _firestoreUtils.courseEnrollments.doc().id;
    final enrollment = CourseEnrollment(
      id: enrollmentId,
      courseId: courseId,
      studentId: studentId,
    );

    await _firestoreUtils.setDocument(
      path: 'course_enrollments/$enrollmentId',
      data: enrollment.toJson(),
    );

    return enrollment;
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      print("Deleting course with ID: $courseId");

      // First, get all enrollments for this course
      final enrollmentsSnapshot = await _firestoreUtils.courseEnrollments
          .where('course_id', isEqualTo: courseId)
          .get();

      print("Found ${enrollmentsSnapshot.docs.length} enrollments to delete");

      // Delete all enrollments in a batch operation
      final batch = FirebaseFirestore.instance.batch();

      for (var doc in enrollmentsSnapshot.docs) {
        batch.delete(doc.reference);
        print("Marked enrollment ${doc.id} for deletion");
      }

      // Delete the course document
      batch.delete(_firestoreUtils.courses.doc(courseId));
      print("Marked course $courseId for deletion");

      // Commit the batch operation
      await batch.commit();
      print("Successfully deleted course and all enrollments");

      return;
    } catch (e) {
      print("Error deleting course: $e");
      throw Exception('Failed to delete course: $e');
    }
  }

  // Unenroll a student from a course
  Future<void> unenrollStudent({
    required String courseId,
    required String studentId,
  }) async {
    // Remove student from course
    await _firestoreUtils.updateDocument(
      path: 'courses/$courseId',
      data: {
        'enrolled_student_ids': FieldValue.arrayRemove([studentId]),
      },
    );

    // Find and delete enrollment document
    final enrollmentsSnapshot = await _firestoreUtils.courseEnrollments
        .where('course_id', isEqualTo: courseId)
        .where('student_id', isEqualTo: studentId)
        .get();

    for (var doc in enrollmentsSnapshot.docs) {
      await _firestoreUtils.deleteDocument(
        path: 'course_enrollments/${doc.id}',
      );
    }
  }

  // Get all courses for a student with their progress
  // Update the streamStudentCourses method

  Stream<List<CourseWithProgress>> streamStudentCourses(String studentId) {
    print("Starting streamStudentCourses for student: $studentId");

    return _firestoreUtils.courseEnrollments
        .where('student_id', isEqualTo: studentId)
        .snapshots()
        .asyncMap((enrollmentsSnapshot) async {
      print(
          "Got enrollments snapshot with ${enrollmentsSnapshot.docs.length} documents");

      final result = <CourseWithProgress>[];

      // Process each enrollment document
      for (var enrollmentDoc in enrollmentsSnapshot.docs) {
        final enrollment = CourseEnrollment.fromJson({
          ...enrollmentDoc.data() as Map<String, dynamic>,
          'id': enrollmentDoc.id,
        });

        // Get the LATEST course data for each enrollment
        final courseDoc = await _firestoreUtils.getDocument(
          path: 'courses/${enrollment.courseId}',
        );

        if (courseDoc.exists) {
          final course = Course.fromJson({
            ...courseDoc.data() as Map<String, dynamic>,
            'id': enrollment.courseId,
          });

          result.add(CourseWithProgress(
            course: course,
            enrollment: enrollment,
          ));
        }
      }

      return result;
    });
  }

  // Add CourseMaterial to a course
  Future<void> addMaterial({
    required String courseId,
    required CourseMaterial CourseMaterial,
  }) async {
    await _firestoreUtils.updateDocument(
      path: 'courses/$courseId',
      data: {
        'materials': FieldValue.arrayUnion([CourseMaterial.toJson()]),
      },
    );
  }

  // Remove CourseMaterial from a course
  Future<void> removeMaterial({
    required String courseId,
    required String materialId,
  }) async {
    final course = await getCourse(courseId);
    if (course == null) throw Exception('Course not found');

    final updatedMaterials = course.materials
        .where((CourseMaterial) => CourseMaterial.id != materialId)
        .map((m) => m.toJson())
        .toList();

    await _firestoreUtils.updateDocument(
      path: 'courses/$courseId',
      data: {
        'materials': updatedMaterials,
      },
    );
  }

  Future<void> updateCourse({
    required String courseId,
    String? code,
    String? name,
    String? description,
    CourseColor? color,
  }) async {
    final updates = <String, dynamic>{};

    // Add fields to updates only if they are provided
    if (code != null) updates['code'] = code;
    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (color != null) {
      // Store color as string representation to match how Course.fromJson expects it
      updates['color'] = color.toString().split('.').last;
    }

    if (updates.isEmpty) {
      print("No updates provided for course: $courseId");
      return;
    }

    try {
      print("Updating course: $courseId with data: $updates");
      await _firestoreUtils.updateDocument(
        path: 'courses/$courseId',
        data: updates,
      );
      print("Course update successful");
    } catch (e) {
      print("Error updating course: $e");
      throw Exception('Failed to update course: $e');
    }
  }

  Future<void> updateCourseSchedule({
    required String courseId,
    List<String>? days,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? location,
  }) async {
    // Validate required fields for schedule
    if (days == null || startTime == null || endTime == null) {
      print(
          "Missing required fields for updating schedule of course: $courseId");
      throw Exception("Missing required fields for schedule update");
    }

    final schedule = CourseSchedule(
      days: days,
      startTime: startTime,
      endTime: endTime,
      location: location ?? "",
    );

    try {
      print("Updating schedule for course: $courseId");
      await _firestoreUtils.updateDocument(
        path: 'courses/$courseId',
        data: {
          'schedule': schedule.toJson(),
        },
      );
      print("Schedule update successful");
    } catch (e) {
      print("Error updating course schedule: $e");
      throw Exception('Failed to update course schedule: $e');
    }
  }

  // Track student progress for a course
  Future<void> markMaterialAsCompleted({
    required String enrollmentId,
    required String materialId,
  }) async {
    await _firestoreUtils.updateDocument(
      path: 'course_enrollments/$enrollmentId',
      data: {
        'completed_material_ids': FieldValue.arrayUnion([materialId]),
      },
    );
  }

  // Add a focus session to an enrollment
  Future<void> addFocusSession({
    required String enrollmentId,
    required String focusSessionId,
  }) async {
    await _firestoreUtils.updateDocument(
      path: 'course_enrollments/$enrollmentId',
      data: {
        'focus_session_ids': FieldValue.arrayUnion([focusSessionId]),
      },
    );
  }
}

// Helper class to combine course and enrollment data
class CourseWithProgress {
  final Course course;
  final CourseEnrollment enrollment;

  CourseWithProgress({
    required this.course,
    required this.enrollment,
  });

  int get completedMaterialsCount => enrollment.completedMaterialIds.length;

  int get totalMaterialsCount => course.materials.length;

  double get progressPercentage => totalMaterialsCount > 0
      ? (completedMaterialsCount / totalMaterialsCount) * 100
      : 0;
}
