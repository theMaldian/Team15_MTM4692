import 'package:ytu_assistant/l10n/app_localizations.dart';

/// Proficiency level for a user's language. Backend stores these upper-cased
/// (`BEGINNER | INTERMEDIATE | ADVANCED | NATIVE`).
enum LanguageLevel {
  beginner,
  intermediate,
  advanced,
  native;

  /// Wire value sent to / received from the backend (upper-case).
  String get wireValue => name.toUpperCase();

  String localizedLabel(L10n l10n) {
    switch (this) {
      case LanguageLevel.beginner:
        return l10n.levelBeginner;
      case LanguageLevel.intermediate:
        return l10n.levelIntermediate;
      case LanguageLevel.advanced:
        return l10n.levelAdvanced;
      case LanguageLevel.native:
        return l10n.levelNative;
    }
  }

  static LanguageLevel? tryFromString(String? value) {
    switch ((value ?? '').trim().toUpperCase()) {
      case 'BEGINNER':
        return LanguageLevel.beginner;
      case 'INTERMEDIATE':
        return LanguageLevel.intermediate;
      case 'ADVANCED':
        return LanguageLevel.advanced;
      case 'NATIVE':
        return LanguageLevel.native;
      default:
        return null;
    }
  }
}
