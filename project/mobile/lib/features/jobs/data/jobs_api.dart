import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/core/network/api_client.dart';
import 'package:ytu_assistant/core/network/api_endpoints.dart';
import 'package:ytu_assistant/features/jobs/data/models/applicant_model.dart';
import 'package:ytu_assistant/features/jobs/data/models/job_model.dart';
import 'package:ytu_assistant/features/jobs/data/models/job_requests.dart';

/// Dio wrapper for `/jobs/*`. Errors are already normalized to `ApiException`
/// by the [ApiClient] interceptor.
///
/// NOTE: `/jobs/active` supports NO server-side filtering — callers filter
/// client-side. `closeJob` uses PATCH (per BACKEND_API.md), `applyToJob` uses
/// POST with no body.
class JobsApi {
  JobsApi(this._client);

  final ApiClient _client;

  Future<List<JobModel>> fetchActive() async {
    final dynamic body = await _client.get(ApiEndpoints.activeJobs);
    return _jobList(body);
  }

  Future<List<JobModel>> fetchMyJobs() async {
    final dynamic body = await _client.get(ApiEndpoints.myJobs);
    return _jobList(body);
  }

  Future<JobModel> fetchJob(int id) async {
    final dynamic body = await _client.get(ApiEndpoints.job(id));
    return JobModel.fromJson(_job(body));
  }

  Future<JobModel> createJob(CreateJobRequest req) async {
    final dynamic body =
        await _client.post(ApiEndpoints.jobs, data: req.toJson());
    return JobModel.fromJson(_job(body));
  }

  Future<JobModel> updateJob(int id, UpdateJobRequest req) async {
    final dynamic body =
        await _client.put(ApiEndpoints.job(id), data: req.toJson());
    return JobModel.fromJson(_job(body));
  }

  Future<void> closeJob(int id) async {
    await _client.patch(ApiEndpoints.closeJob(id));
  }

  Future<void> applyToJob(int id) async {
    await _client.post(ApiEndpoints.applyToJob(id));
  }

  Future<List<ApplicantModel>> fetchApplicants(int jobId) async {
    final dynamic body = await _client.get(ApiEndpoints.jobApplicants(jobId));
    final Map<String, dynamic> map = _asMap(body);
    final dynamic rawList = map['applicants'];
    if (rawList is! List) {
      return <ApplicantModel>[];
    }
    return rawList
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> e) =>
            ApplicantModel.fromJson(_castMap(e)))
        .toList();
  }

  // ---- helpers ----

  List<JobModel> _jobList(dynamic body) {
    final Map<String, dynamic> map = _asMap(body);
    final dynamic rawList = map['jobs'];
    if (rawList is! List) {
      return <JobModel>[];
    }
    return rawList
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> e) => JobModel.fromJson(_castMap(e)))
        .toList();
  }

  Map<String, dynamic> _job(dynamic body) {
    final Map<String, dynamic> map = _asMap(body);
    final dynamic job = map['job'];
    if (job is Map) {
      return _castMap(job);
    }
    // Some responses might already be the bare job object.
    return map;
  }

  static Map<String, dynamic> _asMap(dynamic body) {
    if (body is Map<String, dynamic>) {
      return body;
    }
    if (body is Map) {
      return _castMap(body);
    }
    return <String, dynamic>{};
  }

  static Map<String, dynamic> _castMap(Map<dynamic, dynamic> raw) {
    return raw.map((Object? key, Object? value) =>
        MapEntry<String, dynamic>(key.toString(), value));
  }
}

/// Riverpod provider for [JobsApi].
final jobsApiProvider = Provider<JobsApi>((ref) {
  return JobsApi(ref.watch(apiClientProvider));
});
