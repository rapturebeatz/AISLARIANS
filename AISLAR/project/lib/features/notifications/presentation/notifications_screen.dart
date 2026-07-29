import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../models/notification_model.dart';
import '../../../../core/services/firestore_service.dart';

final notificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  return ref.read(firestoreServiceProvider)
      .streamWhere('notifications', 'recipientId', 'current-user', orderByField: 'createdAt', descending: true)
      .map((snap) => snap.docs
          .map((doc) => NotificationModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList());
});

final unreadCountProvider = StreamProvider<int>((ref) {
  return ref.read(firestoreServiceProvider)
      .streamWhere('notifications', 'recipientId', 'current-user', orderByField: 'createdAt', descending: true)
      .map((snap) => snap.docs.where((d) => (d.data() as Map)['isRead'] == false).length);
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsync = ref.watch(notificationsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(icon: const Icon(Icons.done_all), onPressed: () {}),
        ],
      ),
      body: notifsAsync.when(
        data: (notifs) => notifs.isEmpty
            ? const Center(child: Text('No notifications yet'))
            : ListView.builder(
                itemCount: notifs.length,
                itemBuilder: (_, i) {
                  final n = notifs[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: n.isRead ? Colors.grey[200] : theme.colorScheme.primaryContainer,
                      child: Icon(_iconForType(n.type), color: n.isRead ? Colors.grey : theme.colorScheme.primary),
                    ),
                    title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                        Text(timeago.format(n.createdAt), style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      ],
                    ),
                    trailing: n.isRead ? null : Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.blue)),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'birthday': return Icons.cake;
      case 'event': return Icons.event;
      case 'message': return Icons.message;
      case 'announcement': return Icons.campaign;
      case 'approval': return Icons.check_circle;
      case 'mention': return Icons.alternate_email;
      default: return Icons.notifications;
    }
  }
}
