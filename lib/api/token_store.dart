import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenPair {
  const TokenPair({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}

class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';

  final FlutterSecureStorage _storage;

  Future<TokenPair?> read() async {
    final access = await _storage.read(key: _kAccessToken);
    final refresh = await _storage.read(key: _kRefreshToken);
    if (access == null || refresh == null) return null;
    if (access.isEmpty || refresh.isEmpty) return null;
    return TokenPair(accessToken: access, refreshToken: refresh);
  }

  Future<void> write(TokenPair pair) async {
    await _storage.write(key: _kAccessToken, value: pair.accessToken);
    await _storage.write(key: _kRefreshToken, value: pair.refreshToken);
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kRefreshToken);
  }
}

