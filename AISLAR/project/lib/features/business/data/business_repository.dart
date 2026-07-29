import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firestore_service.dart';
import '../../../../models/business_job_model.dart';

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  return BusinessRepository(ref.read(firestoreServiceProvider));
});

class BusinessRepository {
  final FirestoreService _firestore;

  BusinessRepository(this._firestore);

  Stream<List<BusinessModel>> streamBusinesses({String? category}) {
    if (category != null) {
      return _firestore
          .streamWhere('businesses', 'category', category, orderByField: 'createdAt', descending: true)
          .map((snap) => snap.docs
              .map((doc) => BusinessModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
              .toList());
    }
    return _firestore
        .streamCollection('businesses', orderByField: 'createdAt', descending: true)
        .map((snap) => snap.docs
            .map((doc) => BusinessModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Stream<List<JobModel>> streamJobs({String? category}) {
    if (category != null) {
      return _firestore
          .streamWhere('jobs', 'category', category, orderByField: 'createdAt', descending: true)
          .map((snap) => snap.docs
              .map((doc) => JobModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
              .toList());
    }
    return _firestore
        .streamCollection('jobs', orderByField: 'createdAt', descending: true)
        .map((snap) => snap.docs
            .map((doc) => JobModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<String> createBusiness(BusinessModel business) async {
    final docRef = await _firestore.create('businesses', business.toJson());
    return docRef.id;
  }

  Future<String> createJob(JobModel job) async {
    final docRef = await _firestore.create('jobs', job.toJson());
    return docRef.id;
  }
}
