// lib/features/auth/data/mock_auth_datasource.dart
//
// Used ONLY when AppEnv.authMock == true.
// Production builds never compile this path.
// Returns a structurally valid JWT payload with correct realm_access.roles.

import 'dart:convert';
import 'auth_remote_datasource.dart';
import '../../../core/network/api_exception.dart';

// A minimal valid JWT structure: header.payload.signature
// The payload is what your app decodes for role/userId.
// Signature is fake — real Keycloak will never see this token.
String _buildMockJwt({
  required String sub,
  required String email,
  required String givenName,
  required String familyName,
  required String role, // 'PATIENT' | 'DOCTOR' | 'ADMIN'
}) {
  const header = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9'; // {"alg":"RS256","typ":"JWT"}

  final payloadMap = {
    'sub': sub,
    'email': email,
    'given_name': givenName,
    'family_name': familyName,
    'realm_access': {
      'roles': [role, 'offline_access', 'uma_authorization'],
    },
    'exp': 4070908800, // Year 2099 — never expires in dev
    'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    'iss': 'http://mock-keycloak/realms/tynysai',
    'preferred_username': email,
  };

  final payloadJson = jsonEncode(payloadMap);
  final payloadBase64 = base64Url
      .encode(utf8.encode(payloadJson))
      .replaceAll('=', ''); // JWT uses unpadded base64url

  const fakeSig = 'MOCK_SIGNATURE_NOT_VALID';
  return '$header.$payloadBase64.$fakeSig';
}

// Mock credentials — these are the only valid logins in mock mode
const _mockAccounts = [
  _MockAccount(
    email: 'patient@tynysai.kz',
    password: 'test1234',
    sub: '00000000-0000-0000-0000-000000000001',
    givenName: 'Aizat',
    familyName: 'Bekova',
    role: 'PATIENT',
  ),
  _MockAccount(
    email: 'doctor@tynysai.kz',
    password: 'test1234',
    sub: '00000000-0000-0000-0000-000000000002',
    givenName: 'Dr. Arman',
    familyName: 'Seitkali',
    role: 'DOCTOR',
  ),
];

class MockAuthDatasource {
  /// Simulates Keycloak login with 300ms network delay.
  /// Throws [ServerException] on wrong credentials — same behavior as real.
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final account = _mockAccounts.where(
      (a) => a.email == email && a.password == password,
    ).firstOrNull;

    if (account == null) {
      throw const ServerException(
        'Invalid email or password.',
      );
    }

    final accessToken = _buildMockJwt(
      sub: account.sub,
      email: account.email,
      givenName: account.givenName,
      familyName: account.familyName,
      role: account.role,
    );

    return AuthTokens(
      accessToken: accessToken,
      refreshToken: 'mock-refresh-token-${account.sub}',
      expiresIn: 3600,
    );
  }

  Future<void> logout(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // No-op in mock — storage is cleared by AuthNotifier
  }
}

class _MockAccount {
  const _MockAccount({
    required this.email,
    required this.password,
    required this.sub,
    required this.givenName,
    required this.familyName,
    required this.role,
  });

  final String email;
  final String password;
  final String sub;
  final String givenName;
  final String familyName;
  final String role;
}