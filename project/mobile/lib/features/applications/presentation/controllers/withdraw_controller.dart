import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/features/applications/data/applications_repository.dart';
import 'package:ytu_assistant/features/applications/presentation/controllers/my_applications_controller.dart';
import 'package:ytu_assistant/features/jobs/presentation/controllers/active_jobs_controller.dart';
import 'package:ytu_assistant/features/jobs/presentation/controllers/job_detail_controller.dart';

/// Student "withdraw application" action. Separate from the list controller so
/// the card can show its own loading state. Propagates the `ApiException`
/// (e.g. withdraw-after-review) for SnackBar handling.
class WithdrawController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> withdraw(int applicationId, {int? jobId}) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard<void>(
      () => ref.read(applicationsRepositoryProvider).withdraw(applicationId),
    );
    final Object? error = state.error;
    if (error != null) {
      throw error;
    }
    ref.invalidate(myApplicationsControllerProvider);
    ref.invalidate(activeJobsControllerProvider);
    if (jobId != null) {
      ref.invalidate(jobDetailControllerProvider(jobId));
    }
  }
}

final withdrawControllerProvider =
    AutoDisposeAsyncNotifierProvider<WithdrawController, void>(
  WithdrawController.new,
);
