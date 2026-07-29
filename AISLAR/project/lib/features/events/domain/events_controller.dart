import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/event_model.dart';
import '../data/events_repository.dart';

final upcomingEventsProvider = StreamProvider<List<EventModel>>((ref) {
  return ref.read(eventsRepositoryProvider).streamUpcomingEvents();
});

final eventsLoadingProvider = StateProvider<bool>((ref) => false);

final eventsControllerProvider = Provider<EventsController>((ref) {
  return EventsController(ref.read(eventsRepositoryProvider), ref);
});

class EventsController {
  final EventsRepository _repository;
  final Ref _ref;

  EventsController(this._repository, this._ref);

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
  }) async {
    _ref.read(eventsLoadingProvider.notifier).state = true;
    try {
      return await _repository.createEvent(
        title: title,
        description: description,
        type: type,
        startDate: startDate,
        endDate: endDate,
        organizerId: organizerId,
        locationName: locationName,
        address: address,
        lat: lat,
        lng: lng,
        isVirtual: isVirtual,
        meetingLink: meetingLink,
      );
    } finally {
      _ref.read(eventsLoadingProvider.notifier).state = false;
    }
  }

  Future<void> rsvp(String eventId, String userId, String status) async {
    await _repository.rsvp(eventId, userId, status);
  }
}
