import 'package:flutter/material.dart';

import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/core/theme/app_text_styles.dart';
import 'package:ytu_assistant/features/profile/data/models/experience_model.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';

/// One work-experience entry with edit/delete actions.
class ExperienceTile extends StatelessWidget {
  const ExperienceTile({
    super.key,
    required this.experience,
    this.onEdit,
    this.onDelete,
  });

  final ExperienceModel experience;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final String title =
        (experience.position ?? '').trim().isNotEmpty
            ? experience.position!.trim()
            : (experience.companyName ?? '').trim();
    final String? company = (experience.position ?? '').trim().isNotEmpty
        ? experience.companyName?.trim()
        : null;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: AppTextStyles.label),
                    if (company != null && company.isNotEmpty)
                      Text(company, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
              _menu(context, l10n),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              _range(context, l10n),
              style: AppTextStyles.caption,
            ),
          ),
          if ((experience.description ?? '').trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                experience.description!.trim(),
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _range(BuildContext context, L10n l10n) {
    final MaterialLocalizations m = MaterialLocalizations.of(context);
    final String start = experience.startDate == null
        ? ''
        : m.formatMediumDate(experience.startDate!);
    final String end = experience.isOngoing
        ? l10n.ongoing
        : m.formatMediumDate(experience.endDate!);
    if (start.isEmpty) {
      return end;
    }
    return '$start – $end';
  }

  Widget _menu(BuildContext context, L10n l10n) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textSecondary),
      padding: EdgeInsets.zero,
      onSelected: (String v) {
        if (v == 'edit') {
          onEdit?.call();
        } else if (v == 'delete') {
          onDelete?.call();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'edit',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.edit_outlined, size: 20),
            title: Text(l10n.actionEdit),
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.delete_outline,
                size: 20, color: AppColors.error),
            title: Text(l10n.actionDelete,
                style: const TextStyle(color: AppColors.error)),
          ),
        ),
      ],
    );
  }
}
