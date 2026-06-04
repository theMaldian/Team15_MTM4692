import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/features/applications/data/applications_repository.dart';
import 'package:ytu_assistant/features/jobs/domain/application_status.dart';
import 'package:ytu_assistant/features/jobs/presentation/controllers/applicants_controller.dart';

/// Professor action: set an applicant's status (`approved` / `rejected`) via
/// `PATCH /applications/:id/status`. Invalidates the applicants list for the job.
class ApplicantStatusController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> setStatus({
    required int applicationId,
    required int jobId,
    required ApplicationStatus status,
  }) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard<void>(
      () => ref
          .read(applicationsRepositoryProvider)
          .updateStatus(applicationId, status),
    );
    final Object? error = state.error;
    if (error != null) {
      throw error;
    }
    ref.invalidate(applicantsControllerProvider(jobId));
  }
}

final applicantStatusControllerProvider =
    AutoDisposeAsyncNotifierProvider<ApplicantStatusController, void>(
  ApplicantStatusController.new,
);
