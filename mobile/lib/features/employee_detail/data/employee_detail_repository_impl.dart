import 'dart:async';
import 'dart:developer' as developer;

import '../../../core/errors/failures.dart';
import '../../../shared/models/paginated_result.dart';
import '../domain/entities/activity_log_row.dart';
import '../domain/entities/employee_detail.dart';
import '../domain/entities/monthly_trend_point.dart';
import '../domain/entities/org_hierarchy.dart';
import '../domain/repositories/employee_detail_repository.dart';
import 'employee_detail_local_data_source.dart';
import 'employee_detail_remote_data_source.dart';

/// Read-through cache pattern from docs/06_MOBILE_RULES.md §2 - see
/// `OrgRepositoryImpl` for the full explanation, same shape for all four
/// employee-detail-screen data needs.
class EmployeeDetailRepositoryImpl implements EmployeeDetailRepository {
  const EmployeeDetailRepositoryImpl(this._remote, this._local);

  final EmployeeDetailRemoteDataSource _remote;
  final EmployeeDetailLocalDataSource _local;

  @override
  Future<EmployeeDetail> getEmployeeDetail(String employeeId) async {
    final cachedJson = await _local.readCachedEmployeeDetail(employeeId);
    if (cachedJson != null) {
      unawaited(_refreshEmployeeDetailSilently(employeeId));
      return employeeDetailFromJson(cachedJson);
    }
    try {
      final json = await _remote.fetchEmployeeDetailJson(employeeId);
      await _local.writeCachedEmployeeDetail(employeeId, json);
      return employeeDetailFromJson(json);
    } catch (e) {
      developer.log('employee_detail fetch failed: $e', name: 'EmployeeDetailRepositoryImpl');
      throw mapDioError(e);
    }
  }

  Future<void> _refreshEmployeeDetailSilently(String employeeId) async {
    try {
      final json = await _remote.fetchEmployeeDetailJson(employeeId);
      await _local.writeCachedEmployeeDetail(employeeId, json);
    } catch (e) {
      developer.log('employee_detail background refresh failed: $e', name: 'EmployeeDetailRepositoryImpl');
    }
  }

  @override
  Future<OrgHierarchy> getOrgHierarchy(String employeeId) async {
    final cachedJson = await _local.readCachedOrgHierarchy(employeeId);
    if (cachedJson != null) {
      unawaited(_refreshOrgHierarchySilently(employeeId));
      return orgHierarchyFromJson(cachedJson);
    }
    try {
      final json = await _remote.fetchOrgHierarchyJson(employeeId);
      await _local.writeCachedOrgHierarchy(employeeId, json);
      return orgHierarchyFromJson(json);
    } catch (e) {
      developer.log('org_hierarchy fetch failed: $e', name: 'EmployeeDetailRepositoryImpl');
      throw mapDioError(e);
    }
  }

  Future<void> _refreshOrgHierarchySilently(String employeeId) async {
    try {
      final json = await _remote.fetchOrgHierarchyJson(employeeId);
      await _local.writeCachedOrgHierarchy(employeeId, json);
    } catch (e) {
      developer.log('org_hierarchy background refresh failed: $e', name: 'EmployeeDetailRepositoryImpl');
    }
  }

  @override
  Future<PaginatedResult<ActivityLogRow>> getEmployeeLogsPage({
    required String employeeId,
    String? fromDate,
    String? toDate,
    required int start,
    required int limit,
  }) async {
    final cachedJson = await _local.readCachedEmployeeLogs(
      employeeId: employeeId,
      fromDate: fromDate,
      toDate: toDate,
      start: start,
      limit: limit,
    );
    if (cachedJson != null) {
      unawaited(
        _refreshEmployeeLogsSilently(employeeId: employeeId, fromDate: fromDate, toDate: toDate, start: start, limit: limit),
      );
      return employeeLogsResultFromJson(cachedJson);
    }
    try {
      final json = await _remote.fetchEmployeeLogsJson(
        employeeId: employeeId,
        fromDate: fromDate,
        toDate: toDate,
        start: start,
        limit: limit,
      );
      await _local.writeCachedEmployeeLogs(
        employeeId: employeeId,
        fromDate: fromDate,
        toDate: toDate,
        start: start,
        limit: limit,
        json: json,
      );
      return employeeLogsResultFromJson(json);
    } catch (e) {
      developer.log('employee_logs fetch failed: $e', name: 'EmployeeDetailRepositoryImpl');
      throw mapDioError(e);
    }
  }

  Future<void> _refreshEmployeeLogsSilently({
    required String employeeId,
    String? fromDate,
    String? toDate,
    required int start,
    required int limit,
  }) async {
    try {
      final json = await _remote.fetchEmployeeLogsJson(
        employeeId: employeeId,
        fromDate: fromDate,
        toDate: toDate,
        start: start,
        limit: limit,
      );
      await _local.writeCachedEmployeeLogs(
        employeeId: employeeId,
        fromDate: fromDate,
        toDate: toDate,
        start: start,
        limit: limit,
        json: json,
      );
    } catch (e) {
      developer.log('employee_logs background refresh failed: $e', name: 'EmployeeDetailRepositoryImpl');
    }
  }

  @override
  Future<List<MonthlyTrendPoint>> getEmployeeMonthlyTrend(String employeeId) async {
    final cachedJson = await _local.readCachedMonthlyTrend(employeeId);
    if (cachedJson != null) {
      unawaited(_refreshMonthlyTrendSilently(employeeId));
      return monthlyTrendFromJson(cachedJson);
    }
    try {
      final json = await _remote.fetchEmployeeMonthlyTrendJson(employeeId);
      await _local.writeCachedMonthlyTrend(employeeId, json);
      return monthlyTrendFromJson(json);
    } catch (e) {
      developer.log('employee_monthly_trend fetch failed: $e', name: 'EmployeeDetailRepositoryImpl');
      throw mapDioError(e);
    }
  }

  Future<void> _refreshMonthlyTrendSilently(String employeeId) async {
    try {
      final json = await _remote.fetchEmployeeMonthlyTrendJson(employeeId);
      await _local.writeCachedMonthlyTrend(employeeId, json);
    } catch (e) {
      developer.log('employee_monthly_trend background refresh failed: $e', name: 'EmployeeDetailRepositoryImpl');
    }
  }
}
