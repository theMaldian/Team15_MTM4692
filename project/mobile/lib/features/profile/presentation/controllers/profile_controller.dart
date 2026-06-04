import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/features/auth/data/models/user_model.dart';
import 'package:ytu_assistant/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ytu_assistant/features/profile/data/models/profile_model.dart';
import 'package:ytu_assistant/features/profile/data/profile_repository.dart';

/// The current user's full profile (`GET /profile`). The single source of truth
/// for the profile screen; mutation controllers invalidate this after a change.
class ProfileController extends AsyncNotifier<ProfileModel> {
  @override
  Future<ProfileModel> build() {
    // This provider is long-lived (not auto-disposed). Re-run whenever the
    // signed-in user changes so we never serve a previous session's profile.
    ref.watch(
      authControllerProvider.select(
        (AsyncValue<UserModel?> auth) => auth.valueOrNull?.userId,
      ),
    );
    return ref.read(profileRepositoryProvider).fetchProfile();
  }

  Future<void> refresh() async {
    state = const AsyncLoading<ProfileModel>();
    state = await AsyncValue.guard<ProfileModel>(
      () => ref.read(profileRepositoryProvider).fetchProfile(),
    );
  }
}

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, ProfileModel>(
  ProfileController.new,
);
