import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Application status, used by `my_application_status` on job detail and by
/// the applicant rows on `/jobs/:id/applicants`.
///
/// Backend CHECK constraint: `('pending', 'approved', 'rejected')`.
enum ApplicationStatus {
  pending,
  approved,
  rejected;

  String get wireValue => name;

  String get label {
    switch (this) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.approved:
        return 'Approved';
      case ApplicationStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case ApplicationStatus.pending:
        return AppColors.statusPending;
      case ApplicationStatus.approved:
        return AppColors.statusApproved;
      case ApplicationStatus.rejected:
        return AppColors.statusRejected;
    }
  }

  IconData get icon {
    switch (this) {
      case ApplicationStatus.pending:
        return Icons.hourglass_empty;
      case ApplicationStatus.approved:
        return Icons.check_circle_outline;
      case ApplicationStatus.rejected:
        return Icons.cancel_outlined;
    }
  }

  static ApplicationStatus? tryFromString(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'pending':
        return ApplicationStatus.pending;
      case 'approved':
        return ApplicationStatus.approved;
      case 'rejected':
        return ApplicationStatus.rejected;
      default:
        return null;
    }
  }
}
