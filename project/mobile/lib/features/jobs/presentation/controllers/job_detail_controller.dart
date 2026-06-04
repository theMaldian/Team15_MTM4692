import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/features/jobs/data/jobs_repository.dart';
import 'package:ytu_assistant/features/jobs/data/models/job_model.dart';

/// Single job detail, keyed by job id.
class JobDetailController
    extends FamilyAsyncNotifier<JobModel, int> {
  late int _jobId;

  @override
  Future<JobModel> build(int arg) {
    _jobId = arg;
    return ref.read(jobsRepositoryProvider).fetchJob(arg);
  }

  Future<void> refresh() async {
    state = const AsyncLoading<JobModel>();
    state = await AsyncValue.guard<JobModel>(
      () => ref.read(jobsRepositoryProvider).fetchJob(_jobId),
    );
  }

  /// Professor action: close (deactivate) this posting, then refresh.
  Future<void> close() async {
    await ref.read(jobsRepositoryProvider).closeJob(_jobId);
    await refresh();
  }
}

final jobDetailControllerProvider =
    AsyncNotifierProvider.family<JobDetailController, JobModel, int>(
  JobDetailController.new,
);
