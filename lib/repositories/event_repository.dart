import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebaseUtil/firestore.dart';
import '../models/event.dart';

class EventRepository {
  final FirestoreUtils _firestoreUtils;

  EventRepository({
    required FirestoreUtils firestoreUtils,
  }) : _firestoreUtils = firestoreUtils;

  // Create a new event
  Future<Event> createEvent({
    required String courseId,
    required String title,
    required String description,
    required DateTime dateTime,
    required String createdBy,
  }) async {
    final eventId = _firestoreUtils.events.doc().id;

    final event = Event(
      id: eventId,
      courseId: courseId,
      title: title,
      description: description,
      dateTime: dateTime,
      createdBy: createdBy,
    );

    await _firestoreUtils.setDocument(
      path: 'events/$eventId',
      data: event.toJson(),
    );

    return event;
  }

  // Get all events for a course
  Stream<List<Event>> streamCourseEvents(String courseId) {
    print("Streaming events for course: $courseId");

    return _firestoreUtils.events
        .where('course_id', isEqualTo: courseId)
        .orderBy('date_time')
        .snapshots()
        .map((snapshot) {
      print("Event snapshot received - doc count: ${snapshot.docs.length}");

      return snapshot.docs.map((doc) {
        return Event.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });
      }).toList();
    });
  }

  // Update an event
  Future<void> updateEvent({
    required String eventId,
    required String title,
    required String description,
    required DateTime dateTime,
  }) async {
    await _firestoreUtils.updateDocument(
      path: 'events/$eventId',
      data: {
        'title': title,
        'description': description,
        'date_time': Timestamp.fromDate(dateTime),
      },
    );
  }

  // Delete an event
  Future<void> deleteEvent({
    required String eventId,
  }) async {
    await _firestoreUtils.deleteDocument(
      path: 'events/$eventId',
    );
  }
}
