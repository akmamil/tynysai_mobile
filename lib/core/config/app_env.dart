// lib/core/config/app_env.dart
//
// Values are injected at build time via --dart-define flags.
// Never hardcode URLs here. These are the only place environment differs.
//
// Run mock build:
//   flutter run --dart-define=ENV=mock \
//               --dart-define=GATEWAY_URL=https://your-postman-mock.pstmn.io \
//               --dart-define=KEYCLOAK_URL=https://your-postman-mock.pstmn.io \
//               --dart-define=AUTH_MOCK=true
//
// Run real build:
//   flutter run --dart-define=ENV=production \
//               --dart-define=GATEWAY_URL=http://192.168.1.100:8072 \
//               --dart-define=KEYCLOAK_URL=http://192.168.1.100:7080 \
//               --dart-define=AUTH_MOCK=false

abstract final class AppEnv {
  // Which environment are we in?
  static const String env =
      String.fromEnvironment('ENV', defaultValue: 'mock');

  // All traffic goes here (gateway in prod, postman mock in dev)
  static const String gatewayBaseUrl = String.fromEnvironment(
    'GATEWAY_URL',
    defaultValue: 'https://024354f0-4c9e-4389-ac59-8b9c625cb9cb.mock.pstmn.io',
  );

  // Keycloak token endpoint base (in mock, this is also Postman)
  static const String keycloakBaseUrl = String.fromEnvironment(
    'KEYCLOAK_URL',
    defaultValue: 'https://024354f0-4c9e-4389-ac59-8b9c625cb9cb.mock.pstmn.io',
  );

  // When true, auth datasource uses MockAuthDatasource instead of real Keycloak
  static const bool authMock =
      bool.fromEnvironment('AUTH_MOCK', defaultValue: true);

  static bool get isMock => env == 'mock';
  static bool get isProduction => env == 'production';
}