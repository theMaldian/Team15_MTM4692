import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/core/constants/app_constants.dart';
import 'package:ytu_assistant/core/network/api_exception.dart';
import 'package:ytu_assistant/core/storage/secure_storage.dart';

/// Broadcasts auth lifecycle events (currently: forced logout on 401).
///
/// The router listens to this so it can redirect to the login screen when the
/// session expires. Kept deliberately tiny — a [ChangeNotifier] with a counter
/// so listeners can react to repeated logout signals.
class AuthEvents extends ChangeNotifier {
  int _logoutSignal = 0;

  /// Increments every time a forced logout is requested.
  int get logoutSignal => _logoutSignal;

  /// Called by the [ApiClient] when the backend returns 401.
  void notifyLogout() {
    _logoutSignal++;
    notifyListeners();
  }
}

/// Dio-based HTTP client for the YTU backend.
///
/// - Attaches `Authorization: Bearer <token>` when a token is stored.
/// - Normalizes errors into [ApiException].
/// - On 401, clears the token and emits a logout event via [AuthEvents].
class ApiClient {
  ApiClient({
    required SecureStorage storage,
    required AuthEvents authEvents,
    Dio? dio,
  })  : _storage = storage,
        _authEvents = authEvents,
        _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = AppConstants.baseUrl
      ..connectTimeout = AppConstants.connectTimeout
      ..receiveTimeout = AppConstants.receiveTimeout
      ..contentType = Headers.jsonContentType
      ..responseType = ResponseType.json;

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (Object obj) => debugPrint(obj.toString()),
        ),
      );
    }
  }

  final Dio _dio;
  final SecureStorage _storage;
  final AuthEvents _authEvents;

  /// Exposed for advanced callers; prefer the typed helpers below.
  Dio get dio => _dio;

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String? token = await _storage.readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (error.response?.statusCode == 401) {
      // Session expired / invalid token: clear and notify the router.
      await _storage.clear();
      _authEvents.notifyLogout();
    }
    handler.next(error);
  }

  // ---- Typed verbs: return the decoded JSON body, throw [ApiException]. ----

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _request(() => _dio.get(path, queryParameters: queryParameters));
  }

  Future<dynamic> post(String path, {Object? data}) {
    return _request(() => _dio.post(path, data: data));
  }

  Future<dynamic> put(String path, {Object? data}) {
    return _request(() => _dio.put(path, data: data));
  }

  Future<dynamic> patch(String path, {Object? data}) {
    return _request(() => _dio.patch(path, data: data));
  }

  Future<dynamic> delete(String path, {Object? data}) {
    return _request(() => _dio.delete(path, data: data));
  }

  Future<dynamic> _request(Future<Response<dynamic>> Function() send) async {
    try {
      final Response<dynamic> response = await send();
      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }
}

/// Riverpod provider for [AuthEvents] (logout broadcaster).
final authEventsProvider = ChangeNotifierProvider<AuthEvents>((ref) {
  return AuthEvents();
});

/// Riverpod provider for the app-wide [ApiClient].
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    storage: ref.watch(secureStorageProvider),
    authEvents: ref.watch(authEventsProvider),
  );
});
