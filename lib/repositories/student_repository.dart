import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebaseUtil/firestore.dart';
import '../models/Student.dart';

class StudentRepository {
  final FirestoreUtils _firestoreUtils;
  final FirebaseAuth _auth;

  StudentRepository({
    required FirestoreUtils firestoreUtils,
    FirebaseAuth? auth,
  })  : _firestoreUtils = firestoreUtils,
        _auth = auth ?? FirebaseAuth.instance;

  Future<void> createStudent({
    required String email,
    required String name,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');

    final student = Student(
      uid: user.uid,
      email: email,
      name: name,
      photoUrl: photoUrl,
      enrolledCourseIds: [],
      focusSessionIds: [],
      friendIds: [],
      communityIds: [],
    );

    await _firestoreUtils.setDocument(
      path: 'students/${user.uid}',
      data: student.toJson(),
    );
  }

  Future<Student?> getStudent(String studentId) async {
    final doc = await _firestoreUtils.getDocument(
      path: 'students/$studentId',
    );

    if (!doc.exists) return null;
    return Student.fromJson(doc.data() as Map<String, dynamic>);
  }

  Future<Student> getOrCreateStudent() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');

    final doc = await _firestoreUtils.getDocument(
      path: 'students/${user.uid}',
    );

    if (doc.exists) {
      return Student.fromJson(doc.data() as Map<String, dynamic>);
    }

    final newStudent = Student(
      uid: user.uid,
      email: user.email!,
      name: user.displayName ?? "Default Name",
      photoUrl: user.photoURL,
      enrolledCourseIds: [],
      focusSessionIds: [],
      friendIds: [],
      communityIds: [],
    );

    await _firestoreUtils.setDocument(
      path: 'students/${user.uid}',
      data: newStudent.toJson(),
    );

    return newStudent;
  }

  Future<void> updateStudent(
      String studentId, Map<String, dynamic> data) async {
    await _firestoreUtils.updateDocument(
      path: 'students/$studentId',
      data: data,
    );
  }

  Future<void> addFocusSession(String studentId, String sessionId) async {
    await _firestoreUtils.updateDocument(
      path: 'students/$studentId',
      data: {
        'focusSessionIds': FieldValue.arrayUnion([sessionId]),
      },
    );
  }
}
