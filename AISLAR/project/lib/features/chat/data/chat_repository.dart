import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firestore_service.dart';
import '../../../../models/chat_model.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.read(firestoreServiceProvider));
});

class ChatRepository {
  final FirestoreService _firestore;

  ChatRepository(this._firestore);

  // --- Rooms ---

  Stream<List<ChatRoomModel>> streamRooms(String userId) {
    return _firestore
        .streamWhere('chat_rooms', 'memberIds', userId, orderByField: 'updatedAt', descending: true)
        .map((snap) => snap.docs
            .map((doc) => ChatRoomModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<String> createRoom({
    required String type,
    String? name,
    String? photoUrl,
    required List<String> memberIds,
    List<String> adminIds = const [],
  }) async {
    final docRef = await _firestore.create('chat_rooms', {
      'type': type,
      'name': name,
      'photoURL': photoUrl,
      'memberIds': memberIds,
      'adminIds': adminIds.isNotEmpty ? adminIds : [memberIds.first],
      'lastMessage': null,
      'isArchived': false,
    });
    return docRef.id;
  }

  Future<String> getOrCreateDirectRoom(String userId1, String userId2) async {
    final roomId = [userId1, userId2]..sort();
    final key = '${roomId[0]}_${roomId[1]}';

    final existing = await _firestore.whereIn('chat_rooms', 'memberIds', [[userId1, userId2]]);
    if (existing.isNotEmpty) return existing.first.id;

    return createRoom(
      type: 'direct',
      memberIds: [userId1, userId2],
      adminIds: [userId1],
    );
  }

  // --- Messages ---

  Stream<List<MessageModel>> streamMessages(String roomId) {
    return _firestore
        .streamWhere('messages', 'roomId', roomId, orderByField: 'createdAt', descending: false, limit: 100)
        .map((snap) => snap.docs
            .map((doc) => MessageModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String content,
    String type = 'text',
    String? mediaUrl,
    String? replyTo,
  }) async {
    await _firestore.create('messages', {
      'roomId': roomId,
      'senderId': senderId,
      'content': content,
      'type': type,
      'mediaURL': mediaUrl,
      'replyTo': replyTo,
      'mentions': [],
      'readBy': [senderId],
      'deliveredTo': [senderId],
      'isEdited': false,
      'isDeleted': false,
    });

    await _firestore.update('chat_rooms', roomId, {
      'lastMessage': {
        'text': content.length > 100 ? '${content.substring(0, 100)}...' : content,
        'senderId': senderId,
        'sentAt': Timestamp.now(),
        'type': type,
      },
    });
  }

  Future<void> markAsRead(String roomId, String userId) async {
    final messages = await _firestore.query('messages')
        .where('roomId', isEqualTo: roomId)
        .where('readBy', arrayContains: userId)
        .get();

    // Mark last 50 unread messages as read
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in messages.docs) {
      batch.update(doc.reference, {
        'readBy': FieldValue.arrayUnion([userId]),
      });
    }
    await batch.commit();
  }
}
