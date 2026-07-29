import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../models/event_model.dart';
import '../domain/events_controller.dart';
import '../presentation/event_detail_screen.dart';
import 'create_event_screen.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(upcomingEventsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateEventScreen()));
          }),
        ],
      ),
      body: eventsAsync.when(
        data: (events) => events.isEmpty
            ? const Center(child: Text('No upcoming events'))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: events.length,
                itemBuilder: (_, i) => _EventCard(event: events[i]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventModel event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailScreen(event: event))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(dateFormat.format(event.startDate).split(' ')[0], style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)),
                    Text(dateFormat.format(event.startDate).split(' ')[1], style: TextStyle(fontSize: 11, color: theme.colorScheme.onPrimaryContainer)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${timeFormat.format(event.startDate)} - ${timeFormat.format(event.endDate)}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    Text(event.location.name, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                  ],
                ),
              ),
              Chip(
                label: Text(event.type, style: const TextStyle(fontSize: 11)),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
