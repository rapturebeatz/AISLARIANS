import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

class FirestoreService {
  final _firestore = FirebaseFirestore.instance;

  // --- Generic CRUD ---

  Future<DocumentReference> create(String collection, Map<String, dynamic> data) {
    return _firestore.collection(collection).add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> set(String collection, String id, Map<String, dynamic> data) {
    return _firestore.collection(collection).doc(id).set({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> update(String collection, String id, Map<String, dynamic> data) {
    return _firestore.collection(collection).doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> delete(String collection, String id) {
    return _firestore.collection(collection).doc(id).delete();
  }

  Future<DocumentSnapshot> get(String collection, String id) {
    return _firestore.collection(collection).doc(id).get();
  }

  Future<List<DocumentSnapshot>> getAll(String collection) {
    return _firestore.collection(collection).get().then((snap) => snap.docs);
  }

  // --- Queries ---

  Query query(String collection) => _firestore.collection(collection);

  Future<List<DocumentSnapshot>> whereIn(String collection, String field, List<dynamic> values) {
    return _firestore
        .collection(collection)
        .where(field, whereIn: values)
        .get()
        .then((snap) => snap.docs);
  }

  // --- Streams ---

  Stream<DocumentSnapshot> streamDoc(String collection, String id) {
    return _firestore.collection(collection).doc(id).snapshots();
  }

  Stream<QuerySnapshot> streamCollection(String collection, {
    String? orderByField,
    bool descending = true,
    int? limit,
  }) {
    var query = _firestore.collection(collection) as Query;
    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }
    if (limit != null) {
      query = query.limit(limit);
    }
    return query.snapshots();
  }

  Stream<QuerySnapshot> streamWhere(String collection, String field, dynamic value, {
    String? orderByField,
    bool descending = true,
    int? limit,
  }) {
    var query = _firestore.collection(collection).where(field, isEqualTo: value) as Query;
    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }
    if (limit != null) {
      query = query.limit(limit);
    }
    return query.snapshots();
  }

  // --- Batched writes ---

  Future<void> batchWrite(List<Map<String, dynamic>> operations) {
    final batch = _firestore.batch();
    for (final op in operations) {
      final ref = _firestore.collection(op['collection']).doc(op['id']);
      switch (op['type']) {
        case 'set':
          batch.set(ref, op['data']);
          break;
        case 'update':
          batch.update(ref, op['data']);
          break;
        case 'delete':
          batch.delete(ref);
          break;
      }
    }
    return batch.commit();
  }

  // --- Increment/Decrement ---

  Future<void> increment(String collection, String id, String field, {int amount = 1}) {
    return _firestore.collection(collection).doc(id).update({
      field: FieldValue.increment(amount),
    });
  }
}
