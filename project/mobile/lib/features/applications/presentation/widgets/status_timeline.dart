import 'package:flutter/material.dart';

import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/core/theme/app_text_styles.dart';
import 'package:ytu_assistant/features/jobs/domain/application_status.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';

/// Compact 3-step progress: Applied → In review → Result. The result node is
/// colored by the final [ApplicationStatus] once a decision is made.
class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.status});

  final ApplicationStatus status;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final bool decided = status != ApplicationStatus.pending;
    final Color resultColor = status.color;

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            _dot(filled: true, color: AppColors.primary, icon: Icons.check),
            _line(active: true),
            _dot(
              filled: true,
              color: AppColors.primary,
              icon: decided ? Icons.check : Icons.more_horiz,
            ),
            _line(active: decided),
            _dot(
              filled: decided,
              color: decided ? resultColor : AppColors.border,
              icon: status == ApplicationStatus.rejected
                  ? Icons.close
                  : Icons.check,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                l10n.statusTimelineApplied,
                textAlign: TextAlign.start,
                style: AppTextStyles.caption,
              ),
            ),
            Expanded(
              child: Text(
                l10n.statusTimelineReview,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption,
              ),
            ),
            Expanded(
              child: Text(
                l10n.statusTimelineResult,
                textAlign: TextAlign.end,
                style: AppTextStyles.caption.copyWith(
                  color: decided ? resultColor : AppColors.textSecondary,
                  fontWeight: decided ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dot({
    required bool filled,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: filled ? color : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Icon(
        icon,
        size: 14,
        color: filled ? AppColors.textOnPrimary : color,
      ),
    );
  }

  Widget _line({required bool active}) {
    return Expanded(
      child: Container(
        height: 2,
        color: active ? AppColors.primary : AppColors.border,
      ),
    );
  }
}
