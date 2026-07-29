import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../models/feature_models.dart';
import '../data/gallery_repository.dart';

class AlbumDetailScreen extends ConsumerWidget {
  final AlbumModel album;

  const AlbumDetailScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(_albumPhotosProvider(album.id));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(album.title),
        actions: [
          IconButton(icon: const Icon(Icons.add_photo_alternate), onPressed: () {}),
        ],
      ),
      body: photosAsync.when(
        data: (photos) => photos.isEmpty
            ? const Center(child: Text('No photos yet'))
            : GridView.builder(
                padding: const EdgeInsets.all(4),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: photos.length,
                itemBuilder: (_, i) {
                  final photo = photos[i];
                  return GestureDetector(
                    onTap: () => _showPhoto(context, photo['url'] as String),
                    child: CachedNetworkImage(
                      imageUrl: photo['url'] as String,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: Colors.grey[200]),
                      errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showPhoto(BuildContext context, String url) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
        body: Center(
          child: InteractiveViewer(
            child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
          ),
        ),
      ),
    ));
  }
}

final _albumPhotosProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, albumId) {
  return ref.read(galleryRepositoryProvider).streamPhotos(albumId);
});
