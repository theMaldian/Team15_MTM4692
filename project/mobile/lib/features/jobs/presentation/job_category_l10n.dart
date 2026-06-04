import 'package:ytu_assistant/features/jobs/data/models/job_model.dart';
import 'package:ytu_assistant/features/jobs/domain/job_category.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';

/// Localized display label for [JobCategory].
extension JobCategoryL10n on JobCategory {
  String localizedLabel(L10n l10n) {
    switch (this) {
      case JobCategory.courseAssistant:
        return l10n.catCourseAssistant;
      case JobCategory.labAssistant:
        return l10n.catLabAssistant;
      case JobCategory.researchAssistant:
        return l10n.catResearchAssistant;
      case JobCategory.other:
        return l10n.catOther;
    }
  }
}

/// Mirrors the logic of [JobModel.categoryLabel] but with localized strings.
///
/// Falls back to the raw free-text value for backend strings that don't match
/// any known category (so unknown future categories still display something).
extension JobModelL10n on JobModel {
  String localizedCategoryLabel(L10n l10n) {
    final JobCategory c = category;
    if (c != JobCategory.other) {
      return c.localizedLabel(l10n);
    }
    final String raw = jobCategoryRaw.trim();
    if (raw.isEmpty || raw.toLowerCase() == 'other') {
      return l10n.catOther;
    }
    // Preserve unknown free-text values as-is (title-cased).
    return raw
        .split(RegExp(r'[\s_-]+'))
        .where((String w) => w.isNotEmpty)
        .map((String w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }
}
