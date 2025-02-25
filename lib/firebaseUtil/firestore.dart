import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUtils {
  final FirebaseFirestore _firestore;

  FirestoreUtils({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection References
  CollectionReference get students => _firestore.collection('students');
  CollectionReference get courses => _firestore.collection('courses');
  CollectionReference get focusSessions =>
      _firestore.collection('focus_sessions');
  CollectionReference get courseEnrollments =>
      _firestore.collection('course_enrollments');

  // Generic CRUD Operations
  // Add this debugging to your setDocument method

  Future<void> setDocument({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    try {
      print("Setting document at path: $path");
      print("Document data: $data");

      final reference = _firestore.doc(path);
      print("Reference path: ${reference.path}");

      await reference.set(data);
      print("Document successfully written at $path");
    } catch (e) {
      print("Error in setDocument: $e");
      throw Exception('Failed to set document: $e');
    }
  }

// Make sure collection references are properly defined
  Future<DocumentSnapshot> getDocument({required String path}) async {
    try {
      final reference = _firestore.doc(path);
      return await reference.get();
    } catch (e) {
      throw Exception('Failed to get document: $e');
    }
  }

  Future<void> updateDocument({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    try {
      final reference = _firestore.doc(path);
      await reference.update(data);
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }

// Add this method to the FirestoreUtils class
  Future<void> deleteDocument({required String path}) async {
    try {
      final reference = _firestore.doc(path);
      await reference.delete();
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  Stream<DocumentSnapshot> streamDocument({required String path}) {
    try {
      final reference = _firestore.doc(path);
      return reference.snapshots();
    } catch (e) {
      throw Exception('Failed to stream document: $e');
    }
  }
}
