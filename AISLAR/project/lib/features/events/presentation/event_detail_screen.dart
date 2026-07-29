import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../models/event_model.dart';
import '../data/events_repository.dart';
import '../domain/events_controller.dart';

class EventDetailScreen extends ConsumerWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    final rsvpStatusAsync = ref.watch(_rsvpStatusProvider(event.id));
    final attendeeCountAsync = ref.watch(_attendeeCountProvider(event.id));

    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.bannerUrl != null)
              Image.network(event.bannerUrl!, height: 200, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox()),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  _DetailRow(icon: Icons.calendar_today, label: dateFormat.format(event.startDate)),
                  _DetailRow(icon: Icons.access_time, label: '${timeFormat.format(event.startDate)} - ${timeFormat.format(event.endDate)}'),
                  _DetailRow(icon: event.location.isVirtual ? Icons.videocam : Icons.location_on, label: event.location.name),
                  if (event.location.address != null) _DetailRow(icon: Icons.map, label: event.location.address!),
                  if (event.location.meetingLink != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => launchUrl(Uri.parse(event.location.meetingLink!)),
                        child: Row(
                          children: [
                            Icon(Icons.link, size: 18, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text('Join virtually', style: TextStyle(color: theme.colorScheme.primary)),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),
                  _DetailRow(icon: Icons.people, label: '${attendeeCountAsync.valueOrNull ?? event.attendeeCount} attending'),

                  if (event.description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('About', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(event.description, style: const TextStyle(fontSize: 14)),
                  ],

                  const SizedBox(height: 24),

                  rsvpStatusAsync.when(
                    data: (status) {
                      if (status == 'going') {
                        return Chip(
                          label: const Text('You\'re going'),
                          avatar: const Icon(Icons.check, size: 16),
                          backgroundColor: Colors.green[100],
                        );
                      }
                      return SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: () {
                            ref.read(eventsControllerProvider).rsvp(event.id, 'current-user', 'going');
                          },
                          icon: const Icon(Icons.event_available),
                          label: const Text('RSVP - Going'),
                        ),
                      );
                    },
                    loading: () => const SizedBox(height: 48, child: Center(child: CircularProgressIndicator())),
                    error: (_, __) => const SizedBox(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

final _rsvpStatusProvider = StreamProvider.family<String?, String>((ref, eventId) {
  return ref.read(eventsRepositoryProvider).streamRsvpStatus(eventId, 'current-user');
});

final _attendeeCountProvider = StreamProvider.family<int, String>((ref, eventId) {
  return ref.read(eventsRepositoryProvider).streamAttendeeCount(eventId);
});
