import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../config/env_config.dart';
import '../storage/secure_storage.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  final config = ref.watch(envConfigProvider);    // ← was AppConstants
  final storage = ref.watch(secureStorageProvider);
  return DioClient(config, storage);
});

class DioClient {
  DioClient(this._config, this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: _config.gatewayBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          // Global mock delay: all endpoints respond in ~500ms.
          // The mock server reads this header and delays its response.
          // In production the real backend ignores unknown headers — safe to leave.
          'x-mock-response-delay': '500',
        },
      ),
    );
    _dio.interceptors.add(_AuthInterceptor(_storage, _config, _dio));
  }

   late final Dio _dio;
   final EnvConfig _config;
   final SecureStorageService _storage;

   Dio get instance => _dio;
}

/// Interceptor that:
/// 1. Attaches the Bearer access token to every request.
/// 2. On 401, attempts one token refresh, then retries.
/// 3. On second 401, clears storage (forces re-login via router guard).
/// 

class _AuthInterceptor extends QueuedInterceptor {
  _AuthInterceptor(this._storage, this._config, this._dio);

  final SecureStorageService _storage;
  final EnvConfig _config;
  final Dio _dio;

  // Separate Dio instance for token refresh to avoid interceptor loops.
  late final Dio _refreshDio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final stored = await _storage.getTokens();
    if (stored == null) {
      return handler.next(options);
    }

    String accessToken = stored.accessToken;

    // Proactively refresh if token expires within 30 seconds.
    if (_storage.isTokenExpiredOrExpiringSoon(stored.expiresAt)) {
      final refreshed = await _tryRefresh(stored.refreshToken);
      if (refreshed != null) {
        accessToken = refreshed;
      } else {
        await _storage.clearTokens();
        return handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.unknown,
            error: 'Session expired',
          ),
        );
      }
    }

    options.headers['Authorization'] = 'Bearer $accessToken';
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final isRetry = options.extra['_retry'] == true;

    if (err.response?.statusCode == 401 && !isRetry) {
      final stored = await _storage.getTokens();
      if (stored != null) {
        final newToken = await _tryRefresh(stored.refreshToken);
        if (newToken != null) {
          options.extra['_retry'] = true;
          options.headers['Authorization'] = 'Bearer $newToken';
          try {
            final response = await _dio.fetch(options);
            return handler.resolve(response);
          } catch (e) {
            // fall through to clearTokens
          }
        }
      }
      await _storage.clearTokens();
    }

    return handler.next(err);
  }

  /// Returns the new access token on success, null on failure.
  Future<String?> _tryRefresh(String refreshToken) async {
    try {
      final response = await _refreshDio.post(
        _config.tokenUrl,
        data: {
          'grant_type': 'refresh_token',
          'client_id': _config.keycloakClientId,
          'refresh_token': refreshToken,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      final body = response.data as Map<String, dynamic>;
      final newAccess = body['access_token'] as String;
      final newRefresh = body['refresh_token'] as String;
      final expiresIn = body['expires_in'] as int;

      await _storage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
        expiresIn: expiresIn,
      );

      return newAccess;
    } catch (_) {
      return null;
    }
  }
}