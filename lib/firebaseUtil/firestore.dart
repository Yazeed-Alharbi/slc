import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirestoreUtils {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirestoreUtils({FirebaseFirestore? firestore, FirebaseStorage? storage})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  // Collection References
  CollectionReference get students => _firestore.collection('students');
  CollectionReference get courses => _firestore.collection('courses');
  CollectionReference get focusSessions =>
      _firestore.collection('focus_sessions');
  CollectionReference get courseEnrollments =>
      _firestore.collection('course_enrollments');

  // Generic CRUD Operations
  // Add this debugging to your setDocument method
  Future<String> uploadFileToStorage({
    required File file,
    required String courseId,
  }) async {
    try {
      String fileName =
          "${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}";
      print("Uploading file with name: $fileName");

      Reference ref =
          _storage.ref().child("courses/$courseId/materials/$fileName");
      print("Storage reference: ${ref.fullPath}");

      UploadTask uploadTask = ref.putFile(file);

      TaskSnapshot snapshot = await uploadTask;
      print("File uploaded. Retrieving download URL...");

      String downloadUrl = await snapshot.ref.getDownloadURL();
      print("Download URL: $downloadUrl");

      return downloadUrl;
    } catch (e) {
      print("Error in uploadFileToStorage: $e");
      throw Exception("Failed to upload file: $e");
    }
  }

  Future<void> deleteFileFromStorage(String downloadUrl) async {
    try {
      // Create a reference from the download URL
      Reference ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      print("File deleted from storage: $downloadUrl");
    } catch (e) {
      print("Error deleting file from storage: $e");
      throw Exception("Failed to delete file from storage: $e");
    }
  }

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
