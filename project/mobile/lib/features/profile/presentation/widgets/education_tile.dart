import 'package:flutter/material.dart';

import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/core/theme/app_text_styles.dart';
import 'package:ytu_assistant/features/profile/data/models/education_model.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';

/// One education entry with edit/delete actions.
class EducationTile extends StatelessWidget {
  const EducationTile({
    super.key,
    required this.education,
    this.onEdit,
    this.onDelete,
  });

  final EducationModel education;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final String title = (education.university ?? '').trim().isNotEmpty
        ? education.university!.trim()
        : (education.department ?? '').trim();
    final String? department = (education.university ?? '').trim().isNotEmpty
        ? education.department?.trim()
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
                    if (department != null && department.isNotEmpty)
                      Text(department, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
              _menu(context, l10n),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: <Widget>[
                Text(_range(context, l10n), style: AppTextStyles.caption),
                if (education.gpa != null) ...<Widget>[
                  const SizedBox(width: 8),
                  Text(
                    '${l10n.fieldGpa}: ${education.gpa!.toStringAsFixed(2)}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _range(BuildContext context, L10n l10n) {
    final MaterialLocalizations m = MaterialLocalizations.of(context);
    final String start = education.startDate == null
        ? ''
        : m.formatMediumDate(education.startDate!);
    final String end = education.isOngoing
        ? l10n.ongoing
        : m.formatMediumDate(education.endDate!);
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
