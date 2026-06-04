import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/features/jobs/data/jobs_repository.dart';
import 'package:ytu_assistant/features/jobs/data/models/job_model.dart';
import 'package:ytu_assistant/features/jobs/data/models/job_requests.dart';
import 'package:ytu_assistant/features/jobs/presentation/controllers/job_detail_controller.dart';
import 'package:ytu_assistant/features/jobs/presentation/controllers/my_jobs_controller.dart';

/// Handles create + update submission for the job form.
class JobFormController extends AutoDisposeAsyncNotifier<JobModel?> {
  @override
  Future<JobModel?> build() async => null;

  /// Create when [jobId] is null, otherwise update. On success, invalidates the
  /// professor's list and (for edits) the affected detail provider.
  Future<JobModel> submitCreate(CreateJobRequest req) async {
    state = const AsyncLoading<JobModel?>();
    final AsyncValue<JobModel?> result =
        await AsyncValue.guard<JobModel?>(() async {
      return ref.read(jobsRepositoryProvider).createJob(req);
    });
    state = result;
    final Object? error = result.error;
    if (error != null) {
      throw error;
    }
    ref.invalidate(myJobsControllerProvider);
    return result.value!;
  }

  Future<JobModel> submitUpdate(int jobId, UpdateJobRequest req) async {
    state = const AsyncLoading<JobModel?>();
    final AsyncValue<JobModel?> result =
        await AsyncValue.guard<JobModel?>(() async {
      return ref.read(jobsRepositoryProvider).updateJob(jobId, req);
    });
    state = result;
    final Object? error = result.error;
    if (error != null) {
      throw error;
    }
    ref.invalidate(myJobsControllerProvider);
    ref.invalidate(jobDetailControllerProvider(jobId));
    return result.value!;
  }
}

final jobFormControllerProvider =
    AutoDisposeAsyncNotifierProvider<JobFormController, JobModel?>(
  JobFormController.new,
);
