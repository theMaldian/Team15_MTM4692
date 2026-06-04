import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/core/network/api_client.dart';
import 'package:ytu_assistant/core/network/api_endpoints.dart';
import 'package:ytu_assistant/features/profile/data/models/profile_model.dart';
import 'package:ytu_assistant/features/profile/domain/language_level.dart';

/// Dio wrapper for `/profile` + all CV sub-resources. Skill/language mutations
/// return the full profile shape; experience/education mutations return the
/// single entity. The controllers refetch the profile after any change, so
/// these methods only need to surface errors.
class ProfileApi {
  ProfileApi(this._client);

  final ApiClient _client;

  Future<ProfileModel> fetchProfile() async {
    final dynamic body = await _client.get(ApiEndpoints.profile);
    return ProfileModel.fromJson(_asMap(body));
  }

  Future<void> updateProfile(Map<String, dynamic> body) async {
    await _client.put(ApiEndpoints.profile, data: body);
  }

  // ---- Skills ----
  Future<void> addSkill({int? skillId, String? skillName}) async {
    await _client.post(
      ApiEndpoints.profileSkills,
      data: <String, dynamic>{
        if (skillId != null) 'skill_id': skillId,
        if (skillName != null) 'skill_name': skillName,
      },
    );
  }

  Future<void> removeSkill(int skillId) async {
    await _client.delete(ApiEndpoints.profileSkill(skillId));
  }

  // ---- Languages ----
  Future<void> addLanguage({
    int? languageId,
    String? languageName,
    required LanguageLevel level,
  }) async {
    await _client.post(
      ApiEndpoints.profileLanguages,
      data: <String, dynamic>{
        if (languageId != null) 'language_id': languageId,
        if (languageName != null) 'language_name': languageName,
        'level': level.wireValue,
      },
    );
  }

  Future<void> updateLanguage(int languageId, LanguageLevel level) async {
    await _client.put(
      ApiEndpoints.profileLanguage(languageId),
      data: <String, dynamic>{'level': level.wireValue},
    );
  }

  Future<void> removeLanguage(int languageId) async {
    await _client.delete(ApiEndpoints.profileLanguage(languageId));
  }

  // ---- Experiences ----
  Future<void> createExperience(Map<String, dynamic> body) async {
    await _client.post(ApiEndpoints.profileExperiences, data: body);
  }

  Future<void> updateExperience(int id, Map<String, dynamic> body) async {
    await _client.put(ApiEndpoints.profileExperience(id), data: body);
  }

  Future<void> deleteExperience(int id) async {
    await _client.delete(ApiEndpoints.profileExperience(id));
  }

  // ---- Educations ----
  Future<void> createEducation(Map<String, dynamic> body) async {
    await _client.post(ApiEndpoints.profileEducations, data: body);
  }

  Future<void> updateEducation(int id, Map<String, dynamic> body) async {
    await _client.put(ApiEndpoints.profileEducation(id), data: body);
  }

  Future<void> deleteEducation(int id) async {
    await _client.delete(ApiEndpoints.profileEducation(id));
  }

  static Map<String, dynamic> _asMap(dynamic body) {
    if (body is Map<String, dynamic>) {
      return body;
    }
    if (body is Map) {
      return body.map((Object? key, Object? value) =>
          MapEntry<String, dynamic>(key.toString(), value));
    }
    return <String, dynamic>{};
  }
}

final profileApiProvider = Provider<ProfileApi>((ref) {
  return ProfileApi(ref.watch(apiClientProvider));
});
