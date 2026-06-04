import 'package:ytu_assistant/core/network/api_exception.dart';

/// Maps an error to user-facing text following the app's error-UX rules.
///
/// [overrides] lets a caller supply a custom message for specific status codes
/// (e.g. `{409: 'You have already applied to this job'}`). Transport-level
/// failures (no status) become a connection message; 5xx becomes a generic
/// retry message.
String apiErrorText(
  Object error, {
  Map<int, String> overrides = const <int, String>{},
  String fallback = 'Something went wrong. Please try again.',
}) {
  if (error is! ApiException) {
    return fallback;
  }
  final int? status = error.statusCode;
  if (status == null) {
    return 'Connection error. Check your internet and try again.';
  }
  if (overrides.containsKey(status)) {
    return overrides[status]!;
  }
  if (status >= 500) {
    return fallback;
  }
  // 400 / 401 / 403 / 404 / 409 / 422 → backend's message (it's user-readable).
  return error.message;
}
