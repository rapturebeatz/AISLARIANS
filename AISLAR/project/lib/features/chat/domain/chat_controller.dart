import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/chat_model.dart';
import '../data/chat_repository.dart';

final chatRoomsProvider = StreamProvider.family<List<ChatRoomModel>, String>((ref, userId) {
  return ref.read(chatRepositoryProvider).streamRooms(userId);
});

final chatMessagesProvider = StreamProvider.family<List<MessageModel>, String>((ref, roomId) {
  return ref.read(chatRepositoryProvider).streamMessages(roomId);
});

final chatLoadingProvider = StateProvider<bool>((ref) => false);

final chatControllerProvider = Provider<ChatController>((ref) {
  return ChatController(ref.read(chatRepositoryProvider), ref);
});

class ChatController {
  final ChatRepository _repository;
  final Ref _ref;

  ChatController(this._repository, this._ref);

  Future<String> createRoom({
    required String type,
    String? name,
    required List<String> memberIds,
  }) async {
    _ref.read(chatLoadingProvider.notifier).state = true;
    try {
      return await _repository.createRoom(
        type: type,
        name: name,
        memberIds: memberIds,
      );
    } finally {
      _ref.read(chatLoadingProvider.notifier).state = false;
    }
  }

  Future<String> getOrCreateDirectRoom(String userId1, String userId2) async {
    return await _repository.getOrCreateDirectRoom(userId1, userId2);
  }

  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String content,
    String type = 'text',
    String? mediaUrl,
  }) async {
    await _repository.sendMessage(
      roomId: roomId,
      senderId: senderId,
      content: content,
      type: type,
      mediaUrl: mediaUrl,
    );
  }
}
