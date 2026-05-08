// lib/core/config/env_config.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_env.dart';

final envConfigProvider = Provider<EnvConfig>((ref) => EnvConfig.current());

class EnvConfig {
  const EnvConfig({
    required this.gatewayBaseUrl,
    required this.keycloakBaseUrl,
    required this.keycloakRealm,
    required this.keycloakClientId,
    required this.useMockAuth,
  });

  final String gatewayBaseUrl;
  final String keycloakBaseUrl;
  final String keycloakRealm;
  final String keycloakClientId;
  final bool useMockAuth;

  // Derived URLs — same structure as real Keycloak
  String get tokenUrl =>
      '$keycloakBaseUrl/realms/$keycloakRealm/protocol/openid-connect/token';
  String get logoutUrl =>
      '$keycloakBaseUrl/realms/$keycloakRealm/protocol/openid-connect/logout';

  factory EnvConfig.current() {
    return const EnvConfig(
      gatewayBaseUrl: AppEnv.gatewayBaseUrl,
      keycloakBaseUrl: AppEnv.keycloakBaseUrl,
      keycloakRealm: 'tynysai',
      keycloakClientId: 'tynysai-frontend',
      useMockAuth: AppEnv.authMock,
    );
  }
}