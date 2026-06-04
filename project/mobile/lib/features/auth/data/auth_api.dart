import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/core/network/api_client.dart';
import 'package:ytu_assistant/core/network/api_endpoints.dart';
import 'package:ytu_assistant/features/auth/data/models/auth_requests.dart';
import 'package:ytu_assistant/features/auth/data/models/auth_response_model.dart';

/// Thin Dio wrapper hitting `/auth/*`. Errors are already normalized to
/// `ApiException` by the [ApiClient] interceptor.
class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  Future<AuthResponse> register(RegisterRequest req) async {
    final dynamic body = await _client.post(
      ApiEndpoints.register,
      data: req.toJson(),
    );
    return AuthResponse.fromJson(_asMap(body));
  }

  Future<AuthResponse> login(LoginRequest req) async {
    final dynamic body = await _client.post(
      ApiEndpoints.login,
      data: req.toJson(),
    );
    return AuthResponse.fromJson(_asMap(body));
  }

  Future<void> verifyEmail(VerifyEmailRequest req) async {
    await _client.post(ApiEndpoints.verifyEmail, data: req.toJson());
  }

  Future<void> resendVerification(String email) async {
    await _client.post(
      ApiEndpoints.resendVerification,
      data: <String, dynamic>{'email': email},
    );
  }

  Future<void> logout() async {
    await _client.post(ApiEndpoints.logout);
  }

  Future<void> forgotPassword(String email) async {
    await _client.post(
      ApiEndpoints.forgotPassword,
      data: <String, dynamic>{'email': email},
    );
  }

  Future<void> resetPassword(ResetPasswordRequest req) async {
    await _client.post(ApiEndpoints.resetPassword, data: req.toJson());
  }

  Future<void> changePassword(ChangePasswordRequest req) async {
    await _client.post(ApiEndpoints.changePassword, data: req.toJson());
  }

  static Map<String, dynamic> _asMap(dynamic body) {
    if (body is Map<String, dynamic>) {
      return body;
    }
    if (body is Map) {
      return body.map(
        (Object? key, Object? value) =>
            MapEntry<String, dynamic>(key.toString(), value),
      );
    }
    return <String, dynamic>{};
  }
}

/// Riverpod provider for [AuthApi].
final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(apiClientProvider));
});
