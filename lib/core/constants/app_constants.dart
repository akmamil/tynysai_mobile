class AppConstants {
  AppConstants._();

  // ── Network ──────────────────────────────────────────
  // Change these when deploying. Use 10.0.2.2 for Android emulator localhost.
  static const String gatewayBaseUrl = 'http://10.0.2.2:8072';
  static const String keycloakBaseUrl = 'http://10.0.2.2:7080';
  static const String keycloakRealm = 'tynysai';
  static const String keycloakClientId = 'tynysai-frontend';

  // ── Keycloak Endpoints (called DIRECTLY, not through gateway) ──
  static String get tokenUrl =>
      '$keycloakBaseUrl/realms/$keycloakRealm/protocol/openid-connect/token';
  static String get logoutUrl =>
      '$keycloakBaseUrl/realms/$keycloakRealm/protocol/openid-connect/logout';

  // ── Secure Storage Keys ──────────────────────────────
  static const String kAccessToken = 'tynysai.access_token';
  static const String kRefreshToken = 'tynysai.refresh_token';
  static const String kTokenExpiresAt = 'tynysai.token_expires_at';

  // ── Upload Limits ─────────────────────────────────────
  static const int maxXrayFileSizeBytes = 20 * 1024 * 1024; // 20MB
  static const int maxAvatarFileSizeBytes = 5 * 1024 * 1024; // 5MB

  // ── Polling ───────────────────────────────────────────
  static const Duration xrayPollingInterval = Duration(seconds: 4);
  static const int xrayPollingMaxAttempts = 15; // ~60 seconds total
}