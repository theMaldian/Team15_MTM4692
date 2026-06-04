import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/features/profile/data/profile_repository.dart';
import 'package:ytu_assistant/features/profile/presentation/controllers/profile_controller.dart';

/// Add / remove the current user's skills.
class SkillsController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> add({int? skillId, String? skillName}) =>
      _run(() => ref
          .read(profileRepositoryProvider)
          .addSkill(skillId: skillId, skillName: skillName));

  Future<void> remove(int skillId) =>
      _run(() => ref.read(profileRepositoryProvider).removeSkill(skillId));

  Future<void> _run(Future<void> Function() action) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard<void>(action);
    final Object? error = state.error;
    if (error != null) {
      throw error;
    }
    ref.invalidate(profileControllerProvider);
  }
}

final skillsControllerProvider =
    AutoDisposeAsyncNotifierProvider<SkillsController, void>(
  SkillsController.new,
);
