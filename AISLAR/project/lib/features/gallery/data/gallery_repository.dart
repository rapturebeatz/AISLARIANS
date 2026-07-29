import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firestore_service.dart';
import '../../../../models/feature_models.dart';

final galleryRepositoryProvider = Provider<GalleryRepository>((ref) {
  return GalleryRepository(ref.read(firestoreServiceProvider));
});

class GalleryRepository {
  final FirestoreService _firestore;

  GalleryRepository(this._firestore);

  Stream<List<AlbumModel>> streamAlbums() {
    return _firestore
        .streamCollection('albums', orderByField: 'createdAt', descending: true)
        .map((snap) => snap.docs
            .map((doc) => AlbumModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Stream<List<Map<String, dynamic>>> streamPhotos(String albumId) {
    return _firestore
        .streamWhere('photos', 'albumId', albumId, orderByField: 'createdAt', descending: true)
        .map((snap) => snap.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList());
  }

  Future<String> createAlbum({
    required String title,
    required String type,
    required String createdBy,
    String? description,
  }) async {
    final docRef = await _firestore.create('albums', {
      'title': title,
      'description': description,
      'type': type,
      'createdBy': createdBy,
      'isFeatured': false,
      'photoCount': 0,
    });
    return docRef.id;
  }

  Future<void> addPhoto({
    required String albumId,
    required String uploadedBy,
    required String url,
    String? caption,
  }) async {
    await _firestore.create('photos', {
      'albumId': albumId,
      'uploadedBy': uploadedBy,
      'url': url,
      'caption': caption,
      'tags': [],
      'mentionIds': [],
      'likeCount': 0,
    });
    await _firestore.increment('albums', albumId, 'photoCount');
  }
}
