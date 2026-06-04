import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/features/auth/data/models/auth_requests.dart';
import 'package:ytu_assistant/features/auth/data/models/auth_response_model.dart';
import 'package:ytu_assistant/features/auth/presentation/controllers/auth_controller.dart';

/// Transient state for the register form.
class RegisterController extends AutoDisposeAsyncNotifier<AuthResponse?> {
  @override
  Future<AuthResponse?> build() async => null;

  Future<AuthResponse> submit(RegisterRequest request) async {
    state = const AsyncLoading<AuthResponse?>();
    final AsyncValue<AuthResponse?> result =
        await AsyncValue.guard<AuthResponse?>(() async {
      return ref.read(authControllerProvider.notifier).register(request);
    });
    state = result;
    final Object? error = result.error;
    if (error != null) {
      throw error;
    }
    return result.value!;
  }
}

final registerControllerProvider =
    AutoDisposeAsyncNotifierProvider<RegisterController, AuthResponse?>(
  RegisterController.new,
);
