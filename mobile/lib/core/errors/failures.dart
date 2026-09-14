import 'package:dio/dio.dart';

/// Typed failure classes surfaced by repositories to the presentation layer.
/// Repositories catch Dio/Isar exceptions and rethrow one of these - a widget
/// never inspects a raw `DioException`/`IsarError`. See docs/06_MOBILE_RULES.md §6.
sealed class Failure {
  const Failure(this.message);

  final String message;
}

/// The Dio call failed (no connectivity, timeout, non-2xx response, etc.).
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network request failed.']);
}

/// The backend raised `frappe.DoesNotExistError` for the requested `employee_id`
/// - see docs/04_BACKEND_RULES.md §5 ("must raise ... if not found").
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'The requested record was not found.']);
}

/// An unexpected error while reading/writing the Isar cache.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local cache read/write failed.']);
}

/// Any other unexpected failure.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong.']);
}

/// Maps a caught Dio error to a typed [Failure] - a 404 response is how
/// Frappe's `frappe.DoesNotExistError` (raised for an unknown `employee_id`,
/// docs/04_BACKEND_RULES.md §5) surfaces over REST; everything else is
/// treated as a network failure.
Failure mapDioError(Object error) {
  if (error is DioException && error.response?.statusCode == 404) {
    return const NotFoundFailure();
  }
  return const NetworkFailure();
}
