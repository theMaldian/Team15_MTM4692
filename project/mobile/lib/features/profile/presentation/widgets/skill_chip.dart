import 'package:flutter/material.dart';

import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/core/theme/app_text_styles.dart';

/// A skill pill, optionally removable.
class SkillChip extends StatelessWidget {
  const SkillChip({super.key, required this.label, this.onRemoved});

  final String label;
  final VoidCallback? onRemoved;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 12, right: onRemoved == null ? 12 : 6),
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (onRemoved != null) ...<Widget>[
            const SizedBox(width: 2),
            InkResponse(
              onTap: onRemoved,
              radius: 16,
              child: const Icon(Icons.close, size: 16, color: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }
}
