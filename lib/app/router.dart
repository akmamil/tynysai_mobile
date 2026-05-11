// lib/app/router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/domain/auth_state.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/notifications/presentation/pages/notifications_page.dart';
import '../features/profile/presentation/pages/edit_profile_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/reports/presentation/pages/report_detail_page.dart';
import '../features/reports/presentation/pages/reports_page.dart';
import '../features/xray/presentation/pages/upload_xray_page.dart';
import '../features/xray/presentation/pages/xray_history_page.dart';
import '../features/xray/presentation/pages/xray_result_page.dart';
import '../features/auth/presentation/pages/register.dart';
import '../features/appointments/presentation/pages/appointments_page.dart';
import '../features/appointments/presentation/pages/appointment_detail_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RouterNotifier
// ─────────────────────────────────────────────────────────────────────────────
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
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

    if (isInitializing) return isOnSplash ? null : '/';

    // ── SAFE role redirect ────────────────────────────────────────────────
    // All roles land on /home. Role-specific content is rendered inside
    // HomePage via user.role. This prevents a GoException for missing
    // /doctor/home and /admin/home routes until those are built.
    if (isAuthenticated && (isOnSplash || isOnAuthRoute)) return '/home';

    if (!isAuthenticated && !isOnAuthRoute) return '/login';
    return null;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
      GoRoute(path: '/home', builder: (_, __) => const HomePage()),

      // ── X-Ray feature ──────────────────────────────────────────────────
      GoRoute(path: '/xray/upload', builder: (_, __) => const UploadXrayPage()),
      GoRoute(
        path: '/xray/:id',
        builder: (_, state) {
          final id = int.parse(state.pathParameters['id']!);
          return XrayResultPage(xrayId: id);
        },
      ),
      GoRoute(path: '/history', builder: (_, __) => const XrayHistoryPage()),

      // ── Reports ────────────────────────────────────────────────────────
      GoRoute(path: '/reports', builder: (_, __) => const ReportsPage()),
      GoRoute(
        path: '/reports/:id',
        builder: (_, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ReportDetailPage(reportId: id);
        },
      ),

      // ── Profile ────────────────────────────────────────────────────────
      GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
      GoRoute(
          path: '/profile/edit', builder: (_, __) => const EditProfilePage()),

      // ── Appointments ────────────────────────────────────────────────────
      GoRoute(
          path: '/appointments',
          builder: (_, __) => const AppointmentsPage()),
      GoRoute(
        path: '/appointments/:id',
        builder: (_, state) {
          final id = int.parse(state.pathParameters['id']!);
          return AppointmentDetailPage(appointmentId: id);
        },
      ),

      // ── Notifications ──────────────────────────────────────────────────
      GoRoute(
          path: '/notifications',
          builder: (_, __) => const NotificationsPage()),
    ],
  );
});