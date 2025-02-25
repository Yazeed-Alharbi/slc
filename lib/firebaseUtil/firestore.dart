import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUtils {
  final FirebaseFirestore _firestore;

  FirestoreUtils({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection References
  CollectionReference get students => _firestore.collection('students');
  CollectionReference get courses => _firestore.collection('courses');
  CollectionReference get focusSessions => _firestore.collection('focus_sessions');

  // Generic CRUD Operations
  Future<void> setDocument({
    required String path,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    try {
      final reference = _firestore.doc(path);
      await reference.set(data, SetOptions(merge: merge));
    } catch (e) {
      throw Exception('Failed to set document: $e');
    }
  }

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

  Stream<DocumentSnapshot> streamDocument({required String path}) {
    try {
      final reference = _firestore.doc(path);
      return reference.snapshots();
    } catch (e) {
      throw Exception('Failed to stream document: $e');
    }
  }
}