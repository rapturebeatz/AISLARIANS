import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/admin_repository.dart';

final adminStatsProvider = FutureProvider<Map<String, int>>((ref) {
  return ref.read(adminRepositoryProvider).getStats();
});

final pendingMembersProvider = Provider((ref) {
  return ref.read(adminRepositoryProvider).streamPendingMembers();
});

final adminControllerProvider = Provider<AdminController>((ref) {
  return AdminController(ref.read(adminRepositoryProvider), ref);
});

class AdminController {
  final AdminRepository _repository;
  final Ref _ref;

  AdminController(this._repository, this._ref);

  Future<void> approveMember(String uid) async {
    await _repository.approveMember(uid, 'current-admin');
    ref.invalidate(adminStatsProvider);
  }

  Future<void> rejectMember(String uid) async {
    await _repository.rejectMember(uid);
    ref.invalidate(adminStatsProvider);
  }

  Future<void> suspendMember(String uid) async {
    await _repository.suspendMember(uid);
  }

  Future<void> updateRole(String uid, String role) async {
    await _repository.updateMemberRole(uid, role);
  }
}
