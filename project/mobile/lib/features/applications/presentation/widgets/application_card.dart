import 'package:flutter/material.dart';

import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/core/theme/app_text_styles.dart';
import 'package:ytu_assistant/features/applications/data/models/application_model.dart';
import 'package:ytu_assistant/features/applications/presentation/application_status_l10n.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';

/// A student's application row: job position, department, applied date and a
/// status chip. Pending applications expose a "withdraw" action.
class ApplicationCard extends StatelessWidget {
  const ApplicationCard({
    super.key,
    required this.application,
    required this.onTap,
    this.onWithdraw,
  });

  final ApplicationModel application;
  final VoidCallback onTap;
  final VoidCallback? onWithdraw;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final Color statusColor = application.status.color;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      application.position,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 17,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _statusChip(l10n, statusColor),
                ],
              ),
              if ((application.departmentName ?? '').trim().isNotEmpty) ...<Widget>[
                const SizedBox(height: 2),
                Text(
                  application.departmentName!.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  const Icon(Icons.schedule,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      application.appliedAt == null
                          ? ''
                          : l10n.appliedOn(
                              MaterialLocalizations.of(context)
                                  .formatMediumDate(application.appliedAt!),
                            ),
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              ),
              if (application.isPending && onWithdraw != null) ...<Widget>[
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onWithdraw,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.undo, size: 16),
                    label: Text(l10n.withdrawAction),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(L10n l10n, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(application.status.icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            application.status.localizedLabel(l10n),
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
