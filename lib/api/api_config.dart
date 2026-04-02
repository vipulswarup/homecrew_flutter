class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static const String apiPrefix = '/api/v1';

  static Uri uri(String route, [Map<String, dynamic>? queryParameters]) {
    final String normalizedRoute = route.startsWith('/') ? route : '/$route';
    final String fullPath = '$apiPrefix$normalizedRoute';
    return Uri.parse(baseUrl).replace(
      path: fullPath,
      queryParameters: queryParameters?.map((k, v) => MapEntry(k, '$v')),
    );
  }
}

