import 'dart:async';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../constants/api_constants.dart';

/// Single configured Dio instance + interceptors (auth header, logging,
/// retry) - see docs/06_MOBILE_RULES.md §3/§5. No other file may construct
/// its own `Dio()` instance.
class DioClient {
  DioClient({Dio? dio}) : _dio = dio ?? Dio(_baseOptions) {
    _dio.interceptors.addAll([
      _AuthHeaderInterceptor(this),
      _RetryInterceptor(_dio),
      _LoggingInterceptor(),
    ]);
  }

  static final BaseOptions _baseOptions = BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    // Frappe (`bench`) is multi-tenant and routes by hostname - without this,
    // hitting `baseUrl` directly resolves to whatever site is marked default,
    // not necessarily this app's site.
    headers: {'Host': ApiConstants.siteHost},
  );

  final Dio _dio;

  /// Frappe session id (`sid` cookie) captured after sign-in, attached to
  /// every subsequent request by [_AuthHeaderInterceptor]. Session/API-key
  /// auth for the mobile client isn't part of the documented API contract
  /// (docs/04_BACKEND_RULES.md §5 only defines the `analytics_portal.api.v1.*`
  /// endpoints, not core Frappe auth) - `/api/method/login` is standard
  /// Frappe-core session auth, kept intentionally minimal until a real auth
  /// flow is designed. See the auth feature's presentation-only file tree in
  /// docs/06_MOBILE_RULES.md §6.
  String? sessionId;

  /// Calls one whitelisted `analytics_portal.api.v1.*` method. All endpoints
  /// in docs/04_BACKEND_RULES.md §5 are GET; Frappe wraps a whitelisted
  /// method's return value in `{"message": ...}` - this unwraps it.
  Future<dynamic> callMethod(String method, [Map<String, dynamic>? params]) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/method/$method',
      queryParameters: params,
    );
    return response.data?['message'];
  }

  /// Signs in via Frappe-core's `/api/method/login` and captures the `sid`
  /// session cookie from the response headers for subsequent requests.
  /// Throws [DioException] on bad credentials (Frappe returns non-2xx) or
  /// any network failure - the caller decides how to surface that.
  Future<void> login(String usr, String pwd) async {
    final response = await _dio.post<dynamic>(
      '/api/method/login',
      queryParameters: {'usr': usr, 'pwd': pwd},
    );
    final setCookie = response.headers['set-cookie'];
    String? newSessionId;
    if (setCookie != null) {
      for (final cookie in setCookie) {
        final match = RegExp(r'sid=([^;]+)').firstMatch(cookie);
        if (match != null) {
          newSessionId = match.group(1);
          break;
        }
      }
    }
    if (newSessionId == null || newSessionId == 'Guest') {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Login did not return an authenticated session.',
      );
    }
    sessionId = newSessionId;
  }
}

class _AuthHeaderInterceptor extends Interceptor {
  _AuthHeaderInterceptor(this._client);

  final DioClient _client;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final sessionId = _client.sessionId;
    if (sessionId != null) {
      options.headers['Cookie'] = 'sid=$sessionId';
    }
    handler.next(options);
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log('--> ${options.method} ${options.uri}', name: 'DioClient');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    developer.log(
      '<-- ${response.statusCode} ${response.requestOptions.uri}',
      name: 'DioClient',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      '<-- ERROR ${err.requestOptions.uri}: ${err.message}',
      name: 'DioClient',
    );
    handler.next(err);
  }
}

/// Single retry/backoff interceptor - docs/06_MOBILE_RULES.md §5 ("no per-call
/// ad hoc retry logic"). Retries only idempotent GET requests that failed on
/// a connection/timeout error, up to [_maxRetries] times.
class _RetryInterceptor extends Interceptor {
  _RetryInterceptor(this._dio);

  final Dio _dio;
  static const int _maxRetries = 2;
  static const Duration _baseDelay = Duration(milliseconds: 400);

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final isRetryable =
        options.method == 'GET' &&
        (err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout ||
            err.type == DioExceptionType.connectionError);

    final attempt = (options.extra['retryAttempt'] as int?) ?? 0;
    if (!isRetryable || attempt >= _maxRetries) {
      handler.next(err);
      return;
    }

    await Future<void>.delayed(_baseDelay * (attempt + 1));
    options.extra['retryAttempt'] = attempt + 1;
    try {
      final response = await _dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
