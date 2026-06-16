import '../models/auth_model.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/api/api_exception.dart';

class AuthService {
  final ApiClient _client;

  AuthService(this._client);

  Future<AuthResponseModel> login(String email, String password) async {
    try {
      final data = await _client.post(ApiEndpoints.login, data: {
        'email': email,
        'password': password,
      });
      final response = AuthResponseModel.fromJson(data);
      if (response.ok && response.token != null) {
        await _client.setToken(response.token!);
      }
      return response;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(statusCode: 0, message: e.toString());
    }
  }

  Future<AuthResponseModel> register(String email, String password) async {
    try {
      final data = await _client.post(ApiEndpoints.register, data: {
        'email': email,
        'password': password,
        'password_confirm': password,
      });
      final response = AuthResponseModel.fromJson(data);
      if (response.ok && response.token != null) {
        await _client.setToken(response.token!);
      }
      return response;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(statusCode: 0, message: e.toString());
    }
  }

  Future<AuthResponseModel> me() async {
    try {
      final data = await _client.get(ApiEndpoints.me);
      return AuthResponseModel.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(statusCode: 0, message: e.toString());
    }
  }

  Future<void> logout() async {
    await _client.clearToken();
  }

  Future<bool> isLoggedIn() => _client.hasToken();
}
