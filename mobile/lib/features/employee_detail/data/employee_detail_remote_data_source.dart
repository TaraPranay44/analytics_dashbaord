import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../../shared/models/paginated_result.dart';
import '../domain/entities/activity_log_row.dart';
import '../domain/entities/employee_detail.dart';
import '../domain/entities/monthly_trend_point.dart';
import '../domain/entities/org_hierarchy.dart';

/// Dio calls for `employee_detail`, `org_hierarchy`, `employee_logs`,
/// `employee_monthly_trend`, plus JSON -> Entity mapping. See
/// docs/06_MOBILE_RULES.md §1 - the only layer allowed to import `dio`.
class EmployeeDetailRemoteDataSource {
  const EmployeeDetailRemoteDataSource(this._dio);

  final DioClient _dio;

  Future<Map<String, dynamic>> fetchEmployeeDetailJson(String employeeId) async {
    final json = await _dio.callMethod(ApiConstants.employeeDetail, {'employee_id': employeeId});
    return json as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchOrgHierarchyJson(String employeeId) async {
    final json = await _dio.callMethod(ApiConstants.orgHierarchy, {'employee_id': employeeId});
    return json as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchEmployeeLogsJson({
    required String employeeId,
    String? fromDate,
    String? toDate,
    required int start,
    required int limit,
  }) async {
    final json = await _dio.callMethod(ApiConstants.employeeLogs, {
      'employee_id': employeeId,
      if (fromDate != null) 'from_date': fromDate,
      if (toDate != null) 'to_date': toDate,
      'start': start,
      'limit': limit,
    });
    return json as Map<String, dynamic>;
  }

  Future<List<dynamic>> fetchEmployeeMonthlyTrendJson(String employeeId) async {
    final json = await _dio.callMethod(ApiConstants.employeeMonthlyTrend, {'employee_id': employeeId});
    return json as List<dynamic>;
  }
}

EmployeeDetail employeeDetailFromJson(Map<String, dynamic> json) {
  return EmployeeDetail(
    employeeId: json['employee_id'] as String,
    employeeName: json['employee_name'] as String,
    dateOfJoining: json['date_of_joining'] as String?,
    manager: json['manager'] as String?,
    managerChain: ((json['manager_chain'] as List?) ?? const [])
        .map((row) => _managerChainEntryFromJson(row as Map<String, dynamic>))
        .toList(),
    avgHoursOverall: (json['avg_hours_overall'] as num?)?.toDouble() ?? 0.0,
    avgLoginTimeOverall: json['avg_login_time_overall'] as String?,
    avgLogoutTimeOverall: json['avg_logout_time_overall'] as String?,
    trend: ((json['trend'] as List?) ?? const [])
        .map((row) => _trendPointFromJson(row as Map<String, dynamic>))
        .toList(),
  );
}

ManagerChainEntry _managerChainEntryFromJson(Map<String, dynamic> json) {
  return ManagerChainEntry(
    employeeId: json['employee_id'] as String,
    employeeName: json['employee_name'] as String,
  );
}

TrendPoint _trendPointFromJson(Map<String, dynamic> json) {
  return TrendPoint(date: json['date'] as String, totalHours: (json['total_hours'] as num?)?.toDouble() ?? 0.0);
}

OrgHierarchy orgHierarchyFromJson(Map<String, dynamic> json) {
  return OrgHierarchy(
    managerChain: ((json['manager_chain'] as List?) ?? const [])
        .map((row) => _managerChainEntryFromJson(row as Map<String, dynamic>))
        .toList(),
    directReports: ((json['direct_reports'] as List?) ?? const [])
        .map((row) => _directReportFromJson(row as Map<String, dynamic>))
        .toList(),
  );
}

DirectReport _directReportFromJson(Map<String, dynamic> json) {
  return DirectReport(employeeId: json['employee_id'] as String, employeeName: json['employee_name'] as String);
}

PaginatedResult<ActivityLogRow> employeeLogsResultFromJson(Map<String, dynamic> json) {
  return PaginatedResult<ActivityLogRow>(
    data: ((json['data'] as List?) ?? const [])
        .map((row) => _activityLogRowFromJson(row as Map<String, dynamic>))
        .toList(),
    start: (json['start'] as num?)?.toInt() ?? 0,
    limit: (json['limit'] as num?)?.toInt() ?? ApiConstants.pageSizeDefault,
    hasMore: json['has_more'] as bool? ?? false,
  );
}

ActivityLogRow _activityLogRowFromJson(Map<String, dynamic> json) {
  return ActivityLogRow(
    employee: json['employee'] as String,
    date: json['date'] as String,
    loginTime: json['login_time'] as String?,
    logoutTime: json['logout_time'] as String?,
    totalHours: (json['total_hours'] as num?)?.toDouble(),
  );
}

List<MonthlyTrendPoint> monthlyTrendFromJson(List<dynamic> json) {
  return json
      .map(
        (row) => MonthlyTrendPoint(
          yearMonth: (row as Map<String, dynamic>)['year_month'] as String,
          avgHours: (row['avg_hours'] as num?)?.toDouble() ?? 0.0,
        ),
      )
      .toList();
}
