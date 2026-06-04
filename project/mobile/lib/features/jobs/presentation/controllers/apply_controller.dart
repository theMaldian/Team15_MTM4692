import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/features/applications/presentation/controllers/my_applications_controller.dart';
import 'package:ytu_assistant/features/jobs/data/jobs_repository.dart';
import 'package:ytu_assistant/features/jobs/presentation/controllers/active_jobs_controller.dart';
import 'package:ytu_assistant/features/jobs/presentation/controllers/job_detail_controller.dart';

/// Student "apply" action state. Kept separate from the detail controller so
/// the apply button can show its own loading state.
class ApplyController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Applies to [jobId]. Propagates the `ApiException` (incl. 409 already
  /// applied) to the caller for SnackBar handling. On success, refreshes the
  /// detail (so `my_application_*` updates) and the active feed.
  Future<void> apply(int jobId) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard<void>(() {
      return ref.read(jobsRepositoryProvider).applyToJob(jobId);
    });
    final Object? error = state.error;
    if (error != null) {
      throw error;
    }
    // Refresh detail so the apply button flips to "Applied".
    ref.invalidate(jobDetailControllerProvider(jobId));
    ref.invalidate(activeJobsControllerProvider);
    ref.invalidate(myApplicationsControllerProvider);
  }
}

final applyControllerProvider =
    AutoDisposeAsyncNotifierProvider<ApplyController, void>(
  ApplyController.new,
);
