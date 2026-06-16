import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/api/api_exception.dart';
import '../models/auth_model.dart';

class GoogleAuthService {
  final ApiClient _client;

  GoogleAuthService(this._client);

  final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '187703569206-38skdfqdf485njslrl92mef5sh6ri45c.apps.googleusercontent.com',
  );

  Future<AuthResponseModel?> signIn() async {
    try {
      // 1. Google picker
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled

      // 2. Get auth tokens
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) throw ApiException(statusCode: 0, message: 'No ID token from Google');

      // 3. Sign in to Firebase Auth (keeps session synced locally)
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      // 4. Send Google ID token to backend — verified via Google tokeninfo endpoint
      final data = await _client.post(ApiEndpoints.googleAuth, data: {'id_token': idToken});
      final response = AuthResponseModel.fromJson(data);

      if (response.ok && response.token != null) {
        await _client.setToken(response.token!);
      }
      return response;
    } on ApiException {
      rethrow;
    } catch (e, st) {
      if (kDebugMode) debugPrint('[GoogleAuth] error: $e\n$st');
      throw ApiException(statusCode: 0, message: e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (kDebugMode) debugPrint('[GoogleAuth] signOut error: $e');
    }
  }
}
