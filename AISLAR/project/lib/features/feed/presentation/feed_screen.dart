import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/post_model.dart';
import '../../data/feed_repository.dart';
import '../../domain/feed_controller.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../widgets/post_card.dart';
import 'create_post_screen.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(feedListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Feed'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostScreen()));
          }),
        ],
      ),
      body: postsAsync.when(
        data: (posts) => posts.isEmpty
            ? const Center(child: Text('No posts yet. Be the first!'))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: posts.length,
                itemBuilder: (_, i) => PostCard(post: posts[i]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
