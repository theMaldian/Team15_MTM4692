import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/features/applications/data/applications_api.dart';
import 'package:ytu_assistant/features/applications/data/models/application_model.dart';
import 'package:ytu_assistant/features/jobs/domain/application_status.dart';

/// Pure data layer over [ApplicationsApi]. Cache invalidation after mutations
/// is owned by the controllers (matching the jobs feature convention).
class ApplicationsRepository {
  ApplicationsRepository(this._api);

  final ApplicationsApi _api;

  Future<List<ApplicationModel>> fetchMine() => _api.fetchMine();

  Future<void> withdraw(int applicationId) => _api.withdraw(applicationId);

  Future<void> updateStatus(int applicationId, ApplicationStatus status) =>
      _api.updateStatus(applicationId, status);
}

final applicationsRepositoryProvider = Provider<ApplicationsRepository>((ref) {
  return ApplicationsRepository(ref.watch(applicationsApiProvider));
});
