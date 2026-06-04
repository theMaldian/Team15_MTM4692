import 'package:flutter/material.dart';

import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/core/theme/app_text_styles.dart';
import 'package:ytu_assistant/features/auth/domain/user_role.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';

/// Small pill that shows the role inferred from the email domain.
///
/// - Student: navy fill (`AppColors.primaryLight`)
/// - Professor: gold fill (`AppColors.secondary`)
/// - Unrecognized: hidden (returns a zero-sized box)
class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.email});

  /// Pass the raw email; the widget derives the role and renders accordingly.
  final String email;

  @override
  Widget build(BuildContext context) {
    final UserRole? role = UserRole.fromEmail(email);
    if (role == null) {
      return const SizedBox.shrink();
    }
    final L10n l10n = L10n.of(context);
    final bool isStudent = role == UserRole.student;
    final Color bg =
        isStudent ? AppColors.primary : AppColors.secondary;
    final Color fg =
        isStudent ? AppColors.textOnPrimary : AppColors.primaryDark;
    final IconData icon = isStudent ? Icons.school_outlined : Icons.workspace_premium_outlined;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            isStudent ? l10n.roleStudent : l10n.roleProfessor,
            style: AppTextStyles.caption.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
