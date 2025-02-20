import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreUtils {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get students => _firestore.collection('students');

  Future<void> createNewStudent({
    required String fullName,
    required String email,
    String? profilePicture,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user found');

      await students.doc(user.uid).set({
        'full_name': fullName,
        'email': email,
        'profile_picture': profilePicture ?? '',
        'join_date': FieldValue.serverTimestamp(),
        'focus_sessions': 0,
      });
    } catch (e) {
      throw Exception('Failed to create student profile: $e');
    }
  }

  Future<Map<String, dynamic>?> getStudentData(String studentId) async {
    try {
      final DocumentSnapshot doc = await students.doc(studentId).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('Failed to get student data: $e');
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

  Future<void> incrementFocusSessions(String studentId) async {
    try {
      await students.doc(studentId).update({
        'focus_sessions': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to increment focus sessions: $e');
    }
  }
}
