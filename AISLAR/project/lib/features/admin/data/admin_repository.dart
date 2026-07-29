import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firestore_service.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.read(firestoreServiceProvider));
});

class AdminRepository {
  final FirestoreService _firestore;

  AdminRepository(this._firestore);

  Stream<QuerySnapshot> streamPendingMembers() {
    return _firestore.streamWhere('users', 'status', 'pending');
  }

  Stream<QuerySnapshot> streamAllMembers() {
    return _firestore.streamCollection('users', orderByField: 'createdAt', descending: true);
  }

  Future<void> approveMember(String uid, String adminUid) async {
    await _firestore.update('users', uid, {
      'status': 'active',
      'isApproved': true,
      'approvedBy': adminUid,
      'approvedAt': Timestamp.now(),
    });
  }

  Future<void> rejectMember(String uid) async {
    await _firestore.update('users', uid, {
      'status': 'rejected',
    });
  }

  Future<void> suspendMember(String uid) async {
    await _firestore.update('users', uid, {
      'status': 'suspended',
    });
  }

  Future<void> updateMemberRole(String uid, String role) async {
    await _firestore.update('users', uid, {'role': role});
  }

  Future<Map<String, int>> getStats() async {
    final users = await _firestore.getAll('users');
    final posts = await _firestore.getAll('posts');
    final events = await _firestore.getAll('events');

    return {
      'totalMembers': users.length,
      'totalPosts': posts.length,
      'totalEvents': events.length,
      'pendingApprovals': users.where((d) => (d.data() as Map)['status'] == 'pending').length,
    };
  }
}
