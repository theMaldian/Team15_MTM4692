import 'package:flutter/material.dart';

import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/core/theme/app_text_styles.dart';
import 'package:ytu_assistant/core/utils/date_formatter.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';

/// Deadline indicator:
/// - > 7 days   → gray text "Son: 15 Oca"
/// - 1–7 days   → gold pill "3 gün kaldı"
/// - 0 days     → red pill "Bugün son"
/// - past       → gray strikethrough "Süresi doldu"
class DeadlineBadge extends StatelessWidget {
  const DeadlineBadge({super.key, required this.deadline});

  final DateTime deadline;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final int days = DateFormatter.daysUntil(deadline);

    if (days < 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.event_busy,
              size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            l10n.deadlineExpired,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      );
    }

    if (days == 0) {
      return _pill(
        background: AppColors.error,
        foreground: AppColors.textOnPrimary,
        icon: Icons.today,
        label: l10n.deadlineDueToday,
      );
    }

    if (days <= 7) {
      return _pill(
        background: AppColors.secondary,
        foreground: AppColors.primaryDark,
        icon: Icons.schedule,
        label: l10n.deadlineDaysLeft(days),
      );
    }

    // Locale-aware short date via Material localizations (no extra intl init).
    final String date =
        MaterialLocalizations.of(context).formatShortMonthDay(deadline.toLocal());
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.event_outlined,
            size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(l10n.deadlineDue(date), style: AppTextStyles.caption),
      ],
    );
  }

  Widget _pill({
    required Color background,
    required Color foreground,
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 13, color: foreground),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
