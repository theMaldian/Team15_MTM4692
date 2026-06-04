import 'package:flutter/material.dart';

import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/core/theme/app_text_styles.dart';
import 'package:ytu_assistant/features/jobs/data/models/job_model.dart';
import 'package:ytu_assistant/features/jobs/presentation/job_category_l10n.dart';
import 'package:ytu_assistant/features/jobs/presentation/widgets/deadline_badge.dart';
import 'package:ytu_assistant/features/jobs/presentation/widgets/job_status_chip.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';

/// Card used in the active feed and the professor's "My Postings" list.
///
/// Provide [onEdit]/[onClose] to show the professor overflow menu.
class JobCard extends StatelessWidget {
  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
    this.onEdit,
    this.onClose,
    this.showCounts = false,
  });

  final JobModel job;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onClose;

  /// When true, shows the applicant counts row (used on `/jobs/my`).
  final bool showCounts;

  bool get _hasMenu => onEdit != null || onClose != null;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _topRow(context, l10n),
              const SizedBox(height: 12),
              Text(
                job.position,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleMedium.copyWith(
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                job.departmentName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 10),
              Text(
                job.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyLarge.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 14),
              if (showCounts)
                _countsRow(l10n)
              else ...<Widget>[
                _footerRow(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      l10n.jobSeeDetails,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        size: 16, color: AppColors.primary),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _topRow(BuildContext context, L10n l10n) {
    return Row(
      children: <Widget>[
        Icon(job.category.icon, size: 18, color: AppColors.primaryLight),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              job.localizedCategoryLabel(l10n),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Spacer(),
        JobStatusChip(job: job),
        if (_hasMenu) _menu(context),
      ],
    );
  }

  Widget _menu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
      padding: EdgeInsets.zero,
      onSelected: (String value) {
        if (value == 'edit') {
          onEdit?.call();
        } else if (value == 'close') {
          onClose?.call();
        }
      },
      itemBuilder: (BuildContext context) {
        final L10n l10n = L10n.of(context);
        return <PopupMenuEntry<String>>[
        if (onEdit != null)
          PopupMenuItem<String>(
            value: 'edit',
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.edit_outlined, size: 20),
              title: Text(l10n.actionEdit),
            ),
          ),
        if (onClose != null && job.isActive)
          PopupMenuItem<String>(
            value: 'close',
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.lock_outline, size: 20),
              title: Text(l10n.actionClosePosting),
            ),
          ),
        ];
      },
    );
  }

  Widget _footerRow() {
    return Row(
      children: <Widget>[
        DeadlineBadge(deadline: job.deadline),
        const Spacer(),
        if (job.poster != null)
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircleAvatar(
                  radius: 11,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    job.poster!.initials,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textOnPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    job.poster!.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _countsRow(L10n l10n) {
    return Row(
      children: <Widget>[
        DeadlineBadge(deadline: job.deadline),
        const Spacer(),
        const Icon(Icons.people_outline, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          l10n.applicantsCount(job.applicationCount ?? 0),
          style: AppTextStyles.caption,
        ),
        if ((job.pendingCount ?? 0) > 0) ...<Widget>[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.statusPending.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              l10n.pendingCount(job.pendingCount ?? 0),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.statusPending,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
