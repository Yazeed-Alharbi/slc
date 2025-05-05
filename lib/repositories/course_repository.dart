// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'dart:math'; // Add for Random

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/models/Material.dart'; // Updated case to match the actual file
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

  // Helper method to generate random share code
  String _generateShareCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random.secure();
    return List.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  String _getCurrentUserId() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');
    return user.uid;
  }

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
    final shareCode = _generateShareCode(); // Generate code
    print("Generated course ID: $courseId and share code: $shareCode");

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
      shareCode: shareCode, // Add share code
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

      // First, get the course to access its materials
      final course = await getCourse(courseId);
      if (course == null) {
        throw Exception('Course not found');
      }

      // Delete all materials from Firebase Storage
      print("Deleting ${course.materials.length} materials from Storage");
      for (var material in course.materials) {
        try {
          // Method 1: Delete using the download URL
          await _firestoreUtils.deleteFileFromStorage(material.downloadUrl);
          print("Deleted file: ${material.name}");
        } catch (e) {
          print("Error deleting file ${material.name}: $e");
          // Continue with deletion of other files
        }
      }

      // Delete the entire course folder from Storage
      try {
        final storageRef =
            FirebaseStorage.instance.ref().child('courses/$courseId');
        // List all files in the directory and delete them
        final result = await storageRef.listAll();
        for (var item in result.items) {
          await item.delete();
          print("Deleted storage item: ${item.name}");
        }
        print("All course files deleted from storage");
      } catch (e) {
        print("Error cleaning up storage: $e");
        // Continue with Firestore deletion
      }

      // Get all enrollments for this course
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
      print("Successfully deleted course, all enrollments, and all files");

      return;
    } catch (e) {
      print("Error deleting course: $e");
      throw Exception('Failed to delete course: $e');
    }
  }

  Future<String> uploadFileToStorage({
    required File file,
    required String courseId,
    Function(double)? onProgress,
  }) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('courses/$courseId/${file.path.split('/').last}');

      // Create upload task
      final uploadTask = storageRef.putFile(file);

      // Listen to upload progress if callback provided
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for upload to complete
      await uploadTask;

      // Return download URL
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
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

  Future<void> removeMaterial({
    required String courseId,
    required String materialId,
  }) async {
    // Get the current course document
    final course = await getCourse(courseId);
    if (course == null) throw Exception('Course not found');

    // Find the material object to delete using its ID
    late CourseMaterial materialToDelete;
    bool materialFound = false;
    for (var material in course.materials) {
      if (material.id == materialId) {
        materialToDelete = material;
        materialFound = true;
        break;
      }
    }

    if (!materialFound) {
      throw Exception('Material not found');
    }

    // Delete the file from Firebase Storage using its download URL
    await _firestoreUtils.deleteFileFromStorage(materialToDelete.downloadUrl);

    // Update Firestore: Remove the file metadata from the course document
    final updatedMaterials = course.materials
        .where((m) => m.id != materialId)
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

  // Add method to regenerate share code
  Future<String> regenerateShareCode(String courseId) async {
    final newCode = _generateShareCode();
    await _firestoreUtils.updateDocument(
      path: 'courses/$courseId',
      data: {'share_code': newCode},
    );
    return newCode;
  }

  // Find course by share code
  Future<String?> findCourseByShareCode(String shareCode) async {
    final querySnapshot = await _firestoreUtils.courses
        .where('share_code', isEqualTo: shareCode)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    return querySnapshot.docs.first.id;
  }

  // Clone a course by ID
  Future<void> cloneCourse(String courseId) async {
    try {
      // 1. Get the original course
      final originalCourse = await _firestoreUtils
          .getDocument(path: 'courses/$courseId')
          .then((snapshot) => Course.fromJson({
                ...snapshot.data() as Map<String, dynamic>,
                'id': courseId,
              }));

      // 2. Create a new course with similar properties but unique ID
      final newCourseId = _firestoreUtils.generateId();
      final newCourse = Course(
        id: newCourseId,
        code: originalCourse.code,
        name: "${originalCourse.name}",
        description: originalCourse.description,
        color: originalCourse.color,
        createdBy: _auth.currentUser?.uid ?? '',
        originalCourseId: courseId,
        shareCode: _generateShareCode(),
        schedule: originalCourse
            .schedule, // IMPORTANT: Add this line to copy the schedule!
      );

      // 3. Save the new course
      await _firestoreUtils.setDocument(
        path: 'courses/$newCourseId',
        data: newCourse.toJson(),
      );

      // 4. Clone all materials from original course WITH DUPLICATED FILES
      if (originalCourse.materials.isNotEmpty) {
        print(
            "Cloning ${originalCourse.materials.length} materials with independent file copies");
        final List<Map<String, dynamic>> clonedMaterials = [];

        // CREATE A LIST TO TRACK ALL UPLOAD TASKS
        final List<Future<void>> uploadTasks = [];

        for (final material in originalCourse.materials) {
          try {
            print(
                "Processing material: ${material.name}, URL: ${material.downloadUrl}");

            if (material.downloadUrl.isEmpty) {
              // Handle empty URL case as before
              continue;
            }

            // Create a future for this file upload and ADD IT TO THE LIST
            final uploadFuture =
                _duplicateMaterial(material, newCourseId).then((newMaterial) {
              if (newMaterial != null) {
                clonedMaterials.add(newMaterial.toJson());
                print("Added material to cloned list: ${newMaterial.name}");
              }
            });

            // Add this future to our tracking list
            uploadTasks.add(uploadFuture);
          } catch (e) {
            print("Error preparing material ${material.name}: $e");
          }
        }

        // WAIT FOR ALL UPLOADS TO COMPLETE BEFORE CONTINUING
        print("Waiting for ${uploadTasks.length} file uploads to complete...");
        await Future.wait(uploadTasks);
        print("All ${uploadTasks.length} file uploads completed");

        // Update the course document with all cloned materials
        await _firestoreUtils.updateDocument(
          path: 'courses/$newCourseId',
          data: {'materials': clonedMaterials},
        );
      }

      // 5. Enroll the current user in the course
      await enrollStudent(
        courseId: newCourseId,
        studentId: _auth.currentUser?.uid ?? '',
      );

      print("Course successfully cloned with ID: $newCourseId");
    } catch (e) {
      print('Error cloning course: $e');
      rethrow;
    }
  }

  // Check if the user already has this course
  Future<bool> userHasCourse(String courseId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      // First check if the user is enrolled in this course
      final enrollmentDoc = await _firestoreUtils.getDocument(
        path: 'courses/$courseId/enrollments/$userId',
      );

      if (enrollmentDoc.exists) {
        return true;
      }

      // Then check if the user owns this course
      final courseDoc = await _firestoreUtils.getDocument(
        path: 'courses/$courseId',
      );

      if (courseDoc.exists) {
        final data = courseDoc.data() as Map<String, dynamic>;
        final createdBy = data['created_by'] as String?;
        if (createdBy == userId) {
          return true;
        }
      }

      // NEW CHECK: Finally, check if the user already has a course cloned from this one
      final userCoursesQuery = await _firestoreUtils.courses
          .where('created_by', isEqualTo: userId)
          .where('original_course_id', isEqualTo: courseId)
          .limit(1)
          .get();

      return userCoursesQuery.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if user has course: $e');
      return false;
    }
  }

  // Add this helper method to your CourseRepository class:

  Future<CourseMaterial?> _duplicateMaterial(
    CourseMaterial material,
    String newCourseId,
  ) async {
    try {
      // Get reference to original file
      final originalRef =
          FirebaseStorage.instance.refFromURL(material.downloadUrl);
      print("Got storage reference for: ${originalRef.fullPath}");

      // Download the file data
      print("Downloading file data for ${material.name}...");
      final fileData =
          await originalRef.getData(100 * 1024 * 1024); // Increase to 100MB
      if (fileData == null || fileData.isEmpty) {
        print("WARNING: Could not download file ${material.name} (empty data)");
        return null;
      }
      print(
          "Successfully downloaded ${fileData.length} bytes for ${material.name}");

      // Create new path in storage
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${material.name.replaceAll(' ', '_')}';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('courses/$newCourseId/$fileName');

      print(
          "Uploading ${material.name} to new location: ${storageRef.fullPath}");
      // Upload file data to the new location
      final uploadTask = storageRef.putData(
        fileData,
        SettableMetadata(contentType: material.type),
      );

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get new download URL
      final newDownloadUrl = await snapshot.ref.getDownloadURL();
      print("New download URL for ${material.name}: $newDownloadUrl");

      // Create material with the new download URL
      return CourseMaterial(
        id: _firestoreUtils.generateId(),
        name: material.name,
        downloadUrl: newDownloadUrl,
        type: material.type,
        fileSize: material.fileSize,
      );
    } catch (e) {
      print("ERROR duplicating material ${material.name}: $e");
      return null;
    }
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
