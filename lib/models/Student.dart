class Student {
  final String uid;
  final String email;
  final String name;
  final String? photoUrl;
  final List<String>? enrolledCourseIds;
  final List<String>? focusSessionIds;
  final List<String>? friendIds;
  final List<String>? communityIds;

  Student({
    required this.uid,
    required this.email,
    required this.name,
    this.photoUrl,
    this.enrolledCourseIds,
    this.focusSessionIds,
    this.friendIds,
    this.communityIds,
  });

  // Convert StudentModel to JSON (for Firebase or API storage)
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'enrolledCourseIds': enrolledCourseIds,
      'focusSessionIds': focusSessionIds,
      'friendIds': friendIds,
      'communityIds': communityIds,
    };
  }

  // Convert JSON (from Firebase or API response) to StudentModel
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      uid: json['uid'],
      email: json['email'],
      name: json['name'],
      photoUrl: json['photoUrl'],
      enrolledCourseIds: List<String>.from(json['enrolledCourseIds'] ?? []),
      focusSessionIds: List<String>.from(json['focusSessionIds'] ?? []),
      friendIds: List<String>.from(json['friendIds'] ?? []),
      communityIds: List<String>.from(json['communityIds'] ?? []),
    );
  }
}
