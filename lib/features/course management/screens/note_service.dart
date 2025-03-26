import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:slc/models/note.dart';

class NoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Current course ID
  String? _currentCourseId;

  // Constructor that takes a courseId
  NoteService({String? courseId}) {
    _currentCourseId = courseId;
  }

  // Method to set current course ID
  void setCourseId(String courseId) {
    _currentCourseId = courseId;
  }

  // Get the user ID
  String? _getUserId() {
    return _auth.currentUser?.uid;
  }

  // Get reference to student's notes collection for a specific course
  CollectionReference _getNotesCollection() {
    final userId = _getUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    if (_currentCourseId == null) {
      throw Exception('Course ID not set');
    }

    // Path: students/{studentId}/courses/{courseId}/notes
    return _firestore
        .collection('students')
        .doc(userId)
        .collection('courses')
        .doc(_currentCourseId)
        .collection('notes');
  }

  // Get all notes for current student and course
  Stream<List<Note>> getNotes() {
    try {
      final userId = _getUserId();
      if (userId == null) {
        return Stream.value([]);
      }

      if (_currentCourseId == null) {
        print('Warning: Course ID not set when getting notes');
        return Stream.value([]);
      }

      print(
          'Getting notes for student ID: $userId, course ID: $_currentCourseId');

      return _getNotesCollection()
          .orderBy('lastModified', descending: true)
          .snapshots()
          .map((snapshot) {
        print('Retrieved ${snapshot.docs.length} notes from Firestore');

        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          List<Map<String, dynamic>> pages = [];

          if (data['pages'] != null) {
            // Convert the list of dynamic to List<Map<String, dynamic>>
            pages = (data['pages'] as List).map((page) {
              return Map<String, dynamic>.from(page as Map);
            }).toList();
          }

          return Note(
            id: doc.id,
            title: data['title'] ?? 'Untitled',
            createdAt: data['createdAt'] != null
                ? (data['createdAt'] as Timestamp).toDate()
                : DateTime.now(),
            pages: pages,
          );
        }).toList();
      });
    } catch (e) {
      print('Error getting notes: $e');
      return Stream.value([]);
    }
  }

  // Get a specific note
  Future<Note?> getNote(String noteId) async {
    try {
      print('Getting note with ID: $noteId for course: $_currentCourseId');
      final doc = await _getNotesCollection().doc(noteId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        List<Map<String, dynamic>> pages = [];

        if (data['pages'] != null) {
          // Convert the list of dynamic to List<Map<String, dynamic>>
          pages = (data['pages'] as List).map((page) {
            return Map<String, dynamic>.from(page as Map);
          }).toList();
        }

        print('Found note with ${pages.length} pages');

        return Note(
          id: doc.id,
          title: data['title'] ?? 'Untitled',
          createdAt: data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
          pages: pages,
        );
      }
      print('Note not found with ID: $noteId');
      return null;
    } catch (e) {
      print('Error getting note: $e');
      return null;
    }
  }

  // Create a new note for the current course
  Future<String> createNote(String title) async {
    try {
      final userId = _getUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      if (_currentCourseId == null) {
        throw Exception('Course ID not set');
      }

      print(
          'Creating note with title: $title for student: $userId, course: $_currentCourseId');

      // Make sure parent documents exist
      final studentRef = _firestore.collection('students').doc(userId);
      final courseRef = studentRef.collection('courses').doc(_currentCourseId);

      // Check if the course document exists
      final courseDoc = await courseRef.get();
      if (!courseDoc.exists) {
        // Create course document if it doesn't exist
        await courseRef.set({
          'lastActive': Timestamp.now(),
        });
        print('Created course document for course ID: $_currentCourseId');
      }

      // Now create the note in the course's notes subcollection
      final docRef = _getNotesCollection().doc();

      // Set the data
      await docRef.set({
        'title': title,
        'courseId': _currentCourseId,
        'createdAt': Timestamp.now(),
        'lastModified': Timestamp.now(),
        'pages': [
          {
            'sketch': null,
            'text': '',
          }
        ],
      });

      print('Note created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error creating note: $e');
      rethrow;
    }
  }

  // Update a note's pages
  Future<void> updateNotePages(
      String noteId, List<Map<String, dynamic>> pages) async {
    try {
      if (_currentCourseId == null) {
        throw Exception('Course ID not set');
      }

      print('Updating note pages for ID: $noteId in course: $_currentCourseId');
      print('Number of pages: ${pages.length}');

      final docRef = _getNotesCollection().doc(noteId);

      // Get the document first to check if it exists
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Update existing document
        await docRef.update({
          'pages': pages,
          'lastModified': Timestamp.now(),
        });
        print('Note updated successfully');
      } else {
        // Create new document if it doesn't exist
        await docRef.set({
          'title': 'Untitled', // Default title
          'courseId': _currentCourseId,
          'createdAt': Timestamp.now(),
          'lastModified': Timestamp.now(),
          'pages': pages,
        });
        print('Created note document as it did not exist');
      }
    } catch (e) {
      print('Error updating note pages: $e');
      rethrow;
    }
  }

  // Delete a note
  Future<void> deleteNote(String noteId) async {
    try {
      await _getNotesCollection().doc(noteId).delete();
      print('Note deleted with ID: $noteId');
    } catch (e) {
      print('Error deleting note: $e');
      rethrow;
    }
  }
}
