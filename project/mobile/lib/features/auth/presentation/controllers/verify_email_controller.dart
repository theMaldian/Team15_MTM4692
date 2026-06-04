import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/features/auth/presentation/controllers/auth_controller.dart';

/// Transient state for verify-email + resend actions.
class VerifyEmailController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> verify({required String email, required String code}) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard<void>(() {
      return ref
          .read(authControllerProvider.notifier)
          .verifyEmail(email, code);
    });
    final Object? error = state.error;
    if (error != null) {
      throw error;
    }
  }

  Future<void> resend(String email) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard<void>(() {
      return ref
          .read(authControllerProvider.notifier)
          .resendVerification(email);
    });
    final Object? error = state.error;
    if (error != null) {
      throw error;
    }
  }
}

final verifyEmailControllerProvider =
    AutoDisposeAsyncNotifierProvider<VerifyEmailController, void>(
  VerifyEmailController.new,
);
