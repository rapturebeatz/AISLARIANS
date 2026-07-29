import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firestore_service.dart';
import '../../../../models/post_model.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository(ref.read(firestoreServiceProvider));
});

class FeedRepository {
  final FirestoreService _firestore;

  FeedRepository(this._firestore);

  Stream<List<PostModel>> streamPosts() {
    return _firestore
        .streamCollection('posts', orderByField: 'createdAt', descending: true, limit: 50)
        .map((snap) => snap.docs.map((doc) => PostModel.fromJson(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  Stream<List<PostModel>> streamPostsByUser(String userId) {
    return _firestore
        .streamWhere('posts', 'authorId', userId, orderByField: 'createdAt', descending: true)
        .map((snap) => snap.docs.map((doc) => PostModel.fromJson(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  Future<void> createPost({
    required String authorId,
    required String content,
    List<String> mediaUrls = const [],
    List<String> mediaTypes = const [],
    List<String> tags = const [],
    List<String> mentionIds = const [],
    bool isAnnouncement = false,
  }) async {
    await _firestore.create('posts', {
      'authorId': authorId,
      'content': content,
      'mediaURLs': mediaUrls,
      'mediaTypes': mediaTypes,
      'tags': tags,
      'mentionIds': mentionIds,
      'isPinned': false,
      'isAnnouncement': isAnnouncement,
      'status': 'published',
      'likeCount': 0,
      'commentCount': 0,
      'shareCount': 0,
    });
  }

  Future<void> likePost(String postId, String userId) async {
    final likeId = '${postId}_$userId';
    await _firestore.set('likes', likeId, {
      'postId': postId,
      'userId': userId,
    });
    await _firestore.increment('posts', postId, 'likeCount');
  }

  Future<void> unlikePost(String postId, String userId) async {
    final likeId = '${postId}_$userId';
    await _firestore.delete('likes', likeId);
    await _firestore.increment('posts', postId, 'likeCount', amount: -1);
  }

  Future<bool> isLiked(String postId, String userId) async {
    final likeId = '${postId}_$userId';
    final doc = await _firestore.get('likes', likeId);
    return doc.exists;
  }

  Stream<bool> streamIsLiked(String postId, String userId) {
    return _firestore.streamDoc('likes', '${postId}_$userId').map((doc) => doc.exists);
  }

  Future<void> addComment(String postId, String authorId, String content, {String? parentId}) async {
    final docRef = await _firestore.create('comments', {
      'postId': postId,
      'authorId': authorId,
      'parentId': parentId,
      'content': content,
      'likeCount': 0,
      'isEdited': false,
    });
    await _firestore.increment('posts', postId, 'commentCount');
  }

  Stream<List<Map<String, dynamic>>> streamComments(String postId) {
    return _firestore
        .streamWhere('comments', 'postId', postId, orderByField: 'createdAt', descending: false)
        .map((snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>}).toList());
  }

  Future<void> deletePost(String postId) async {
    await _firestore.update('posts', postId, {'status': 'hidden', 'isDeleted': true});
  }
}
