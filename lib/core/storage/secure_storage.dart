import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

class SecureStorageService {
  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        );

  final FlutterSecureStorage _storage;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {
    final expiresAt =
        DateTime.now().millisecondsSinceEpoch ~/ 1000 + expiresIn;
    await Future.wait([
      _storage.write(key: AppConstants.kAccessToken, value: accessToken),
      _storage.write(key: AppConstants.kRefreshToken, value: refreshToken),
      _storage.write(
          key: AppConstants.kTokenExpiresAt, value: expiresAt.toString()),
    ]);
  }

  Future<StoredTokens?> getTokens() async {
    final results = await Future.wait([
      _storage.read(key: AppConstants.kAccessToken),
      _storage.read(key: AppConstants.kRefreshToken),
      _storage.read(key: AppConstants.kTokenExpiresAt),
    ]);

    final access = results[0];
    final refresh = results[1];
    final expiresAtStr = results[2];

    if (access == null || refresh == null || expiresAtStr == null) return null;

    return StoredTokens(
      accessToken: access,
      refreshToken: refresh,
      expiresAt: int.tryParse(expiresAtStr) ?? 0,
    );
  }

  Future<String?> getAccessToken() =>
      _storage.read(key: AppConstants.kAccessToken);

  Future<String?> getRefreshToken() =>
      _storage.read(key: AppConstants.kRefreshToken);

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: AppConstants.kAccessToken),
      _storage.delete(key: AppConstants.kRefreshToken),
      _storage.delete(key: AppConstants.kTokenExpiresAt),
    ]);
  }

  bool isTokenExpiredOrExpiringSoon(int expiresAt) {
    final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return expiresAt - 30 <= nowSeconds; // refresh if expires within 30s
  }
}

class StoredTokens {
  const StoredTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresAt; // Unix seconds
}