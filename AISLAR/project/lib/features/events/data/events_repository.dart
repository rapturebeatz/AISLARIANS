import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firestore_service.dart';
import '../../../../models/event_model.dart';

final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  return EventsRepository(ref.read(firestoreServiceProvider));
});

class EventsRepository {
  final FirestoreService _firestore;

  EventsRepository(this._firestore);

  Stream<List<EventModel>> streamUpcomingEvents() {
    final now = DateTime.now();
    return _firestore
        .streamWhere('events', 'status', 'published', orderByField: 'startDate', descending: false, limit: 50)
        .map((snap) => snap.docs
            .map((doc) => EventModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
            .where((e) => e.startDate.isAfter(now))
            .toList());
  }

  Stream<List<EventModel>> streamPastEvents() {
    final now = DateTime.now();
    return _firestore
        .streamCollection('events', orderByField: 'startDate', descending: true, limit: 50)
        .map((snap) => snap.docs
            .map((doc) => EventModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
            .where((e) => e.startDate.isBefore(now))
            .toList());
  }

  Stream<EventModel> streamEvent(String eventId) {
    return _firestore.streamDoc('events', eventId).map(
      (doc) => EventModel.fromJson(doc.data() as Map<String, dynamic>, doc.id),
    );
  }

  Future<String> createEvent({
    required String title,
    required String description,
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String organizerId,
    required String locationName,
    String? address,
    double? lat,
    double? lng,
    bool isVirtual = false,
    String? meetingLink,
    int? maxAttendees,
    DateTime? rsvpDeadline,
    double? ticketPrice,
    String? currency,
  }) async {
    final docRef = await _firestore.create('events', {
      'title': title,
      'description': description,
      'type': type,
      'startDate': startDate,
      'endDate': endDate,
      'location': {
        'name': locationName,
        'address': address,
        'lat': lat,
        'lng': lng,
        'isVirtual': isVirtual,
        'meetingLink': meetingLink,
      },
      'organizerId': organizerId,
      'maxAttendees': maxAttendees,
      'rsvpDeadline': rsvpDeadline,
      'ticketPrice': ticketPrice,
      'currency': currency,
      'attendeeCount': 0,
      'status': 'published',
    });
    return docRef.id;
  }

  Future<void> rsvp(String eventId, String userId, String status) async {
    await _firestore.set('attendees', '${eventId}_$userId', {
      'eventId': eventId,
      'userId': userId,
      'status': status,
      'rsvpAt': Timestamp.now(),
    });

    if (status == 'going') {
      await _firestore.increment('events', eventId, 'attendeeCount');
    }
  }

  Stream<int> streamAttendeeCount(String eventId) {
    return _firestore.streamDoc('events', eventId).map(
      (doc) => (doc.data()?['attendeeCount'] ?? 0) as int,
    );
  }

  Stream<List<Map<String, dynamic>>> streamAttendees(String eventId) {
    return _firestore
        .streamWhere('attendees', 'eventId', eventId, orderByField: 'rsvpAt', descending: false)
        .map((snap) => snap.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList());
  }

  Future<String?> getRsvpStatus(String eventId, String userId) async {
    final doc = await _firestore.get('attendees', '${eventId}_$userId');
    if (!doc.exists) return null;
    return doc.data()?['status'] as String?;
  }

  Stream<String?> streamRsvpStatus(String eventId, String userId) {
    return _firestore.streamDoc('attendees', '${eventId}_$userId').map(
      (doc) => doc.exists ? doc.data()?['status'] as String? : null,
    );
  }
}
