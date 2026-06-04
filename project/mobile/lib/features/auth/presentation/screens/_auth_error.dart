import 'package:ytu_assistant/core/network/api_exception.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';

/// Maps an [ApiException] (or any other error) to a user-friendly message.
///
/// Pass [l10n] to localize the generic / connection fallbacks; without it the
/// messages fall back to English. Status-specific overrides ([on401] etc.)
/// should already be localized by the caller.
String authErrorMessage(
  Object error, {
  L10n? l10n,
  String? on401,
  String? on403,
  String? on409,
}) {
  String generic() =>
      l10n?.errorGeneric ?? 'Something went wrong. Please try again.';
  String connection() =>
      l10n?.errorConnection ??
      'Connection error. Check your internet and try again.';

  if (error is! ApiException) {
    return generic();
  }
  final int? status = error.statusCode;
  if (status == null) {
    // Transport-level (timeout, no host).
    return connection();
  }
  if (status == 401) {
    return on401 ?? error.message;
  }
  if (status == 403) {
    return on403 ?? error.message;
  }
  if (status == 409) {
    return on409 ?? error.message;
  }
  if (status >= 500) {
    return generic();
  }
  // 400 / 404 / 422 — fall back to backend's message.
  return error.message;
}
