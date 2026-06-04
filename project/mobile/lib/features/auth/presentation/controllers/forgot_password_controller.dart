import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/features/auth/data/auth_repository.dart';
import 'package:ytu_assistant/features/auth/data/models/auth_requests.dart';

/// Transient state for the forgot/reset/change-password forms.
class ForgotPasswordController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> forgot(String email) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard<void>(() {
      return _repo.forgotPassword(email.trim().toLowerCase());
    });
    final Object? error = state.error;
    if (error != null) {
      throw error;
    }
  }

  Future<void> reset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard<void>(() {
      return _repo.resetPassword(
        ResetPasswordRequest(
          email: email.trim().toLowerCase(),
          code: code.trim(),
          newPassword: newPassword,
        ),
      );
    });
    final Object? error = state.error;
    if (error != null) {
      throw error;
    }
  }

  Future<void> change({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard<void>(() {
      return _repo.changePassword(
        ChangePasswordRequest(
          currentPassword: currentPassword,
          newPassword: newPassword,
        ),
      );
    });
    final Object? error = state.error;
    if (error != null) {
      throw error;
    }
  }
}

final forgotPasswordControllerProvider =
    AutoDisposeAsyncNotifierProvider<ForgotPasswordController, void>(
  ForgotPasswordController.new,
);
