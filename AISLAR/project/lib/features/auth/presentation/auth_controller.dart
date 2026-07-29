import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/auth_service.dart';
import '../../../models/user_model.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

final currentUserProvider = Provider<UserModel?>((ref) => null);

final authLoadingProvider = StateProvider<bool>((ref) => false);

final authErrorProvider = StateProvider<String?>((ref) => null);

final signInProvider = Provider.family<void, SignInParams>((ref, params) {
  throw UnimplementedError('Use authControllerProvider instead');
});

final signUpProvider = Provider.family<void, SignUpParams>((ref, params) {
  throw UnimplementedError('Use authControllerProvider instead');
});

class SignInParams {
  final String email;
  final String password;

  SignInParams({required this.email, required this.password});
}

class SignUpParams {
  final String email;
  final String password;
  final String displayName;
  final String? phone;

  SignUpParams({
    required this.email,
    required this.password,
    required this.displayName,
    this.phone,
  });
}

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref.read(authServiceProvider), ref);
});

class AuthController {
  final AuthService _authService;
  final Ref _ref;

  AuthController(this._authService, this._ref);

  Future<void> signIn(String email, String password) async {
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;
    try {
      await _authService.signIn(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _ref.read(authErrorProvider.notifier).state = _mapFirebaseError(e);
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Future<void> signUp(String email, String password, String displayName, {String? phone}) async {
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;
    try {
      await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
        phone: phone,
      );
    } on FirebaseAuthException catch (e) {
      _ref.read(authErrorProvider.notifier).state = _mapFirebaseError(e);
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'weak-password':
        return 'Password must be at least 6 characters';
      case 'invalid-email':
        return 'Invalid email address';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      default:
        return e.message ?? 'An error occurred';
    }
  }
}
