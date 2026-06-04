import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ytu_assistant/core/network/api_exception.dart';
import 'package:ytu_assistant/core/network/localized_error.dart';
import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/core/theme/app_text_styles.dart';
import 'package:ytu_assistant/core/utils/date_formatter.dart';
import 'package:ytu_assistant/features/auth/data/models/user_model.dart';
import 'package:ytu_assistant/features/auth/domain/user_role.dart';
import 'package:ytu_assistant/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ytu_assistant/features/jobs/data/models/job_model.dart';
import 'package:ytu_assistant/features/jobs/presentation/controllers/apply_controller.dart';
import 'package:ytu_assistant/features/jobs/presentation/controllers/job_detail_controller.dart';
import 'package:ytu_assistant/features/jobs/presentation/job_category_l10n.dart';
import 'package:ytu_assistant/features/jobs/presentation/widgets/apply_button.dart';
import 'package:ytu_assistant/features/jobs/presentation/widgets/deadline_badge.dart';
import 'package:ytu_assistant/features/jobs/presentation/widgets/empty_state.dart';
import 'package:ytu_assistant/features/jobs/presentation/widgets/job_status_chip.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';
import 'package:ytu_assistant/shared/widgets/app_snack_bar.dart';
import 'package:ytu_assistant/shared/widgets/secondary_button.dart';

class JobDetailScreen extends ConsumerWidget {
  const JobDetailScreen({super.key, required this.jobId});

  final int jobId;

  Future<void> _apply(BuildContext context, WidgetRef ref) async {
    final L10n l10n = L10n.of(context);
    try {
      await ref.read(applyControllerProvider.notifier).apply(jobId);
      if (context.mounted) {
        AppSnackBar.success(context, l10n.applicationSubmittedMsg);
      }
    } catch (error) {
      if (context.mounted) {
        AppSnackBar.error(
          context,
          localizedApiError(l10n, error, overrides: <int, String>{
            409: l10n.alreadyAppliedMsg,
            404: l10n.postingNoLongerAvailable,
          }),
        );
      }
    }
  }

  void _copyLink(BuildContext context) {
    final L10n l10n = L10n.of(context);
    Clipboard.setData(ClipboardData(text: 'ytu-assistant://jobs/$jobId'));
    AppSnackBar.info(context, l10n.linkCopiedMsg);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final L10n l10n = L10n.of(context);
    final AsyncValue<JobModel> jobAsync =
        ref.watch(jobDetailControllerProvider(jobId));

    // 404 → notify + pop back.
    ref.listen<AsyncValue<JobModel>>(jobDetailControllerProvider(jobId),
        (AsyncValue<JobModel>? prev, AsyncValue<JobModel> next) {
      final Object? error = next.error;
      if (error is ApiException && error.statusCode == 404) {
        AppSnackBar.error(context, l10n.postingNotFound);
        if (context.canPop()) {
          context.pop();
        }
      }
    });

    final UserModel? user = ref.watch(authControllerProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            tooltip: l10n.copyLinkTooltip,
            icon: const Icon(Icons.ios_share),
            onPressed: () => _copyLink(context),
          ),
        ],
      ),
      body: jobAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (Object error, _) => EmptyState(
          icon: Icons.error_outline,
          title: l10n.couldNotLoadPosting,
          subtitle: localizedApiError(l10n, error, overrides: <int, String>{
            404: l10n.thisPostingNotFound,
          }),
          actionLabel: l10n.actionGoBack,
          onAction: () => context.pop(),
        ),
        data: (JobModel job) => _Content(job: job),
      ),
      bottomNavigationBar: jobAsync.maybeWhen(
        data: (JobModel job) => _ActionBar(
          job: job,
          user: user,
          onApply: () => _apply(context, ref),
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.job});

  final JobModel job;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(job.category.icon,
                  size: 28, color: AppColors.primaryDark),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(job.localizedCategoryLabel(l10n),
                  style: AppTextStyles.label),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          job.position,
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(job.departmentName, style: AppTextStyles.bodyLarge),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            JobStatusChip(job: job),
            DeadlineBadge(deadline: job.deadline),
          ],
        ),
        const SizedBox(height: 28),
        _SectionHeader(l10n.detailAboutPosition),
        const SizedBox(height: 8),
        Text(
          job.description,
          style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
        ),
        if (job.poster != null) ...<Widget>[
          const SizedBox(height: 28),
          _SectionHeader(l10n.detailPostedBy),
          const SizedBox(height: 12),
          _PosterCard(job: job),
        ],
        const SizedBox(height: 28),
        _SectionHeader(l10n.detailTimeline),
        const SizedBox(height: 12),
        if (job.createdAt != null)
          _TimelineRow(
            icon: Icons.post_add,
            label: l10n.detailPostedLabel,
            value: DateFormatter.fullDate(job.createdAt!),
          ),
        _TimelineRow(
          icon: Icons.event,
          label: l10n.applicationDeadlineLabel,
          value: DateFormatter.fullDate(job.deadline),
        ),
        if (job.applicationCount != null)
          _TimelineRow(
            icon: Icons.people_outline,
            label: l10n.applicantsLabel,
            value: '${job.applicationCount}',
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
    );
  }
}

class _PosterCard extends StatelessWidget {
  const _PosterCard({required this.job});

  final JobModel job;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary,
              child: Text(
                job.poster!.initials,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(job.poster!.fullName, style: AppTextStyles.titleMedium),
                  if ((job.poster!.email ?? '').isNotEmpty) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(job.poster!.email!, style: AppTextStyles.bodyMedium),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(label, style: AppTextStyles.bodyMedium),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sticky bottom action bar, role/ownership-aware.
class _ActionBar extends ConsumerWidget {
  const _ActionBar({
    required this.job,
    required this.user,
    required this.onApply,
  });

  final JobModel job;
  final UserModel? user;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final L10n l10n = L10n.of(context);

    if (user == null) {
      return const SizedBox.shrink();
    }

    final bool isProfessor = user!.role == UserRole.professor;
    final bool isOwner = job.userId != null && job.userId == user!.userId;

    if (isProfessor && !isOwner) {
      return const SizedBox.shrink();
    }

    Widget child;
    if (isProfessor) {
      child = Row(
        children: <Widget>[
          Expanded(
            child: SecondaryButton(
              label: l10n.viewApplicantsAction,
              icon: Icons.people_outline,
              onPressed: () => context.push('/jobs/${job.jobId}/applicants'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/jobs/${job.jobId}/edit'),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(l10n.actionEdit),
              ),
            ),
          ),
        ],
      );
    } else {
      final bool applying = ref.watch(applyControllerProvider).isLoading;
      child = ApplyButton(
        state: _applyState(applying),
        onPressed: onApply,
      );
    }

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        padding: const EdgeInsets.only(top: 12),
        child: child,
      ),
    );
  }

  ApplyButtonState _applyState(bool applying) {
    if (job.hasApplied) {
      return ApplyButtonState.applied;
    }
    if (!job.isActive) {
      return ApplyButtonState.closed;
    }
    if (job.isExpired) {
      return ApplyButtonState.expired;
    }
    if (applying) {
      return ApplyButtonState.loading;
    }
    return ApplyButtonState.idle;
  }
}
