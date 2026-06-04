import 'package:flutter/material.dart';

import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/core/theme/app_text_styles.dart';
import 'package:ytu_assistant/features/profile/data/models/user_language_model.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';

/// A language pill showing the name + proficiency level. Tapping edits the
/// level; the trailing × removes it.
class LanguageChip extends StatelessWidget {
  const LanguageChip({
    super.key,
    required this.language,
    this.onTap,
    this.onRemoved,
  });

  final UserLanguageModel language;
  final VoidCallback? onTap;
  final VoidCallback? onRemoved;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final String? level = language.level?.localizedLabel(l10n);

    return Material(
      color: AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 34,
          padding:
              EdgeInsets.only(left: 12, right: onRemoved == null ? 12 : 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                language.languageName,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (level != null) ...<Widget>[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    level,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textOnPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              if (onRemoved != null) ...<Widget>[
                const SizedBox(width: 4),
                InkResponse(
                  onTap: onRemoved,
                  radius: 16,
                  child: const Icon(Icons.close,
                      size: 16, color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
