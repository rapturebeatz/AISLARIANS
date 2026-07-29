import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firestore_service.dart';
import '../../../../models/feature_models.dart';

final donationsRepositoryProvider = Provider<DonationsRepository>((ref) {
  return DonationsRepository(ref.read(firestoreServiceProvider));
});

class DonationsRepository {
  final FirestoreService _firestore;

  DonationsRepository(this._firestore);

  Stream<List<DonationModel>> streamDonations({String? fundType}) {
    if (fundType != null) {
      return _firestore
          .streamWhere('donations', 'fundType', fundType, orderByField: 'createdAt', descending: true)
          .map((snap) => snap.docs
              .map((doc) => DonationModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
              .toList());
    }
    return _firestore
        .streamCollection('donations', orderByField: 'createdAt', descending: true)
        .map((snap) => snap.docs
            .map((doc) => DonationModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<String> createDonation(DonationModel donation) async {
    final docRef = await _firestore.create('donations', donation.toJson());
    return docRef.id;
  }
}
