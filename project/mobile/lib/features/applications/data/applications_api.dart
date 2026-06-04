import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/core/network/api_client.dart';
import 'package:ytu_assistant/core/network/api_endpoints.dart';
import 'package:ytu_assistant/features/applications/data/models/application_model.dart';
import 'package:ytu_assistant/features/jobs/domain/application_status.dart';

/// Dio wrapper for `/applications/*`. Errors are normalized to `ApiException`
/// by the [ApiClient] interceptor.
class ApplicationsApi {
  ApplicationsApi(this._client);

  final ApiClient _client;

  /// `GET /applications/my` — student's own applications.
  Future<List<ApplicationModel>> fetchMine() async {
    final dynamic body = await _client.get(ApiEndpoints.myApplications);
    final Map<String, dynamic> map = _asMap(body);
    final dynamic raw = map['applications'];
    if (raw is! List) {
      return <ApplicationModel>[];
    }
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> e) =>
            ApplicationModel.fromJson(_castMap(e)))
        .toList();
  }

  /// `DELETE /applications/:applicationId` — student withdraws their application.
  Future<void> withdraw(int applicationId) async {
    await _client.delete(ApiEndpoints.application(applicationId));
  }

  /// `PATCH /applications/:applicationId/status` — professor sets approved/rejected.
  Future<void> updateStatus(
    int applicationId,
    ApplicationStatus status,
  ) async {
    await _client.patch(
      ApiEndpoints.applicationStatus(applicationId),
      data: <String, dynamic>{'status': status.wireValue},
    );
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

final applicationsApiProvider = Provider<ApplicationsApi>((ref) {
  return ApplicationsApi(ref.watch(apiClientProvider));
});
