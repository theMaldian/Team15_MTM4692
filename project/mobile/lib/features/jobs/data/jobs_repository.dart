import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/features/jobs/data/jobs_api.dart';
import 'package:ytu_assistant/features/jobs/data/models/applicant_model.dart';
import 'package:ytu_assistant/features/jobs/data/models/job_model.dart';
import 'package:ytu_assistant/features/jobs/data/models/job_requests.dart';

/// Pure data layer over [JobsApi]. Cache invalidation after mutations is
/// performed by the controllers (see presentation/controllers/*), which own
/// the provider graph — keeping this class free of `Ref`/UI coupling.
class JobsRepository {
  JobsRepository(this._api);

  final JobsApi _api;

  Future<List<JobModel>> fetchActive() => _api.fetchActive();

  Future<List<JobModel>> fetchMyJobs() => _api.fetchMyJobs();

  Future<JobModel> fetchJob(int id) => _api.fetchJob(id);

  Future<JobModel> createJob(CreateJobRequest req) => _api.createJob(req);

  Future<JobModel> updateJob(int id, UpdateJobRequest req) =>
      _api.updateJob(id, req);

  Future<void> closeJob(int id) => _api.closeJob(id);

  Future<void> applyToJob(int id) => _api.applyToJob(id);

  Future<List<ApplicantModel>> fetchApplicants(int jobId) =>
      _api.fetchApplicants(jobId);
}

/// Riverpod provider for [JobsRepository].
final jobsRepositoryProvider = Provider<JobsRepository>((ref) {
  return JobsRepository(ref.watch(jobsApiProvider));
});
