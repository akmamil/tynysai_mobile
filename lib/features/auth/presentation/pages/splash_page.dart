// lib/features/auth/presentation/pages/splash_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SplashPage
//
// Responsibilities:
//   1. Show the branded splash UI while auth state is being determined.
//   2. Call checkAuthStatus() exactly once, on first frame.
//
// What SplashPage does NOT do:
//   - Navigate. The GoRouter redirect handles all navigation automatically
//     when authProvider state changes. Having both SplashPage AND the router
//     navigate creates a race condition where two context.go() calls fight
//     each other and the last one wins unpredictably.
//
// Why addPostFrameCallback instead of initState directly:
//   - checkAuthStatus() calls setState on a Riverpod notifier.
//   - Calling it during the first frame (before the widget tree is laid out)
//     is safe, but using addPostFrameCallback guarantees the widget is fully
//     mounted and the Riverpod ref is active before we touch state.
// ─────────────────────────────────────────────────────────────────────────────
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Trigger auth check once, after the first frame.
    // GoRouter's redirect will handle navigation once state settles.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(authProvider.notifier).checkAuthStatus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ── DO NOT put ref.listen or context.go() here. ──────────────────────────
    // The router's redirect function already watches authProvider via
    // RouterNotifier and navigates automatically. Adding navigation here
    // creates a second navigation system fighting the router:
    //
    //   Frame N:   authProvider → AuthAuthenticated
    //   Frame N+1: RouterNotifier.notifyListeners() → GoRouter redirect → '/home'
    //   Frame N+1: ref.listen fires → context.go('/home') ← duplicate, races
    //
    // The ref.listen in a page widget fires AFTER the router redirect, so the
    // router has already navigated away and context.go() is called on a widget
    // that is being disposed — sometimes causing "Navigator already has route"
    // errors or a second push onto an already-correct stack.
    // ─────────────────────────────────────────────────────────────────────────

    return Scaffold(
      backgroundColor: const Color(0xFF1A73E8),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'TynysAI',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'AI-Powered Lung Analysis',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
