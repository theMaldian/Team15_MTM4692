import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/features/auth/data/models/user_model.dart';
import 'package:ytu_assistant/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ytu_assistant/features/jobs/data/jobs_repository.dart';
import 'package:ytu_assistant/features/jobs/data/models/job_model.dart';

/// Professor's own postings (`/jobs/my`). The backend enforces the professor
/// role; the UI only reaches this for professors.
class MyJobsController extends AsyncNotifier<List<JobModel>> {
  @override
  Future<List<JobModel>> build() {
    // Long-lived provider: re-run when the signed-in user changes so a new
    // professor never sees the previous professor's postings.
    ref.watch(
      authControllerProvider.select(
        (AsyncValue<UserModel?> auth) => auth.valueOrNull?.userId,
      ),
    );
    return ref.read(jobsRepositoryProvider).fetchMyJobs();
  }

  Future<void> refresh() async {
    state = const AsyncLoading<List<JobModel>>();
    state = await AsyncValue.guard<List<JobModel>>(
      () => ref.read(jobsRepositoryProvider).fetchMyJobs(),
    );
  }
}

final myJobsControllerProvider =
    AsyncNotifierProvider<MyJobsController, List<JobModel>>(
  MyJobsController.new,
);
