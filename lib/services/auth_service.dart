import '../api/api_client.dart';
import '../api/token_store.dart';

class AuthService {
  AuthService({required ApiClient api, required TokenStore tokenStore})
      : _api = api,
        _tokenStore = tokenStore;

  final ApiClient _api;
  final TokenStore _tokenStore;

  Future<TokenPair> login({
    required String email,
    required String password,
    String deviceInfo = 'macos',
  }) async {
    final resp = await _api.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
        'device_info': deviceInfo,
      },
      skipAuth: true,
    );

    final data = resp.data;
    final access = data?['access_token']?.toString();
    final refresh = data?['refresh_token']?.toString();
    if (access == null || refresh == null) {
      throw StateError('Login response missing tokens');
    }

    final pair = TokenPair(accessToken: access, refreshToken: refresh);
    await _tokenStore.write(pair);
    return pair;
  }

  Future<void> logout() async {
    final pair = await _tokenStore.read();
    if (pair != null) {
      await _api.post<void>(
        '/auth/logout',
        data: {'refresh_token': pair.refreshToken},
      );
    }
    await _tokenStore.clear();
  }

  Future<void> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    await _api.post<void>(
      '/auth/signup',
      data: {'email': email, 'password': password, 'name': name},
      skipAuth: true,
    );
  }

  Future<void> verifyEmail({required String token}) async {
    await _api.post<void>(
      '/auth/verify-email',
      data: {'token': token},
      skipAuth: true,
    );
  }

  Future<Map<String, dynamic>> me() async {
    final resp = await _api.get<Map<String, dynamic>>('/me');
    final data = resp.data;
    if (data == null) throw StateError('Empty /me response');
    return data;
  }

  static Future<TokenPair> refreshTokens(ApiClient api, String refreshToken) async {
    final resp = await api.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
      skipAuth: true,
      isRefreshCall: true,
    );
    final data = resp.data;
    final access = data?['access_token']?.toString();
    final refresh = data?['refresh_token']?.toString();
    if (access == null || refresh == null) {
      throw StateError('Refresh response missing tokens');
    }
    return TokenPair(accessToken: access, refreshToken: refresh);
  }
}

