import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

class StorageService {
  final _storage = FirebaseStorage.instance;

  Future<String> uploadFile({
    required String path,
    required File file,
    String? mimeType,
  }) async {
    final ref = _storage.ref().child(path);
    final task = await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<String> uploadBytes({
    required String path,
    required List<int> bytes,
    String? mimeType,
  }) async {
    final ref = _storage.ref().child(path);
    final task = await ref.putData(bytes);
    return await ref.getDownloadURL();
  }

  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {}
  }

  Future<String> getDownloadUrl(String path) async {
    final ref = _storage.ref().child(path);
    return await ref.getDownloadURL();
  }

  Future<List<String>> listFiles(String prefix) async {
    final ref = _storage.ref().child(prefix);
    final result = await ref.listAll();
    final urls = <String>[];
    for (final item in result.items) {
      urls.add(await item.getDownloadURL());
    }
    return urls;
  }
}
