class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? code;

  const ApiException({
    required this.statusCode,
    required this.message,
    this.code,
  });

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isRateLimited => statusCode == 429;
  bool get isServerError => statusCode >= 500;
  bool get isNetworkError => statusCode == 0;

  @override
  String toString() => 'ApiException($statusCode, code=$code): $message';
}
