import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/post_model.dart';
import '../data/feed_repository.dart';
import '../../auth/presentation/auth_controller.dart';

final feedListProvider = StreamProvider<List<PostModel>>((ref) {
  return ref.read(feedRepositoryProvider).streamPosts();
});

final feedLoadingProvider = StateProvider<bool>((ref) => false);

final feedControllerProvider = Provider<FeedController>((ref) {
  return FeedController(ref.read(feedRepositoryProvider), ref);
});

class FeedController {
  final FeedRepository _repository;
  final Ref _ref;

  FeedController(this._repository, this._ref);

  Future<void> createPost({
    required String content,
    List<String> mediaUrls = const [],
    List<String> mediaTypes = const [],
  }) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    _ref.read(feedLoadingProvider.notifier).state = true;
    try {
      await _repository.createPost(
        authorId: user.uid,
        content: content,
        mediaUrls: mediaUrls,
        mediaTypes: mediaTypes,
      );
    } finally {
      _ref.read(feedLoadingProvider.notifier).state = false;
    }
  }

  Future<void> likePost(String postId) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;
    await _repository.likePost(postId, user.uid);
  }

  Future<void> unlikePost(String postId) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;
    await _repository.unlikePost(postId, user.uid);
  }

  Future<void> addComment(String postId, String content) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;
    await _repository.addComment(postId, user.uid, content);
  }

  Future<void> deletePost(String postId) async {
    await _repository.deletePost(postId);
  }
}
