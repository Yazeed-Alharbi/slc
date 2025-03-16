import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final DateTime dateTime;
  final String createdBy;
  final DateTime createdAt;

  Event({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.createdBy,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dateTime: (json['date_time'] as Timestamp).toDate(),
      createdBy: json['created_by'] as String,
      createdAt: (json['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'title': title,
      'description': description,
      'date_time': Timestamp.fromDate(dateTime),
      'created_by': createdBy,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
