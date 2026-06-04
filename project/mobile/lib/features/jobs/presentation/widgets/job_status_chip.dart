import 'package:flutter/material.dart';

import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/core/theme/app_text_styles.dart';
import 'package:ytu_assistant/features/jobs/data/models/job_model.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';

/// Small status pill for a job:
/// - active & not expired → green dot + "Aktif"
/// - active & expired     → gray + "Süresi doldu"
/// - closed (is_active=0) → gray + "Kapandı"
class JobStatusChip extends StatelessWidget {
  const JobStatusChip({super.key, required this.job});

  final JobModel job;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    late final Color color;
    late final String label;
    late final bool showDot;

    if (!job.isActive) {
      color = AppColors.textSecondary;
      label = l10n.statusClosed;
      showDot = false;
    } else if (job.isExpired) {
      color = AppColors.textSecondary;
      label = l10n.statusExpired;
      showDot = false;
    } else {
      color = AppColors.success;
      label = l10n.statusActive;
      showDot = true;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (showDot) ...<Widget>[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
