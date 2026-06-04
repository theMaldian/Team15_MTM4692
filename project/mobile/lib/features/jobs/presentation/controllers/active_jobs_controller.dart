import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/features/jobs/data/jobs_repository.dart';
import 'package:ytu_assistant/features/jobs/data/models/job_model.dart';
import 'package:ytu_assistant/features/jobs/domain/job_category.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';

/// Sort options for the active jobs feed (applied client-side).
enum JobSort { newest, deadlineSoonest }

extension JobSortLabel on JobSort {
  String localizedLabel(L10n l10n) {
    switch (this) {
      case JobSort.newest:
        return l10n.sortNewest;
      case JobSort.deadlineSoonest:
        return l10n.sortDeadlineSoonest;
    }
  }
}

/// Filter state for the active jobs feed. `/jobs/active` does NOT support
/// server-side filtering, so everything here is applied client-side.
class JobFilterState {
  const JobFilterState({
    this.categories = const <JobCategory>{},
    this.department = '',
    this.sort = JobSort.newest,
  });

  final Set<JobCategory> categories;
  final String department;
  final JobSort sort;

  bool get isActive => categories.isNotEmpty || department.trim().isNotEmpty;

  int get activeFilterCount =>
      categories.length + (department.trim().isEmpty ? 0 : 1);

  JobFilterState copyWith({
    Set<JobCategory>? categories,
    String? department,
    JobSort? sort,
  }) {
    return JobFilterState(
      categories: categories ?? this.categories,
      department: department ?? this.department,
      sort: sort ?? this.sort,
    );
  }
}

/// Holds the current filter selections for the active jobs feed.
final jobFilterProvider =
    StateProvider<JobFilterState>((ref) => const JobFilterState());

/// Active jobs feed (student-facing). Fetches once and applies the current
/// [jobFilterProvider] client-side, re-deriving when the filter changes.
class ActiveJobsController extends AsyncNotifier<List<JobModel>> {
  @override
  Future<List<JobModel>> build() async {
    final JobFilterState filter = ref.watch(jobFilterProvider);
    final List<JobModel> jobs =
        await ref.read(jobsRepositoryProvider).fetchActive();
    return _applyFilter(jobs, filter);
  }

  Future<void> refresh() async {
    state = const AsyncLoading<List<JobModel>>();
    state = await AsyncValue.guard<List<JobModel>>(() async {
      final JobFilterState filter = ref.read(jobFilterProvider);
      final List<JobModel> jobs =
          await ref.read(jobsRepositoryProvider).fetchActive();
      return _applyFilter(jobs, filter);
    });
  }

  List<JobModel> _applyFilter(List<JobModel> jobs, JobFilterState filter) {
    Iterable<JobModel> result = jobs;

    if (filter.categories.isNotEmpty) {
      result = result
          .where((JobModel j) => filter.categories.contains(j.category));
    }

    final String dept = filter.department.trim().toLowerCase();
    if (dept.isNotEmpty) {
      result = result.where(
        (JobModel j) => j.departmentName.toLowerCase().contains(dept),
      );
    }

    final List<JobModel> list = result.toList();
    switch (filter.sort) {
      case JobSort.newest:
        list.sort((JobModel a, JobModel b) {
          final DateTime ad = a.createdAt ?? a.deadline;
          final DateTime bd = b.createdAt ?? b.deadline;
          return bd.compareTo(ad);
        });
        break;
      case JobSort.deadlineSoonest:
        list.sort((JobModel a, JobModel b) => a.deadline.compareTo(b.deadline));
        break;
    }
    return list;
  }
}

final activeJobsControllerProvider =
    AsyncNotifierProvider<ActiveJobsController, List<JobModel>>(
  ActiveJobsController.new,
);
