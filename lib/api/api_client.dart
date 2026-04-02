import 'dart:async';

import 'package:dio/dio.dart';

import 'api_config.dart';
import 'api_exception.dart';
import 'token_store.dart';

typedef RefreshFn = Future<TokenPair> Function(String refreshToken);

class ApiClient {
  ApiClient({
    required TokenStore tokenStore,
    required RefreshFn refresh,
    Dio? dio,
  })  : _tokenStore = tokenStore,
        _refresh = refresh,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 30),
                sendTimeout: const Duration(seconds: 30),
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.extra[_kSkipAuth] == true) {
            return handler.next(options);
          }

          final pair = await _tokenStore.read();
          if (pair != null) {
            options.headers['Authorization'] = 'Bearer ${pair.accessToken}';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final status = error.response?.statusCode;
          final requestOptions = error.requestOptions;

          final bool isUnauthorized = status == 401;
          final bool alreadyRetried = requestOptions.extra[_kRetried] == true;
          final bool skipAuth = requestOptions.extra[_kSkipAuth] == true;
          final bool isRefreshCall =
              requestOptions.extra[_kIsRefreshCall] == true ||
              requestOptions.path.endsWith('/auth/refresh');

          if (!isUnauthorized || alreadyRetried || skipAuth || isRefreshCall) {
            return handler.next(error);
          }

          final pair = await _tokenStore.read();
          if (pair == null) {
            return handler.next(error);
          }

          try {
            await _refreshSingleFlight(pair.refreshToken);
          } catch (_) {
            return handler.next(error);
          }

          final updated = await _tokenStore.read();
          if (updated == null) {
            return handler.next(error);
          }

          final retryOptions = _cloneOptions(requestOptions);
          retryOptions.extra[_kRetried] = true;
          retryOptions.headers['Authorization'] = 'Bearer ${updated.accessToken}';

          try {
            final response = await _dio.fetch<dynamic>(retryOptions);
            return handler.resolve(response);
          } on DioException catch (e) {
            return handler.next(e);
          }
        },
      ),
    );
  }

  static const String _kSkipAuth = 'skipAuth';
  static const String _kRetried = 'retried';
  static const String _kIsRefreshCall = 'isRefreshCall';

  final Dio _dio;
  final TokenStore _tokenStore;
  final RefreshFn _refresh;
  Future<void>? _refreshing;

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String route, {
    Map<String, dynamic>? queryParameters,
    bool skipAuth = false,
  }) {
    return _dio.get<T>(
      ApiConfig.uri(route, queryParameters).toString(),
      options: Options(extra: {_kSkipAuth: skipAuth}),
    );
  }

  Future<Response<T>> post<T>(
    String route, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool skipAuth = false,
    bool isRefreshCall = false,
  }) {
    return _dio.post<T>(
      ApiConfig.uri(route, queryParameters).toString(),
      data: data,
      options: Options(
        extra: {
          _kSkipAuth: skipAuth,
          _kIsRefreshCall: isRefreshCall,
        },
      ),
    );
  }

  Future<Response<T>> patch<T>(
    String route, {
    Object? data,
    bool skipAuth = false,
  }) {
    return _dio.patch<T>(
      ApiConfig.uri(route).toString(),
      data: data,
      options: Options(extra: {_kSkipAuth: skipAuth}),
    );
  }

  Future<Response<T>> delete<T>(
    String route, {
    Object? data,
    bool skipAuth = false,
  }) {
    return _dio.delete<T>(
      ApiConfig.uri(route).toString(),
      data: data,
      options: Options(extra: {_kSkipAuth: skipAuth}),
    );
  }

  Future<void> _refreshSingleFlight(String refreshToken) async {
    if (_refreshing != null) return _refreshing;
    final completer = Completer<void>();
    _refreshing = completer.future;
    try {
      final newPair = await _refresh(refreshToken);
      await _tokenStore.write(newPair);
      completer.complete();
    } catch (e) {
      await _tokenStore.clear();
      completer.completeError(e);
    } finally {
      _refreshing = null;
    }
  }

  static RequestOptions _cloneOptions(RequestOptions requestOptions) {
    return RequestOptions(
      path: requestOptions.path,
      method: requestOptions.method,
      headers: Map<String, dynamic>.from(requestOptions.headers),
      queryParameters: Map<String, dynamic>.from(requestOptions.queryParameters),
      data: requestOptions.data,
      extra: Map<String, dynamic>.from(requestOptions.extra),
      baseUrl: requestOptions.baseUrl,
      connectTimeout: requestOptions.connectTimeout,
      sendTimeout: requestOptions.sendTimeout,
      receiveTimeout: requestOptions.receiveTimeout,
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
      validateStatus: requestOptions.validateStatus,
      receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
      followRedirects: requestOptions.followRedirects,
      maxRedirects: requestOptions.maxRedirects,
      requestEncoder: requestOptions.requestEncoder,
      responseDecoder: requestOptions.responseDecoder,
      listFormat: requestOptions.listFormat,
    );
  }

  static ApiException toApiException(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    final detail = (data is Map<String, dynamic>) ? data['detail'] : null;
    final message = detail?.toString() ?? e.message ?? 'Request failed';
    return ApiException(message, statusCode: status, detail: data);
  }
}

