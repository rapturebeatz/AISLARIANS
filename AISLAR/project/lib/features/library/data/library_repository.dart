import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firestore_service.dart';

class DocumentModel {
  final String id;
  final String title;
  final String? description;
  final String type;
  final String fileUrl;
  final int fileSize;
  final String fileType;
  final String uploadedBy;
  final bool isPublic;
  final DateTime createdAt;

  DocumentModel({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.fileUrl,
    this.fileSize = 0,
    this.fileType = 'application/pdf',
    required this.uploadedBy,
    this.isPublic = false,
    required this.createdAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json, String id) => DocumentModel(
    id: id,
    title: json['title'],
    description: json['description'],
    type: json['type'] ?? 'other',
    fileUrl: json['fileURL'],
    fileSize: json['fileSize'] ?? 0,
    fileType: json['fileType'] ?? 'application/pdf',
    uploadedBy: json['uploadedBy'],
    isPublic: json['isPublic'] ?? false,
    createdAt: json['createdAt'].toDate(),
  );
}

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepository(ref.read(firestoreServiceProvider));
});

class LibraryRepository {
  final FirestoreService _firestore;

  LibraryRepository(this._firestore);

  Stream<List<DocumentModel>> streamDocuments({String? type}) {
    if (type != null) {
      return _firestore
          .streamWhere('documents', 'type', type, orderByField: 'createdAt', descending: true)
          .map((snap) => snap.docs
              .map((doc) => DocumentModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
              .toList());
    }
    return _firestore
        .streamCollection('documents', orderByField: 'createdAt', descending: true)
        .map((snap) => snap.docs
            .map((doc) => DocumentModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }
}
