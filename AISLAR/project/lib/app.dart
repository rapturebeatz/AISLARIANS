import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_router.dart';

class AislarConnectApp extends ConsumerWidget {
  const AislarConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(authRouterProvider);
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: home,
      debugShowCheckedModeBanner: false,
    );
  }
}
