import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/core/network/api_exception.dart';
import 'package:ytu_assistant/core/storage/secure_storage.dart';
import 'package:ytu_assistant/features/auth/data/auth_api.dart';
import 'package:ytu_assistant/features/auth/data/models/auth_requests.dart';
import 'package:ytu_assistant/features/auth/data/models/auth_response_model.dart';
import 'package:ytu_assistant/features/auth/data/models/user_model.dart';

/// Orchestrates [AuthApi] + [SecureStorage].
class AuthRepository {
  AuthRepository({required AuthApi api, required SecureStorage storage})
      : _api = api,
        _storage = storage;

  final AuthApi _api;
  final SecureStorage _storage;

  /// Calls `/auth/login`, persists the token + user, returns the [UserModel].
  Future<UserModel> login(LoginRequest req) async {
    final AuthResponse response = await _api.login(req);
    if (response.token == null || response.user == null) {
      throw const ApiException(
        message: 'Login response did not include a session.',
      );
    }
    await _storage.saveToken(response.token!);
    await _storage.saveUser(response.user!.toJson());
    return response.user!;
  }

  /// Calls `/auth/register`. The backend does NOT return a token here —
  /// the user must verify their email and then log in. Returns the full
  /// [AuthResponse] (carrying the inferred role + server message).
  Future<AuthResponse> register(RegisterRequest req) {
    return _api.register(req);
  }

  Future<void> verifyEmail(VerifyEmailRequest req) =>
      _api.verifyEmail(req);

  Future<void> resendVerification(String email) =>
      _api.resendVerification(email);

  Future<void> forgotPassword(String email) => _api.forgotPassword(email);

  Future<void> resetPassword(ResetPasswordRequest req) =>
      _api.resetPassword(req);

  Future<void> changePassword(ChangePasswordRequest req) =>
      _api.changePassword(req);

  /// Calls `/auth/logout` (server-side is a no-op) then clears local storage.
  /// Errors during the network call are swallowed — the client-side wipe is
  /// what really matters.
  Future<void> logout() async {
    try {
      await _api.logout();
    } on ApiException {
      // Server logout is symbolic; always wipe locally regardless.
    }
    await _storage.clear();
  }

  /// Reads the cached user from secure storage. Returns null if no session.
  Future<UserModel?> currentUser() async {
    final Map<String, dynamic>? json = await _storage.readUser();
    if (json == null) {
      return null;
    }
    try {
      return UserModel.fromJson(json);
    } catch (_) {
      // Corrupt cache: wipe and start over.
      await _storage.clear();
      return null;
    }
  }

  /// App-start bootstrap: returns the cached user when a token exists,
  /// otherwise null. A future revision can hit `/profile` for a freshness
  /// check; we keep it cheap for now.
  Future<UserModel?> bootstrap() async {
    final bool hasToken = await _storage.hasToken();
    if (!hasToken) {
      return null;
    }
    return currentUser();
  }
}

/// Riverpod provider for [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    api: ref.watch(authApiProvider),
    storage: ref.watch(secureStorageProvider),
  );
});
