import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:slc/models/Student.dart';


class FirestoreUtils {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get students => _firestore.collection('students');

  Future<void> createNewStudent({
    required String email,
    required String name,
    String? photoUrl,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user found');

      final String uid = user.uid;
      final student = Student(
        uid: uid,
        email: email,
        name: name,
        photoUrl: photoUrl,
        enrolledCourseIds: [],
        focusSessionIds: [],
        friendIds: [],
        communityIds: [],
      );

      await students.doc(uid).set(student.toJson());
    } catch (e) {
      throw Exception('Failed to create student profile: $e');
    }
  }

  Future<Student?> getStudentData(String studentId) async {
    try {
      final DocumentSnapshot doc = await students.doc(studentId).get();
      if (!doc.exists) return null;
      return Student.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get student data: $e');
    }
  }

  Future<Student> getOrCreateStudent() async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');

    final String uid = user.uid;
    final DocumentSnapshot doc = await students.doc(uid).get();

    if (doc.exists) {
      return Student.fromJson(doc.data() as Map<String, dynamic>);
    } else {
      final Student newStudent = Student(
        uid: uid,
        email: user.email!,
        name: user.displayName ?? "Default Name",
        photoUrl: user.photoURL,
        enrolledCourseIds: [],
        focusSessionIds: [],
        friendIds: [],
        communityIds: [],
      );

      await students.doc(uid).set(newStudent.toJson());
      return newStudent;
    }
  }

  Future<void> updateStudentProfile(
      String studentId, Map<String, dynamic> data) async {
    try {
      await students.doc(studentId).update(data);
    } catch (e) {
      throw Exception('Failed to update student profile: $e');
    }
  }

  Future<void> addFocusSession(String studentId, String sessionId) async {
    try {
      await students.doc(studentId).update({
        'focusSessionIds': FieldValue.arrayUnion([sessionId]),
      });
    } catch (e) {
      throw Exception('Failed to add focus session: $e');
    }
  }
}
