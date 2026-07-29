import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../../models/post_model.dart';
import '../../data/feed_repository.dart';
import '../../domain/feed_controller.dart';
import '../../../../auth/presentation/auth_controller.dart';
import '../post_detail_screen.dart';

class PostCard extends ConsumerWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailScreen(post: post))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      post.authorId.isNotEmpty ? post.authorId[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.authorId, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(timeago.format(post.createdAt), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                  if (post.isAnnouncement)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('Announcement', style: TextStyle(fontSize: 10, color: theme.colorScheme.onPrimaryContainer)),
                    ),
                ],
              ),
              if (post.content.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(post.content, style: const TextStyle(fontSize: 15)),
              ],
              if (post.mediaUrls.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(post.mediaUrls.first, fit: BoxFit.cover, height: 200, width: double.infinity, errorBuilder: (_, __, ___) => const SizedBox()),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _LikeButton(post: post, userId: user?.uid),
                  const SizedBox(width: 4),
                  Text('${post.likeCount}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline, size: 20),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailScreen(post: post))),
                  ),
                  Text('${post.commentCount}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.share_outlined, size: 20),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LikeButton extends ConsumerWidget {
  final PostModel post;
  final String? userId;

  const _LikeButton({required this.post, this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (userId == null) return const Icon(Icons.favorite_border, size: 20);

    final isLikedAsync = ref.watch(_isLikedProvider(post.id));

    return IconButton(
      icon: Icon(
        isLikedAsync.when(
          data: (liked) => liked ? Icons.favorite : Icons.favorite_border,
          loading: () => Icons.favorite_border,
          error: (_, __) => Icons.favorite_border,
        ),
        color: isLikedAsync.when(
          data: (liked) => liked ? Colors.red : null,
          loading: () => null,
          error: (_, __) => null,
        ),
        size: 20,
      ),
      onPressed: () {
        final controller = ref.read(feedControllerProvider);
        isLikedAsync.whenData((liked) {
          if (liked) {
            controller.unlikePost(post.id);
          } else {
            controller.likePost(post.id);
          }
        });
      },
    );
  }
}

final _isLikedProvider = StreamProvider.family<bool, String>((ref, postId) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(false);
  return ref.read(feedRepositoryProvider).streamIsLiked(postId, user.uid);
});
