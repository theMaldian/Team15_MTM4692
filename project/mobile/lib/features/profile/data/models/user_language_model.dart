import 'package:ytu_assistant/features/profile/domain/language_level.dart';

/// A language linked to the current user (`details.languages` row in
/// `GET /profile`): `{ language_id, language_name, level }`.
class UserLanguageModel {
  const UserLanguageModel({
    required this.languageId,
    required this.languageName,
    this.level,
  });

  final int languageId;
  final String languageName;
  final LanguageLevel? level;

  factory UserLanguageModel.fromJson(Map<String, dynamic> json) {
    return UserLanguageModel(
      languageId: (json['language_id'] as num).toInt(),
      languageName: (json['language_name'] as String?) ?? '',
      level: LanguageLevel.tryFromString(json['level'] as String?),
    );
  }
}
