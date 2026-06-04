import 'package:flutter/material.dart';

import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/core/theme/app_text_styles.dart';
import 'package:ytu_assistant/features/applications/presentation/application_status_l10n.dart';
import 'package:ytu_assistant/features/jobs/domain/application_status.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';

/// Bottom sheet that lets a professor set an applicant's decision.
///
/// The backend's `PATCH /applications/:id/status` only accepts `approved` /
/// `rejected` (see BACKEND_API.md), so only those two are offered — `pending`
/// is the read-only initial state and cannot be set back.
class StatusUpdateSheet extends StatelessWidget {
  const StatusUpdateSheet({super.key, required this.current});

  final ApplicationStatus current;

  static Future<ApplicationStatus?> show(
    BuildContext context,
    ApplicationStatus current,
  ) {
    return showModalBottomSheet<ApplicationStatus>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatusUpdateSheet(current: current),
    );
  }

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.statusUpdateSheetTitle, style: AppTextStyles.titleLarge),
            const SizedBox(height: 16),
            _option(context, l10n, ApplicationStatus.approved),
            const SizedBox(height: 10),
            _option(context, l10n, ApplicationStatus.rejected),
          ],
        ),
      ),
    );
  }

  Widget _option(BuildContext context, L10n l10n, ApplicationStatus status) {
    final bool selected = current == status;
    final Color color = status.color;
    return Material(
      color: color.withValues(alpha: selected ? 0.16 : 0.06),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).pop(status),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: <Widget>[
              Icon(status.icon, color: color),
              const SizedBox(width: 12),
              Text(
                status.localizedLabel(l10n),
                style: AppTextStyles.titleMedium.copyWith(color: color),
              ),
              const Spacer(),
              if (selected) Icon(Icons.check, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
