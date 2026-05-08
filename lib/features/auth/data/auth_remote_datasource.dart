import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/config/env_config.dart';

class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
}

class AuthRemoteDatasource {
  AuthRemoteDatasource(this._config)
      : _keycloakDio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ));

  final EnvConfig _config;
  final Dio _keycloakDio;

  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _keycloakDio.post(
        _config.tokenUrl,
        data: {
          'grant_type': 'password',
          'client_id': _config.keycloakClientId,
          'username': email,
          'password': password,
          'scope': 'openid',
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final body = response.data as Map<String, dynamic>;
      return AuthTokens(
        accessToken: body['access_token'] as String,
        refreshToken: body['refresh_token'] as String,
        expiresIn: body['expires_in'] as int,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final body = e.response?.data as Map<String, dynamic>?;
        final desc =
            body?['error_description'] as String? ?? 'Invalid credentials.';
        throw ServerException(desc);
      }
      throw mapDioException(e);
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _keycloakDio.post(
        _config.logoutUrl,
        data: {
          'client_id': _config.keycloakClientId,
          'refresh_token': refreshToken,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
    } catch (_) {}
  }

  Map<String, dynamic> decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return {};

    final payload = parts[1];

    final padded = payload
        .padRight((payload.length + 3) & ~3, '=')
        .replaceAll('-', '+')
        .replaceAll('_', '/');

    try {
      final decoded = utf8.decode(base64Decode(padded));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}