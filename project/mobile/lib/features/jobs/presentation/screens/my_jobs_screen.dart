import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ytu_assistant/core/network/localized_error.dart';
import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/features/jobs/data/jobs_repository.dart';
import 'package:ytu_assistant/features/jobs/data/models/job_model.dart';
import 'package:ytu_assistant/features/jobs/presentation/controllers/job_detail_controller.dart';
import 'package:ytu_assistant/features/jobs/presentation/controllers/my_jobs_controller.dart';
import 'package:ytu_assistant/features/jobs/presentation/widgets/empty_state.dart';
import 'package:ytu_assistant/features/jobs/presentation/widgets/job_card.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';
import 'package:ytu_assistant/shared/widgets/app_snack_bar.dart';
import 'package:ytu_assistant/shared/widgets/skeleton_box.dart';

/// Professor's ACTIVE postings (`/my-jobs`). Active = `is_active == true` AND
/// deadline not passed (i.e. [JobModel.isOpen]).
class MyJobsScreen extends ConsumerWidget {
  const MyJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final L10n l10n = L10n.of(context);
    final AsyncValue<List<JobModel>> jobsAsync =
        ref.watch(myJobsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navActivePostings),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.newPostingTooltip,
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/jobs/new'),
          ),
        ],
      ),
      body: jobsAsync.when(
        loading: () => const MyJobsSkeleton(),
        error: (Object error, _) => _ErrorView(error: error),
        data: (List<JobModel> jobs) => PostingsList(
          jobs: jobs.where((JobModel j) => j.isOpen).toList(),
          variant: PostingsVariant.active,
        ),
      ),
    );
  }
}

/// Professor's INACTIVE postings (`/my-jobs/closed`). Inactive = `is_active ==
/// false` OR deadline passed (i.e. NOT [JobModel.isOpen]).
class ClosedJobsScreen extends ConsumerWidget {
  const ClosedJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final L10n l10n = L10n.of(context);
    final AsyncValue<List<JobModel>> jobsAsync =
        ref.watch(myJobsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navInactivePostings)),
      body: jobsAsync.when(
        loading: () => const MyJobsSkeleton(),
        error: (Object error, _) => _ErrorView(error: error),
        data: (List<JobModel> jobs) => PostingsList(
          jobs: jobs.where((JobModel j) => !j.isOpen).toList(),
          variant: PostingsVariant.inactive,
        ),
      ),
    );
  }
}

class _ErrorView extends ConsumerWidget {
  const _ErrorView({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final L10n l10n = L10n.of(context);
    return EmptyState(
      icon: Icons.cloud_off_outlined,
      title: l10n.myJobsErrorTitle,
      subtitle: localizedApiError(l10n, error),
      actionLabel: l10n.actionRetry,
      onAction: () => ref.read(myJobsControllerProvider.notifier).refresh(),
    );
  }
}

enum PostingsVariant { active, inactive }

/// Shared list body for both professor postings screens (same JobCard + the
/// same per-card overflow actions: Düzenle / Kapat).
class PostingsList extends ConsumerWidget {
  const PostingsList({super.key, required this.jobs, required this.variant});

  final List<JobModel> jobs;
  final PostingsVariant variant;

  bool get _isActive => variant == PostingsVariant.active;

  Future<void> _confirmClose(
    BuildContext context,
    WidgetRef ref,
    L10n l10n,
    JobModel job,
  ) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(l10n.closePostingTitle),
        content: Text(l10n.closePostingBody(job.position)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.actionClosePosting),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) {
      return;
    }
    try {
      await ref.read(jobsRepositoryProvider).closeJob(job.jobId);
      ref.invalidate(myJobsControllerProvider);
      ref.invalidate(jobDetailControllerProvider(job.jobId));
      if (context.mounted) {
        AppSnackBar.success(context, l10n.postingClosedSuccess);
      }
    } catch (error) {
      if (context.mounted) {
        AppSnackBar.error(
          context,
          localizedApiError(l10n, error, overrides: <int, String>{
            403: l10n.errorForbidden,
            404: l10n.errorNotFound,
          }),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final L10n l10n = L10n.of(context);

    if (jobs.isEmpty) {
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.read(myJobsControllerProvider.notifier).refresh(),
        child: ListView(
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height * 0.16),
            EmptyState(
              icon: _isActive
                  ? Icons.post_add_outlined
                  : Icons.inventory_2_outlined,
              title: _isActive
                  ? l10n.myJobsEmptyActiveTitle
                  : l10n.myJobsEmptyInactiveTitle,
              subtitle: _isActive
                  ? l10n.myJobsEmptyActiveSubtitle
                  : l10n.myJobsEmptyInactiveSubtitle,
              actionLabel: _isActive ? l10n.actionCreatePosting : null,
              onAction: _isActive ? () => context.push('/jobs/new') : null,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(myJobsControllerProvider.notifier).refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: jobs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (BuildContext context, int index) {
          final JobModel job = jobs[index];
          return JobCard(
            job: job,
            showCounts: true,
            onTap: () => context.push('/jobs/${job.jobId}'),
            onEdit: () => context.push('/jobs/${job.jobId}/edit'),
            // JobCard only renders "Close" when the job is still is_active,
            // so this is safe to pass on both screens.
            onClose: () => _confirmClose(context, ref, l10n, job),
          );
        },
      ),
    );
  }
}

class MyJobsSkeleton extends StatelessWidget {
  const MyJobsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SkeletonBox(width: 120, height: 22, borderRadius: 999),
            SizedBox(height: 14),
            SkeletonBox(width: 200, height: 18),
            SizedBox(height: 8),
            SkeletonBox(width: 140, height: 14),
            SizedBox(height: 14),
            SkeletonBox(width: 180, height: 12),
          ],
        ),
      ),
    );
  }
}
