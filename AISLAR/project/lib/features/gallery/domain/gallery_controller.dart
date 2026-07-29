import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/feature_models.dart';
import '../data/gallery_repository.dart';

final albumsProvider = StreamProvider<List<AlbumModel>>((ref) {
  return ref.read(galleryRepositoryProvider).streamAlbums();
});

final galleryControllerProvider = Provider<GalleryController>((ref) {
  return GalleryController(ref.read(galleryRepositoryProvider), ref);
});

class GalleryController {
  final GalleryRepository _repository;
  final Ref _ref;

  GalleryController(this._repository, this._ref);

  Future<String> createAlbum({
    required String title,
    required String type,
    required String createdBy,
    String? description,
  }) async {
    return await _repository.createAlbum(
      title: title,
      type: type,
      createdBy: createdBy,
      description: description,
    );
  }

  Future<void> addPhoto({
    required String albumId,
    required String uploadedBy,
    required String url,
    String? caption,
  }) async {
    await _repository.addPhoto(
      albumId: albumId,
      uploadedBy: uploadedBy,
      url: url,
      caption: caption,
    );
  }
}
