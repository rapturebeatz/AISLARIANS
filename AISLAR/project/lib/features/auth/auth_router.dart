import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/auth_service.dart';
import '../../../models/user_model.dart';
import '../presentation/login_screen.dart';
import '../presentation/register_screen.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../admin/presentation/pending_approval_screen.dart';

final authRouterProvider = Provider<Widget>((ref) {
  final authState = ref.watch(authStateProvider);
  final authService = ref.watch(authServiceProvider);

  return authState.when(
    data: (user) {
      if (user == null) return const LoginScreen();
      return StreamBuilder<UserModel>(
        stream: authService.streamUser(user.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
          final userModel = snapshot.data!;
          if (userModel.status == 'pending') return const PendingApprovalScreen();
          if (userModel.status == 'suspended') return const SuspendedScreen();
          return const DashboardScreen();
        },
      );
    },
    loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
    error: (_, __) => const LoginScreen(),
  );
});
