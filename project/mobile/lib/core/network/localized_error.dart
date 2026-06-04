import 'package:ytu_assistant/core/network/api_exception.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';

/// Localized counterpart to [apiErrorText]. Maps an error to a user-facing,
/// translated message following the app's error-UX rules.
///
/// [overrides] supplies a localized message for specific status codes
/// (e.g. `{403: l10n.errorForbidden}`). Transport-level failures (no status)
/// become a connection message; 5xx becomes the generic retry message; other
/// 4xx fall back to the backend's (already human-readable) message.
String localizedApiError(
  L10n l10n,
  Object error, {
  Map<int, String> overrides = const <int, String>{},
}) {
  if (error is! ApiException) {
    return l10n.errorGeneric;
  }
  final int? status = error.statusCode;
  if (status == null) {
    return l10n.errorConnection;
  }
  if (overrides.containsKey(status)) {
    return overrides[status]!;
  }
  if (status >= 500) {
    return l10n.errorGeneric;
  }
  return error.message;
}
