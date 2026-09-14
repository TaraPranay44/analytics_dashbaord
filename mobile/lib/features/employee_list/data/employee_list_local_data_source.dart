import '../../../core/cache/isar_client.dart';
import '../../../core/constants/cache_constants.dart';
import '../domain/entities/employee_sort_option.dart';

/// Isar read-through cache for one `employee_list` page's raw JSON body,
/// keyed exactly like the backend's own cache key (docs/04_BACKEND_RULES.md
/// §6: `q`, `manager`, `sort`, `start`, `limit`) so each filter/page combo
/// caches separately.
class EmployeeListLocalDataSource {
  const EmployeeListLocalDataSource(this._isar);

  final IsarClient _isar;

  Future<Map<String, dynamic>?> readCached({
    required String q,
    required String? manager,
    required EmployeeSortOption? sort,
    required int start,
    required int limit,
  }) async {
    final cached = await _isar.readCached(
      CacheConstants.employeeListKey(q, manager, sort?.apiValue, start, limit),
      ttlSeconds: CacheConstants.employeeListCacheTtlSeconds,
    );
    return cached as Map<String, dynamic>?;
  }

  Future<void> writeCached({
    required String q,
    required String? manager,
    required EmployeeSortOption? sort,
    required int start,
    required int limit,
    required Map<String, dynamic> json,
  }) {
    return _isar.writeCached(
      CacheConstants.employeeListKey(q, manager, sort?.apiValue, start, limit),
      json,
    );
  }
}
