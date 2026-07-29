import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../models/chat_model.dart';
import '../data/chat_repository.dart';
import '../domain/chat_controller.dart';
import '../presentation/chat_room_screen.dart';

class ChatListScreen extends ConsumerWidget {
  final String userId;

  const ChatListScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(chatRoomsProvider(userId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
        ],
      ),
      body: roomsAsync.when(
        data: (rooms) => rooms.isEmpty
            ? const Center(child: Text('No conversations yet'))
            : ListView.builder(
                itemCount: rooms.length,
                itemBuilder: (_, i) => _RoomTile(room: rooms[i], userId: userId),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _RoomTile extends StatelessWidget {
  final ChatRoomModel room;
  final String userId;

  const _RoomTile({required this.room, required this.userId});

  String _roomName() {
    if (room.name != null) return room.name!;
    // For direct chats, show other member's name
    return room.memberIds.where((id) => id != userId).firstOrNull ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primary,
        child: Text(_roomName()[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
      ),
      title: Text(_roomName(), style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        room.lastMessage?.text ?? 'No messages yet',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      ),
      trailing: room.lastMessage != null
          ? Text(timeago.format(room.lastMessage!.sentAt), style: TextStyle(fontSize: 11, color: Colors.grey[500]))
          : null,
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => ChatRoomScreen(room: room),
      )),
    );
  }
}
