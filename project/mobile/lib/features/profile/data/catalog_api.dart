import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/core/network/api_client.dart';
import 'package:ytu_assistant/core/network/api_endpoints.dart';
import 'package:ytu_assistant/features/profile/data/models/language_model.dart';
import 'package:ytu_assistant/features/profile/data/models/skill_model.dart';

/// Dio wrapper for the catalog master lists (`/skills`, `/languages`).
class CatalogApi {
  CatalogApi(this._client);

  final ApiClient _client;

  Future<List<SkillModel>> fetchSkills() async {
    final dynamic body = await _client.get(ApiEndpoints.skills);
    final Map<String, dynamic> map = _asMap(body);
    final dynamic raw = map['skills'];
    if (raw is! List) {
      return <SkillModel>[];
    }
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> e) => SkillModel.fromJson(_castMap(e)))
        .toList();
  }

  Future<List<LanguageModel>> fetchLanguages() async {
    final dynamic body = await _client.get(ApiEndpoints.languages);
    final Map<String, dynamic> map = _asMap(body);
    final dynamic raw = map['languages'];
    if (raw is! List) {
      return <LanguageModel>[];
    }
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> e) => LanguageModel.fromJson(_castMap(e)))
        .toList();
  }

  static Map<String, dynamic> _asMap(dynamic body) {
    if (body is Map<String, dynamic>) {
      return body;
    }
    if (body is Map) {
      return _castMap(body);
    }
    return <String, dynamic>{};
  }

  static Map<String, dynamic> _castMap(Map<dynamic, dynamic> raw) {
    return raw.map((Object? key, Object? value) =>
        MapEntry<String, dynamic>(key.toString(), value));
  }
}

final catalogApiProvider = Provider<CatalogApi>((ref) {
  return CatalogApi(ref.watch(apiClientProvider));
});
