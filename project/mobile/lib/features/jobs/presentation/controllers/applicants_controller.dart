import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/features/jobs/data/jobs_repository.dart';
import 'package:ytu_assistant/features/jobs/data/models/applicant_model.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';

/// Sort options for the applicants list (client-side).
enum ApplicantSort { newest, gpaDesc }

extension ApplicantSortLabel on ApplicantSort {
  String localizedLabel(L10n l10n) {
    switch (this) {
      case ApplicantSort.newest:
        return l10n.sortNewest;
      case ApplicantSort.gpaDesc:
        return l10n.sortGpaHighToLow;
    }
  }
}

/// Applicants for a job, keyed by job id. The backend enforces that only the
/// owner professor can read these; a 403 surfaces as an error state.
class ApplicantsController
    extends FamilyAsyncNotifier<List<ApplicantModel>, int> {
  late int _jobId;

  @override
  Future<List<ApplicantModel>> build(int arg) {
    _jobId = arg;
    return ref.read(jobsRepositoryProvider).fetchApplicants(arg);
  }

  Future<void> refresh() async {
    state = const AsyncLoading<List<ApplicantModel>>();
    state = await AsyncValue.guard<List<ApplicantModel>>(
      () => ref.read(jobsRepositoryProvider).fetchApplicants(_jobId),
    );
  }
}

final applicantsControllerProvider = AsyncNotifierProvider.family<
    ApplicantsController, List<ApplicantModel>, int>(
  ApplicantsController.new,
);

/// Holds the applicants sort selection (per screen instance is fine here).
final applicantSortProvider =
    StateProvider.autoDispose<ApplicantSort>((ref) => ApplicantSort.newest);
