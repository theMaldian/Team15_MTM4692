import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/features/profile/data/catalog_api.dart';
import 'package:ytu_assistant/features/profile/data/models/language_model.dart';
import 'package:ytu_assistant/features/profile/data/models/profile_model.dart';
import 'package:ytu_assistant/features/profile/data/models/skill_model.dart';
import 'package:ytu_assistant/features/profile/data/profile_api.dart';
import 'package:ytu_assistant/features/profile/domain/language_level.dart';

/// Pure data layer over [ProfileApi] + [CatalogApi]. Controllers own cache
/// invalidation (matching the jobs/applications convention).
class ProfileRepository {
  ProfileRepository(this._profile, this._catalog);

  final ProfileApi _profile;
  final CatalogApi _catalog;

  // ---- Profile ----
  Future<ProfileModel> fetchProfile() => _profile.fetchProfile();

  Future<void> updateProfile(Map<String, dynamic> body) =>
      _profile.updateProfile(body);

  // ---- Skills ----
  Future<void> addSkill({int? skillId, String? skillName}) =>
      _profile.addSkill(skillId: skillId, skillName: skillName);

  Future<void> removeSkill(int skillId) => _profile.removeSkill(skillId);

  // ---- Languages ----
  Future<void> addLanguage({
    int? languageId,
    String? languageName,
    required LanguageLevel level,
  }) =>
      _profile.addLanguage(
        languageId: languageId,
        languageName: languageName,
        level: level,
      );

  Future<void> updateLanguage(int languageId, LanguageLevel level) =>
      _profile.updateLanguage(languageId, level);

  Future<void> removeLanguage(int languageId) =>
      _profile.removeLanguage(languageId);

  // ---- Experiences ----
  Future<void> createExperience(Map<String, dynamic> body) =>
      _profile.createExperience(body);

  Future<void> updateExperience(int id, Map<String, dynamic> body) =>
      _profile.updateExperience(id, body);

  Future<void> deleteExperience(int id) => _profile.deleteExperience(id);

  // ---- Educations ----
  Future<void> createEducation(Map<String, dynamic> body) =>
      _profile.createEducation(body);

  Future<void> updateEducation(int id, Map<String, dynamic> body) =>
      _profile.updateEducation(id, body);

  Future<void> deleteEducation(int id) => _profile.deleteEducation(id);

  // ---- Catalog ----
  Future<List<SkillModel>> fetchSkills() => _catalog.fetchSkills();

  Future<List<LanguageModel>> fetchLanguages() => _catalog.fetchLanguages();
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(
    ref.watch(profileApiProvider),
    ref.watch(catalogApiProvider),
  );
});
