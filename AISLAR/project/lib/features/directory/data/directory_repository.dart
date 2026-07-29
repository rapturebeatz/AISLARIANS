import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firestore_service.dart';
import '../../../../models/profile_model.dart';

final directoryRepositoryProvider = Provider<DirectoryRepository>((ref) {
  return DirectoryRepository(ref.read(firestoreServiceProvider));
});

class DirectoryRepository {
  final FirestoreService _firestore;

  DirectoryRepository(this._firestore);

  Stream<List<ProfileModel>> streamAllProfiles() {
    return _firestore
        .streamCollection('profiles', orderByField: 'fullName', descending: false, limit: 200)
        .map((snap) => snap.docs
            .map((doc) => ProfileModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<ProfileModel?> getProfile(String uid) async {
    final doc = await _firestore.get('profiles', uid);
    if (!doc.exists) return null;
    return ProfileModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  Stream<ProfileModel> streamProfile(String uid) {
    return _firestore.streamDoc('profiles', uid).map(
      (doc) => ProfileModel.fromJson(doc.data() as Map<String, dynamic>),
    );
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.update('profiles', uid, data);
  }

  Future<void> createProfile(String uid, ProfileModel profile) async {
    await _firestore.set('profiles', uid, profile.toJson());
  }

  Future<List<ProfileModel>> searchProfiles({
    String? name,
    String? department,
    int? graduationYear,
    String? country,
    String? occupation,
    String? company,
    List<String>? skills,
  }) async {
    var query = _firestore.query('profiles') as Query;

    if (department != null) query = query.where('department', isEqualTo: department);
    if (graduationYear != null) query = query.where('graduationYear', isEqualTo: graduationYear);
    if (country != null) query = query.where('country', isEqualTo: country);
    if (occupation != null) query = query.where('occupation', isEqualTo: occupation);
    if (employer != null) query = query.where('employer', isEqualTo: employer);

    final snap = await query.get();
    var profiles = snap.docs
        .map((doc) => ProfileModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    // Client-side filtering for name/skills (Firestore limitations)
    if (name != null) {
      final lower = name.toLowerCase();
      profiles = profiles.where((p) => p.fullName.toLowerCase().contains(lower)).toList();
    }
    if (skills != null && skills.isNotEmpty) {
      profiles = profiles.where((p) => skills.any((s) => p.skills.contains(s))).toList();
    }

    return profiles;
  }

  Stream<List<ProfileModel>> streamFilteredProfiles({
    String? department,
    int? graduationYear,
    String? country,
  }) {
    var query = _firestore.query('profiles') as Query;
    if (department != null) query = query.where('department', isEqualTo: department);
    if (graduationYear != null) query = query.where('graduationYear', isEqualTo: graduationYear);
    if (country != null) query = query.where('country', isEqualTo: country);

    return query.snapshots().map(
      (snap) => snap.docs
          .map((doc) => ProfileModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList(),
    );
  }
}
