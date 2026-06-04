import 'package:flutter/material.dart';

import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/core/theme/app_text_styles.dart';
import 'package:ytu_assistant/features/auth/data/models/user_model.dart';
import 'package:ytu_assistant/features/auth/presentation/widgets/role_badge.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';
import 'package:ytu_assistant/shared/widgets/secondary_button.dart';

/// Profile hero: initials avatar, name, role badge, optional academic title,
/// faculty · department, email, and an "Edit profile" action.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.user,
    this.academicTitle,
    required this.onEdit,
  });

  final UserModel user;
  final String? academicTitle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final List<String> facultyDept = <String>[
      if ((user.faculty ?? '').trim().isNotEmpty) user.faculty!.trim(),
      if ((user.department ?? '').trim().isNotEmpty) user.department!.trim(),
    ];

    return Column(
      children: <Widget>[
        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.primary,
          child: Text(
            user.initials,
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 30,
              color: AppColors.textOnPrimary,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          user.fullName,
          textAlign: TextAlign.center,
          style: AppTextStyles.titleLarge,
        ),
        if ((academicTitle ?? '').trim().isNotEmpty) ...<Widget>[
          const SizedBox(height: 2),
          Text(
            academicTitle!.trim(),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
        ],
        const SizedBox(height: 10),
        RoleBadge(email: user.email),
        if (facultyDept.isNotEmpty) ...<Widget>[
          const SizedBox(height: 10),
          Text(
            facultyDept.join(' · '),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
        const SizedBox(height: 4),
        Text(user.email, textAlign: TextAlign.center, style: AppTextStyles.caption),
        const SizedBox(height: 16),
        SecondaryButton(
          label: l10n.editProfileAction,
          icon: Icons.edit_outlined,
          onPressed: onEdit,
        ),
      ],
    );
  }
}
