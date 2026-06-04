import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/features/profile/data/models/language_model.dart';
import 'package:ytu_assistant/features/profile/data/models/skill_model.dart';
import 'package:ytu_assistant/features/profile/data/profile_repository.dart';

/// Master catalog lists (skills + languages), loaded once and cached for the
/// session.
class CatalogData {
  const CatalogData({required this.skills, required this.languages});

  final List<SkillModel> skills;
  final List<LanguageModel> languages;
}

class CatalogController extends AsyncNotifier<CatalogData> {
  @override
  Future<CatalogData> build() async {
    final ProfileRepository repo = ref.read(profileRepositoryProvider);
    final List<SkillModel> skills = await repo.fetchSkills();
    final List<LanguageModel> languages = await repo.fetchLanguages();
    return CatalogData(skills: skills, languages: languages);
  }

  Future<void> refresh() async {
    state = const AsyncLoading<CatalogData>();
    state = await AsyncValue.guard<CatalogData>(() async {
      final ProfileRepository repo = ref.read(profileRepositoryProvider);
      final List<SkillModel> skills = await repo.fetchSkills();
      final List<LanguageModel> languages = await repo.fetchLanguages();
      return CatalogData(skills: skills, languages: languages);
    });
  }
}

final catalogControllerProvider =
    AsyncNotifierProvider<CatalogController, CatalogData>(
  CatalogController.new,
);
