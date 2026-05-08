import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/constants/api_paths.dart';
import '../../../../core/models/enums.dart';
import '../../../../core/models/user.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/auth_remote_datasource.dart';
import '../../data/mock_auth_datasource.dart';
import '../../domain/auth_state.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(envConfigProvider),
    ref.watch(secureStorageProvider),
    ref.watch(dioClientProvider),
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// AuthNotifier
//
// State machine with 5 states:
//
//   AuthInitial       → App just launched, auth status unknown
//   AuthLoading       → Async operation in progress (login / status check)
//   AuthAuthenticated → Valid session. Carries AuthUser.
//   AuthUnauthenticated → No session. Router redirects to /login.
//   AuthError         → Login failed. Carries error message.
//
// State transitions:
//
//   AuthInitial
//     └─ checkAuthStatus() ──► AuthLoading ──► AuthAuthenticated (tokens valid)
//                                          └─► AuthUnauthenticated (no tokens)
//
//   AuthUnauthenticated
//     └─ login() ────────────► AuthLoading ──► AuthAuthenticated (success)
//                                          └─► AuthError (bad credentials)
//
//   AuthAuthenticated
//     └─ logout() ───────────────────────────► AuthUnauthenticated
//     └─ refreshUser() ──────────────────────► AuthAuthenticated (updated user)
//
//   AuthError
//     └─ clearError() ───────────────────────► AuthUnauthenticated
// ─────────────────────────────────────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._config, this._storage, this._dioClient)
      : super(const AuthInitial());

  final EnvConfig _config;
  final SecureStorageService _storage;
  final DioClient _dioClient;

  // The ONLY two allowed mock divergence points (per architecture rules):
  // 1. Auth datasource selection — here.
  // 2. XrayRemoteDatasource upload + getXrayById — in xray feature.
  late final AuthRemoteDatasource _realAuth = AuthRemoteDatasource(_config);
  late final MockAuthDatasource _mockAuth = MockAuthDatasource();

  // ── checkAuthStatus ────────────────────────────────────────────────────────
  // Called once by SplashPage on first frame.
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> checkAuthStatus() async {
    if (state is AuthAuthenticated) return;

    state = const AuthLoading();

    final stored = await _storage.getTokens();

    if (stored == null) {
      state = const AuthUnauthenticated();
      return;
    }

    try {
      final user = await _resolveCurrentUser();
      state = AuthAuthenticated(user);
    } catch (_) {
      await _storage.clearTokens();
      state = const AuthUnauthenticated();
    }
  }

  // ── login ──────────────────────────────────────────────────────────────────
  Future<void> login({required String email, required String password}) async {
    if (state is AuthLoading || state is AuthAuthenticated) return;

    state = const AuthLoading();

    try {
      final AuthTokens tokens;
      if (_config.useMockAuth) {
        tokens = await _mockAuth.login(email: email, password: password);
      } else {
        tokens = await _realAuth.login(email: email, password: password);
      }

      // Tokens MUST be persisted before _resolveCurrentUser() because the
      // DioClient interceptor reads from storage to attach the Bearer header.
      await _storage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        expiresIn: tokens.expiresIn,
      );

      final user = await _resolveCurrentUser();
      state = AuthAuthenticated(user);
    } on ApiException catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError('Unexpected error: ${e.toString()}');
    }
  }

  // ── logout ─────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    final refreshToken = await _storage.getRefreshToken();

    // Clear local tokens first — the user is logged out regardless of server response.
    await _storage.clearTokens();

    if (refreshToken != null) {
      if (_config.useMockAuth) {
        await _mockAuth.logout(refreshToken);
      } else {
        await _realAuth.logout(refreshToken);
      }
    }

    state = const AuthUnauthenticated();
  }

  // ── refreshUser ────────────────────────────────────────────────────────────
  // Called by ProfileNotifier after a successful profile update so the
  // AppBar / home screen reflects the new name/avatar without a full re-login.
  void refreshUser(AuthUser updated) {
    if (state is AuthAuthenticated) {
      state = AuthAuthenticated(updated);
    }
  }

  // ── clearError ────────────────────────────────────────────────────────────
  void clearError() {
    if (state is AuthError) state = const AuthUnauthenticated();
  }

  // ── _resolveCurrentUser ───────────────────────────────────────────────────
  //
  // MOCK MODE:
  //   Decodes the stored mock JWT to extract the actual role, sub, email,
  //   and name. This means logging in as doctor@tynysai.kz correctly returns
  //   UserRole.doctor — not the hardcoded patient that broke role-based routing.
  //
  //   decodeJwtPayload() is a pure string operation (no network call), so
  //   using _realAuth here is safe even in mock mode.
  //
  // PRODUCTION MODE:
  //   Calls GET /api/users/me through the gateway. The DioClient interceptor
  //   attaches the Bearer token automatically. This call also auto-provisions
  //   the user record in the backend DB on first login.
  // ─────────────────────────────────────────────────────────────────────────
Future<AuthUser> _resolveCurrentUser() async {
    if (_config.useMockAuth) {
      final token = await _storage.getAccessToken();
      if (token != null) {
        final payload = _realAuth.decodeJwtPayload(token);
        final roles = (payload['realm_access']?['roles'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        final role = userRoleFromRealmRoles(roles);
        final sub = payload['sub'] as String? ?? '';
        final email = payload['preferred_username'] as String? ?? '';
        final fullName =
            '${payload['given_name'] ?? ''} ${payload['family_name'] ?? ''}'
                .trim();
        return AuthUser(
          id: sub,
          email: email,
          fullName: fullName.isEmpty ? email : fullName,
          role: role,
          avatarPath: null,
        );
      }
      // Fallback: token unreadable — return hardcoded mock identity.
      return const AuthUser(
        id: '00000000-0000-0000-0000-000000000001',
        email: 'patient@tynysai.kz',
        fullName: 'Aizat Bekova',
        role: UserRole.patient,
        avatarPath: null,
      );
    }

    // Production: GET /api/users/me
    // DioClient interceptor attaches Bearer token automatically.
    // This call also auto-provisions the user in the backend DB on first login.
    final response = await _dioClient.instance.get(ApiPaths.getMe);
    final body = response.data as Map<String, dynamic>;
    final appUser = AppUser.fromJson(body['data'] as Map<String, dynamic>);

    return AuthUser(
      id: appUser.id,
      email: appUser.email,
      fullName: appUser.fullName,
      role: appUser.role,
      avatarPath: appUser.avatarPath,
    );
  }
  }