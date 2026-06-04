import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/features/auth/presentation/controllers/auth_controller.dart';

/// Owns the transient submit state for the login form.
class LoginController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submit({required String email, required String password}) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard<void>(() {
      return ref.read(authControllerProvider.notifier).login(email, password);
    });
    final Object? error = state.error;
    if (error != null) {
      throw error;
    }
  }
}

final loginControllerProvider =
    AutoDisposeAsyncNotifierProvider<LoginController, void>(
  LoginController.new,
);
