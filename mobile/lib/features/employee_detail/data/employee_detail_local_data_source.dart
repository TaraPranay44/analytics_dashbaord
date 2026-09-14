import '../../../core/cache/isar_client.dart';
import '../../../core/constants/cache_constants.dart';

/// Isar read-through cache for every `employee_detail` screen data need -
/// same single pattern as `OrgLocalDataSource`/`EmployeeListLocalDataSource`,
/// see docs/06_MOBILE_RULES.md §2.
class EmployeeDetailLocalDataSource {
  const EmployeeDetailLocalDataSource(this._isar);

  final IsarClient _isar;

  Future<Map<String, dynamic>?> readCachedEmployeeDetail(String employeeId) async {
    final cached = await _isar.readCached(
      CacheConstants.employeeDetailKey(employeeId),
      ttlSeconds: CacheConstants.untilNextAggregationTtlSeconds,
    );
    return cached as Map<String, dynamic>?;
  }

  Future<void> writeCachedEmployeeDetail(String employeeId, Map<String, dynamic> json) =>
      _isar.writeCached(CacheConstants.employeeDetailKey(employeeId), json);

  Future<Map<String, dynamic>?> readCachedOrgHierarchy(String employeeId) async {
    final cached = await _isar.readCached(CacheConstants.orgHierarchyKey(employeeId));
    return cached as Map<String, dynamic>?;
  }

  Future<void> writeCachedOrgHierarchy(String employeeId, Map<String, dynamic> json) =>
      _isar.writeCached(CacheConstants.orgHierarchyKey(employeeId), json);

  Future<Map<String, dynamic>?> readCachedEmployeeLogs({
    required String employeeId,
    String? fromDate,
    String? toDate,
    required int start,
    required int limit,
  }) async {
    final cached = await _isar.readCached(
      CacheConstants.employeeLogsKey(employeeId, fromDate, toDate, start, limit),
    );
    return cached as Map<String, dynamic>?;
  }

  Future<void> writeCachedEmployeeLogs({
    required String employeeId,
    String? fromDate,
    String? toDate,
    required int start,
    required int limit,
    required Map<String, dynamic> json,
  }) {
    return _isar.writeCached(
      CacheConstants.employeeLogsKey(employeeId, fromDate, toDate, start, limit),
      json,
    );
  }

  Future<List<dynamic>?> readCachedMonthlyTrend(String employeeId) async {
    final cached = await _isar.readCached(CacheConstants.employeeMonthlyTrendKey(employeeId));
    return cached as List<dynamic>?;
  }

  Future<void> writeCachedMonthlyTrend(String employeeId, List<dynamic> json) =>
      _isar.writeCached(CacheConstants.employeeMonthlyTrendKey(employeeId), json);
}
