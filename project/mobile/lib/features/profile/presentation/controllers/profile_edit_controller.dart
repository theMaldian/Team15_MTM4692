import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/features/profile/data/profile_repository.dart';
import 'package:ytu_assistant/features/profile/presentation/controllers/profile_controller.dart';

/// Saves basic-info edits via `PUT /profile`, then refreshes the profile.
class ProfileEditController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> save(Map<String, dynamic> body) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard<void>(
      () => ref.read(profileRepositoryProvider).updateProfile(body),
    );
    final Object? error = state.error;
    if (error != null) {
      throw error;
    }
    ref.invalidate(profileControllerProvider);
  }
}

final profileEditControllerProvider =
    AutoDisposeAsyncNotifierProvider<ProfileEditController, void>(
  ProfileEditController.new,
);
