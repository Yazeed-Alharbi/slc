import 'package:cloud_firestore/cloud_firestore.dart';

class CourseMaterial {
  final String id;
  final String name;
  final String downloadUrl;
  final String type;
  final DateTime uploadedAt;

  CourseMaterial({
    required this.id,
    required this.name,
    required this.downloadUrl,
    required this.type,
    DateTime? uploadedAt,
  }) : uploadedAt = uploadedAt ?? DateTime.now();

  factory CourseMaterial.fromJson(Map<String, dynamic> json) {
    return CourseMaterial(
      id: json['id'] as String,
      name: json['name'] as String,
      downloadUrl: json['download_url'] as String,
      type: json['type'] as String,
      uploadedAt: (json['uploaded_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'download_url': downloadUrl,
        'type': type,
        'uploaded_at': Timestamp.fromDate(uploadedAt),
      };
}
