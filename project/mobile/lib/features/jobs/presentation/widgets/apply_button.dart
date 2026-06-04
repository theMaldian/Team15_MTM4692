import 'package:flutter/material.dart';

import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/core/theme/app_text_styles.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';

/// Visual/interaction states for the student apply button.
enum ApplyButtonState { idle, loading, applied, closed, expired }

/// State-aware full-width apply button used on the job detail action bar.
class ApplyButton extends StatelessWidget {
  const ApplyButton({
    super.key,
    required this.state,
    required this.onPressed,
  });

  final ApplyButtonState state;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    switch (state) {
      case ApplyButtonState.idle:
        return SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: onPressed,
            child: Text(l10n.applyButtonIdle),
          ),
        );
      case ApplyButtonState.loading:
        return const SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: null,
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
              ),
            ),
          ),
        );
      case ApplyButtonState.applied:
        return _StaticBar(
          background: AppColors.surfaceAlt,
          borderColor: AppColors.secondaryDark,
          icon: Icons.check_circle,
          iconColor: AppColors.secondaryDark,
          label: l10n.applyButtonApplied,
          labelColor: AppColors.primaryDark,
        );
      case ApplyButtonState.closed:
        return _StaticBar(
          background: AppColors.surfaceAlt,
          borderColor: AppColors.border,
          icon: Icons.lock_outline,
          iconColor: AppColors.textSecondary,
          label: l10n.statusClosed,
          labelColor: AppColors.textSecondary,
        );
      case ApplyButtonState.expired:
        return _StaticBar(
          background: AppColors.surfaceAlt,
          borderColor: AppColors.border,
          icon: Icons.event_busy,
          iconColor: AppColors.textSecondary,
          label: l10n.applyButtonExpired,
          labelColor: AppColors.textSecondary,
        );
    }
  }
}

class _StaticBar extends StatelessWidget {
  const _StaticBar({
    required this.background,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.labelColor,
  });

  final Color background;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.button.copyWith(color: labelColor),
          ),
        ],
      ),
    );
  }
}
