import 'package:ytu_assistant/features/jobs/domain/application_status.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';

/// Localized labels for [ApplicationStatus] (the enum itself lives in the jobs
/// domain and keeps an English fallback `.label`).
extension ApplicationStatusL10n on ApplicationStatus {
  String localizedLabel(L10n l10n) {
    switch (this) {
      case ApplicationStatus.pending:
        return l10n.appStatusPending;
      case ApplicationStatus.approved:
        return l10n.appStatusApproved;
      case ApplicationStatus.rejected:
        return l10n.appStatusRejected;
    }
  }
}
