import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/features/profile/data/profile_repository.dart';
import 'package:ytu_assistant/features/profile/presentation/controllers/profile_controller.dart';

/// Create / edit / delete the current user's experience entries.
class ExperiencesController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> create(Map<String, dynamic> body) =>
      _run(() => ref.read(profileRepositoryProvider).createExperience(body));

  Future<void> edit(int id, Map<String, dynamic> body) =>
      _run(() => ref.read(profileRepositoryProvider).updateExperience(id, body));

  Future<void> remove(int id) =>
      _run(() => ref.read(profileRepositoryProvider).deleteExperience(id));

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

final experiencesControllerProvider =
    AutoDisposeAsyncNotifierProvider<ExperiencesController, void>(
  ExperiencesController.new,
);
