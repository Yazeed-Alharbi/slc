import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:slc/models/Material.dart';
import 'package:slc/common/styles/colors.dart';

class CourseSchedule {
  final List<String> days; // e.g., "MON", "WED"
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String location;

  CourseSchedule({
    required this.days,
    required this.startTime,
    required this.endTime,
    required this.location,
  });

  factory CourseSchedule.fromJson(Map<String, dynamic> json) {
    return CourseSchedule(
      days: List<String>.from(json['days']),
      startTime: TimeOfDay(
        hour: json['start_time']['hour'],
        minute: json['start_time']['minute'],
      ),
      endTime: TimeOfDay(
        hour: json['end_time']['hour'],
        minute: json['end_time']['minute'],
      ),
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'days': days,
      'start_time': {
        'hour': startTime.hour,
        'minute': startTime.minute,
      },
      'end_time': {
        'hour': endTime.hour,
        'minute': endTime.minute,
      },
      'location': location,
    };
  }
}

class Course {
  final String id;
  final String code; // e.g., "ICS-433"
  final String name; // e.g., "Operating Systems"
  final String description;
  final String shareCode; // New field
  final List<CourseMaterial> materials;
  final List<String> enrolledStudentIds;
  final DateTime createdAt;
  final String createdBy;
  final CourseColor color;
  final CourseSchedule? schedule;
  final String?
      originalCourseId; // Add this field to track the original course ID

  Course({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.shareCode, // New required field
    List<CourseMaterial>? materials,
    List<String>? enrolledStudentIds,
    DateTime? createdAt,
    required this.createdBy,
    required this.color,
    this.schedule,
    this.originalCourseId, // Add this parameter
  })  : materials = materials ?? [],
        enrolledStudentIds = enrolledStudentIds ?? [],
        createdAt = createdAt ?? DateTime.now();

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      shareCode: json['share_code'] as String? ??
          _generateDefaultShareCode(), // Add fallback for existing courses
      materials: (json['materials'] as List?)
              ?.map((m) => CourseMaterial.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      enrolledStudentIds: List<String>.from(json['enrolled_student_ids'] ?? []),
      createdAt: (json['created_at'] as Timestamp).toDate(),
      createdBy: json['created_by'] as String,

      // Convert stored string (e.g., "deepPurple") to CourseColor
      color: SLCColors.getCourseColorFromString(json['color'] ?? "navyBlue"),

      schedule: json['schedule'] != null
          ? CourseSchedule.fromJson(json['schedule'])
          : null,
      originalCourseId: json['original_course_id'] as String?, // Read from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'description': description,
      'share_code': shareCode, // Write to JSON
      'materials': materials.map((m) => m.toJson()).toList(),
      'enrolled_student_ids': enrolledStudentIds,
      'created_at': Timestamp.fromDate(createdAt),
      'created_by': createdBy,
      'color': color.name,

      'schedule': schedule?.toJson(),
      'original_course_id': originalCourseId, // Write to JSON
    };
  }

  Course copyWith({
    String? id,
    String? code,
    String? name,
    String? description,
    String? shareCode, // New parameter
    List<CourseMaterial>? materials,
    List<String>? enrolledStudentIds,
    DateTime? createdAt,
    String? createdBy,
    CourseColor? color,
    CourseSchedule? schedule,
    String? originalCourseId, // New parameter
  }) {
    return Course(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      shareCode: shareCode ?? this.shareCode, // Pass to constructor
      materials: materials ?? this.materials,
      enrolledStudentIds: enrolledStudentIds ?? this.enrolledStudentIds,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      color: color ?? this.color,
      schedule: schedule ?? this.schedule,
      originalCourseId:
          originalCourseId ?? this.originalCourseId, // Pass to constructor
    );
  }

  // Add this static method to generate a default share code for existing courses
  static String _generateDefaultShareCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = DateTime.now().millisecondsSinceEpoch % chars.length;
    // Use a simpler algorithm for default codes that doesn't need Random
    return List.generate(6, (i) => chars[(rnd + i * 7) % chars.length])
        .join('');
  }
}
