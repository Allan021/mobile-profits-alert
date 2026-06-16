import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_endpoints.dart';
import 'api_exception.dart';

class ApiClient {
  static const _tokenKey = 'pa_auth_token';

  late final Dio _dio;
  String? _cachedToken;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: kApiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      validateStatus: (_) => true,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        if (kDebugMode) {
          final hasToken = token != null;
          debugPrint('[API] ${options.method} ${options.uri} | auth=${hasToken ? "bearer" : "none"}');
          if (options.data != null) debugPrint('[API] body=${options.data}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          final sc = response.statusCode;
          final path = response.requestOptions.path;
          final dataPreview = _previewData(response.data);
          debugPrint('[API] $sc ${response.requestOptions.method} $path | $dataPreview');
        }
        return handler.next(response);
      },
      onError: (err, handler) {
        if (kDebugMode) {
          debugPrint('[API] ERR ${err.requestOptions.method} ${err.requestOptions.path} | ${err.message}');
          if (err.response != null) {
            debugPrint('[API] ERR response=${_previewData(err.response!.data)}');
          }
        }
        return handler.next(err);
      },
    ));
  }

  static String _previewData(dynamic data) {
    if (data == null) return 'null';
    final s = data.toString();
    return s.length > 300 ? '${s.substring(0, 300)}…' : s;
  }

  Future<String?> _getToken() async {
    if (_cachedToken != null) return _cachedToken;
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(_tokenKey);
    return _cachedToken;
  }

  Future<void> setToken(String token) async {
    _cachedToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    _cachedToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<bool> hasToken() async {
    final t = await _getToken();
    return t != null && t.isNotEmpty;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? params,
  }) async {
    try {
      final resp = await _dio.get(path, queryParameters: params);
      return _handleResponse(resp);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final resp = await _dio.post(path, data: data);
      return _handleResponse(resp);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final resp = await _dio.delete(path, data: data);
      return _handleResponse(resp);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Map<String, dynamic> _handleResponse(Response resp) {
    final body = resp.data;
    if (resp.statusCode != null && resp.statusCode! >= 400) {
      throw ApiException(
        statusCode: resp.statusCode!,
        message: _extractMessage(body),
        code: _extractCode(body),
      );
    }
    if (body is Map<String, dynamic>) return body;
    return {'ok': true};
  }

  ApiException _fromDio(DioException e) {
    final resp = e.response;
    if (resp != null) {
      return ApiException(
        statusCode: resp.statusCode ?? 0,
        message: _extractMessage(resp.data),
        code: _extractCode(resp.data),
      );
    }
    return ApiException(
      statusCode: 0,
      message: e.message ?? 'Network error',
    );
  }

  String _extractMessage(dynamic data) {
    if (data is Map) {
      return data['error']?.toString() ??
          data['message']?.toString() ??
          'Unknown error';
    }
    return data?.toString() ?? 'Unknown error';
  }

  String? _extractCode(dynamic data) {
    if (data is Map) return data['error']?.toString();
    return null;
  }
}

// App-wide singleton
final apiClient = ApiClient();
