import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/features/profile/data/profile_repository.dart';
import 'package:ytu_assistant/features/profile/domain/language_level.dart';
import 'package:ytu_assistant/features/profile/presentation/controllers/profile_controller.dart';

/// Add / change-level / remove the current user's languages.
class LanguagesController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> add({
    int? languageId,
    String? languageName,
    required LanguageLevel level,
  }) =>
      _run(() => ref.read(profileRepositoryProvider).addLanguage(
            languageId: languageId,
            languageName: languageName,
            level: level,
          ));

  Future<void> changeLevel(int languageId, LanguageLevel level) => _run(
      () => ref.read(profileRepositoryProvider).updateLanguage(languageId, level));

  Future<void> remove(int languageId) =>
      _run(() => ref.read(profileRepositoryProvider).removeLanguage(languageId));

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

final languagesControllerProvider =
    AutoDisposeAsyncNotifierProvider<LanguagesController, void>(
  LanguagesController.new,
);
