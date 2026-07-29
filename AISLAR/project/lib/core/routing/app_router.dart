import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'landing',
        builder: (context, state) => const SizedBox(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const SizedBox(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const SizedBox(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const SizedBox(),
      ),
      GoRoute(
        path: '/profile/:id',
        name: 'profile',
        builder: (context, state) => const SizedBox(),
      ),
      GoRoute(
        path: '/directory',
        name: 'directory',
        builder: (context, state) => const SizedBox(),
      ),
      GoRoute(
        path: '/feed',
        name: 'feed',
        builder: (context, state) => const SizedBox(),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const SizedBox(),
      ),
      GoRoute(
        path: '/events',
        name: 'events',
        builder: (context, state) => const SizedBox(),
      ),
      GoRoute(
        path: '/gallery',
        name: 'gallery',
        builder: (context, state) => const SizedBox(),
      ),
      GoRoute(
        path: '/business',
        name: 'business',
        builder: (context, state) => const SizedBox(),
      ),
      GoRoute(
        path: '/jobs',
        name: 'jobs',
        builder: (context, state) => const SizedBox(),
      ),
      GoRoute(
        path: '/library',
        name: 'library',
        builder: (context, state) => const SizedBox(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const SizedBox(),
      ),
    ],
  );
});
