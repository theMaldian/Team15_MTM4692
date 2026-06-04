/// Catalog language from `GET /languages` (`{ language_id, language_name }`).
class LanguageModel {
  const LanguageModel({required this.languageId, required this.languageName});

  final int languageId;
  final String languageName;

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      languageId: (json['language_id'] as num).toInt(),
      languageName: (json['language_name'] as String?) ?? '',
    );
  }
}
