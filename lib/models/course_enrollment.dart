import 'package:cloud_firestore/cloud_firestore.dart';

class CourseEnrollment {
  final String id;
  final String courseId;
  final String studentId;
  final List<String> completedMaterialIds;
  final List<String> focusSessionIds;
  final int progress;
  final DateTime enrolledAt;

  CourseEnrollment({
    required this.id,
    required this.courseId,
    required this.studentId,
    List<String>? completedMaterialIds,
    List<String>? focusSessionIds,
    this.progress = 0,
    DateTime? enrolledAt,
  })  : completedMaterialIds = completedMaterialIds ?? [],
        focusSessionIds = focusSessionIds ?? [],
        enrolledAt = enrolledAt ?? DateTime.now();

  factory CourseEnrollment.fromJson(Map<String, dynamic> json) {
    return CourseEnrollment(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      studentId: json['student_id'] as String,
      completedMaterialIds:
          List<String>.from(json['completed_material_ids'] ?? []),
      focusSessionIds: List<String>.from(json['focus_session_ids'] ?? []),
      progress: json['progress'] as int? ?? 0,
      enrolledAt:
          (json['enrolled_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'student_id': studentId,
      'completed_material_ids': completedMaterialIds,
      'focus_session_ids': focusSessionIds,
      'progress': progress,
      'enrolled_at': Timestamp.fromDate(enrolledAt),
    };
  }

  CourseEnrollment copyWith({
    String? id,
    String? courseId,
    String? studentId,
    List<String>? completedMaterialIds,
    List<String>? focusSessionIds,
    int? progress,
    DateTime? enrolledAt,
  }) {
    return CourseEnrollment(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      studentId: studentId ?? this.studentId,
      completedMaterialIds: completedMaterialIds ?? this.completedMaterialIds,
      focusSessionIds: focusSessionIds ?? this.focusSessionIds,
      progress: progress ?? this.progress,
      enrolledAt: enrolledAt ?? this.enrolledAt,
    );
  }
}
