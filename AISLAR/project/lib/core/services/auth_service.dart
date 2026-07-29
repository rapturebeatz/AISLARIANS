import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final _auth = auth.FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Stream<auth.User?> get authStateChanges => _auth.authStateChanges();
  auth.User? get currentUser => _auth.currentUser;

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
    String? phone,
  }) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await result.user!.updateDisplayName(displayName);
    await result.user!.reload();

    final now = DateTime.now();
    final userModel = UserModel(
      uid: result.user!.uid,
      email: email,
      phone: phone,
      displayName: displayName,
      role: 'visitor',
      status: 'pending',
      isApproved: false,
      lastLoginAt: now,
      createdAt: now,
      updatedAt: now,
    );

    await _firestore.collection('users').doc(result.user!.uid).set(userModel.toJson());
    return userModel;
  }

  Future<UserModel> signIn({required String email, required String password}) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final now = DateTime.now();
    await _firestore.collection('users').doc(result.user!.uid).update({
      'lastLoginAt': now,
      'updatedAt': now,
    });
    return _getUserModel(result.user!.uid);
  }

  Future<void> signOut() => _auth.signOut();

  Future<UserModel> _getUserModel(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return UserModel.fromJson(doc.data()!);
  }

  Stream<UserModel> streamUser(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map(
      (doc) => UserModel.fromJson(doc.data()!),
    );
  }

  Future<void> sendPasswordReset(String email) => _auth.sendPasswordResetEmail(email);

  Future<void> updateRole(String uid, String role) async {
    await _firestore.collection('users').doc(uid).update({
      'role': role,
      'updatedAt': DateTime.now(),
    });
  }

  Future<void> approveMember(String uid, String adminUid) async {
    await _firestore.collection('users').doc(uid).update({
      'status': 'active',
      'isApproved': true,
      'approvedBy': adminUid,
      'approvedAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    });
  }

  Future<void> suspendMember(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'status': 'suspended',
      'updatedAt': DateTime.now(),
    });
  }
}
