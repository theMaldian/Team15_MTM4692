import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ytu_assistant/core/network/api_exception.dart';
import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/features/jobs/data/models/job_model.dart';
import 'package:ytu_assistant/features/jobs/presentation/controllers/active_jobs_controller.dart';
import 'package:ytu_assistant/features/jobs/presentation/widgets/empty_state.dart';
import 'package:ytu_assistant/features/jobs/presentation/widgets/job_card.dart';
import 'package:ytu_assistant/features/jobs/presentation/widgets/job_filter_bar.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';
import 'package:ytu_assistant/shared/widgets/app_snack_bar.dart';
import 'package:ytu_assistant/shared/widgets/skeleton_box.dart';

/// Active jobs feed. Student landing screen; professors can also reach it via
/// the "Browse" tab (the backend restricts `/jobs/active` to students, so a
/// professor sees a friendly notice instead of a list).
class JobListScreen extends ConsumerStatefulWidget {
  const JobListScreen({super.key});

  @override
  ConsumerState<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends ConsumerState<JobListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowDenied());
  }

  void _maybeShowDenied() {
    if (!mounted) {
      return;
    }
    final String? denied =
        GoRouterState.of(context).uri.queryParameters['denied'];
    if (denied == 'students') {
      AppSnackBar.error(context, L10n.of(context).deniedForStudents);
    }
  }

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final AsyncValue<List<JobModel>> jobsAsync =
        ref.watch(activeJobsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.jobsTitle),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.filterTooltip,
            icon: const Icon(Icons.tune),
            onPressed: () => JobFilterSheet.show(context),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          const JobFilterBar(),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () =>
                  ref.read(activeJobsControllerProvider.notifier).refresh(),
              child: jobsAsync.when(
                skipLoadingOnReload: true,
                loading: () => const _JobListSkeleton(),
                error: (Object error, _) => _errorView(error),
                data: (List<JobModel> jobs) => _list(jobs),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(List<JobModel> jobs) {
    final L10n l10n = L10n.of(context);
    if (jobs.isEmpty) {
      final bool filtered = ref.read(jobFilterProvider).isActive;
      return ListView(
        children: <Widget>[
          SizedBox(height: MediaQuery.of(context).size.height * 0.18),
          EmptyState(
            icon: filtered ? Icons.filter_alt_off : Icons.work_off_outlined,
            title: filtered ? l10n.emptyNoMatchTitle : l10n.emptyNoPostingsTitle,
            subtitle: filtered
                ? l10n.emptyNoMatchSubtitle
                : l10n.emptyNoPostingsSubtitle,
            actionLabel: filtered ? l10n.actionClearFilters : null,
            onAction: filtered
                ? () => ref.read(jobFilterProvider.notifier).state =
                    const JobFilterState()
                : null,
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (BuildContext context, int index) {
        final JobModel job = jobs[index];
        return JobCard(
          job: job,
          onTap: () => context.push('/jobs/${job.jobId}'),
        );
      },
    );
  }

  Widget _errorView(Object error) {
    final L10n l10n = L10n.of(context);
    final bool professorBlocked =
        error is ApiException && error.statusCode == 403;
    return ListView(
      children: <Widget>[
        SizedBox(height: MediaQuery.of(context).size.height * 0.16),
        EmptyState(
          icon: professorBlocked
              ? Icons.school_outlined
              : Icons.cloud_off_outlined,
          title:
              professorBlocked ? l10n.studentOnlyTitle : l10n.errorLoadTitle,
          subtitle: professorBlocked
              ? l10n.studentOnlySubtitle
              : l10n.errorLoadSubtitle,
          actionLabel: professorBlocked ? null : l10n.actionRetry,
          onAction: professorBlocked
              ? null
              : () =>
                  ref.read(activeJobsControllerProvider.notifier).refresh(),
        ),
      ],
    );
  }
}

class _JobListSkeleton extends StatelessWidget {
  const _JobListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
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
            Row(
              children: <Widget>[
                SkeletonBox(width: 110, height: 22, borderRadius: 999),
                Spacer(),
                SkeletonBox(width: 64, height: 22, borderRadius: 999),
              ],
            ),
            SizedBox(height: 14),
            SkeletonBox(width: 200, height: 18),
            SizedBox(height: 8),
            SkeletonBox(width: 140, height: 14),
            SizedBox(height: 14),
            SkeletonBox(height: 12),
            SizedBox(height: 6),
            SkeletonBox(width: 240, height: 12),
          ],
        ),
      ),
    );
  }
}
