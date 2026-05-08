// lib/app/router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/domain/auth_state.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/xray/presentation/pages/upload_xray_page.dart';
import '../features/xray/presentation/pages/xray_result_page.dart';
import '../features/xray/presentation/pages/xray_history_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/profile/presentation/pages/edit_profile_page.dart'; // ← ADDED
import '../features/notifications/presentation/pages/notifications_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RouterNotifier
//
// Bridges Riverpod's authProvider to GoRouter's ChangeNotifier system.
//
// WHY THIS EXISTS:
// GoRouter.refreshListenable accepts a ChangeNotifier. When notifyListeners()
// is called, GoRouter re-evaluates its redirect function — WITHOUT recreating
// the router or resetting the navigation stack.
//
// The previous pattern (ref.watch inside Provider<GoRouter>) was wrong because
// ref.watch causes the entire Provider to be invalidated and re-run, creating
// a brand new GoRouter instance on every auth state change. A new GoRouter
// always starts at initialLocation, which triggered SplashPage.initState()
// mid-login, which called checkAuthStatus() and reset the auth state.
// ─────────────────────────────────────────────────────────────────────────────
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authProvider,
      (_, __) => notifyListeners(),
    );
  }

  final Ref _ref;

  AuthState get _authState => _ref.read(authProvider);

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _authState;
    final loc = state.matchedLocation;

    final isAuthenticated = authState is AuthAuthenticated;
    final isInitializing =
        authState is AuthInitial || authState is AuthLoading;

    final isOnSplash = loc == '/';
    final isOnAuthRoute = loc == '/login' || loc == '/register';

    if (isInitializing) {
      return isOnSplash ? null : '/';
    }

    if (isAuthenticated && (isOnSplash || isOnAuthRoute)) {
      return '/home';
    }

    if (!isAuthenticated && !isOnAuthRoute) {
      return '/login';
    }

    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// routerProvider
//
// CRITICAL: This Provider creates GoRouter ONCE and never recreates it.
// Auth state changes only trigger redirect re-evaluation via refreshListenable.
// ─────────────────────────────────────────────────────────────────────────────
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      // ── Auth ──────────────────────────────────────────────────────────────
      GoRoute(
        path: '/',
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginPage(),
      ),

      // ── Main ──────────────────────────────────────────────────────────────
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomePage(),
      ),

      // ── X-Ray feature ─────────────────────────────────────────────────────
      //
      // Navigation pattern:
      //   /home → push('/xray/upload') → upload completes → go('/xray/:id')
      //   /history → push('/xray/:id') [back button returns to history]
      //
      // Use context.push() for xray/upload and xray/:id so the back button
      // returns to the calling page. Use context.go() for /home and /history
      // since those are top-level destinations.
      GoRoute(
        path: '/xray/upload',
        builder: (_, __) => const UploadXrayPage(),
      ),
      GoRoute(
        path: '/xray/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return XrayResultPage(xrayId: id);
        },
      ),
      GoRoute(
        path: '/history',
        builder: (_, __) => const XrayHistoryPage(),
      ),

      // ── Profile ───────────────────────────────────────────────────────────
      GoRoute(
        path: '/profile',
        builder: (_, __) => const ProfilePage(),
      ),
      // ── ADDED: edit profile route ─────────────────────────────────────────
      // Reached via context.push('/profile/edit') from ProfilePage AppBar.
      // On save, invalidates patientProfileProvider and pops back to /profile.
      GoRoute(
        path: '/profile/edit',
        builder: (_, __) => const EditProfilePage(),
      ),

      // ── Notifications ─────────────────────────────────────────────────────
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationsPage(),
      ),
    ],
  );
});