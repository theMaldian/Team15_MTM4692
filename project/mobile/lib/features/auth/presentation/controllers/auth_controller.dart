import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/core/network/api_client.dart';
import 'package:ytu_assistant/features/auth/data/auth_repository.dart';
import 'package:ytu_assistant/features/auth/data/models/auth_requests.dart';
import 'package:ytu_assistant/features/auth/data/models/auth_response_model.dart';
import 'package:ytu_assistant/features/auth/data/models/user_model.dart';

/// Global current-user state. `null` = signed out.
class AuthController extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    // Wire up the 401-forced-logout broadcast from the network layer.
    ref.listen<AuthEvents>(authEventsProvider, (_, __) {
      if (state.hasValue && state.value != null) {
        state = const AsyncData<UserModel?>(null);
      }
    });

    final AuthRepository repo = ref.read(authRepositoryProvider);
    return repo.bootstrap();
  }

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  /// Calls login, then exposes the user via [state].
  Future<void> login(String email, String password) async {
    state = const AsyncLoading<UserModel?>();
    state = await AsyncValue.guard<UserModel?>(() async {
      return _repo.login(
        LoginRequest(email: email.trim().toLowerCase(), password: password),
      );
    });
    final Object? error = state.error;
    if (error != null) {
      throw error;
    }
  }

  /// Submits a registration. Backend doesn't issue a token here, so the user
  /// stays signed out — the caller should navigate to /verify-email.
  Future<AuthResponse> register(RegisterRequest req) async {
    final AuthResponse response = await _repo.register(req);
    return response;
  }

  Future<void> verifyEmail(String email, String code) {
    return _repo.verifyEmail(
      VerifyEmailRequest(email: email.trim().toLowerCase(), code: code.trim()),
    );
  }

  Future<void> resendVerification(String email) {
    return _repo.resendVerification(email.trim().toLowerCase());
  }

  /// Logs out + wipes local session. Always resolves to a null user state.
  ///
  /// Intentionally skips an `AsyncLoading` transition so the router redirect
  /// doesn't flash to /splash before landing on /login.
  Future<void> logout() async {
    try {
      await _repo.logout();
    } finally {
      state = const AsyncData<UserModel?>(null);
    }
  }
}

/// Riverpod provider for [AuthController].
final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserModel?>(AuthController.new);
