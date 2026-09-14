import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../domain/entities/org_insights.dart';
import '../domain/entities/org_summary.dart';

/// Dio calls for `org_dashboard`/`org_insights`, plus the DTO -> Entity
/// mapping (docs/06_MOBILE_RULES.md §1: "the only layer allowed to import
/// `dio`"). Raw JSON never leaves this file as a bare `Map`.
class OrgRemoteDataSource {
  const OrgRemoteDataSource(this._dio);

  final DioClient _dio;

  Future<Map<String, dynamic>> fetchOrgDashboardJson() async =>
      await _dio.callMethod(ApiConstants.orgDashboard) as Map<String, dynamic>;

  Future<Map<String, dynamic>> fetchOrgInsightsJson() async =>
      await _dio.callMethod(ApiConstants.orgInsights) as Map<String, dynamic>;
}

OrgSummary _orgSummaryFromJson(Map<String, dynamic> json) {
  return OrgSummary(
    date: json['date'] as String?,
    totalEmployees: (json['total_employees'] as num?)?.toInt() ?? 0,
    avgHoursOrg: (json['avg_hours_org'] as num?)?.toDouble() ?? 0.0,
    avgLoginTimeOrg: json['avg_login_time_org'] as String?,
    history: ((json['history'] as List?) ?? const [])
        .map((row) => _orgDailyStatsPointFromJson(row as Map<String, dynamic>))
        .toList(),
  );
}

OrgDailyStatsPoint _orgDailyStatsPointFromJson(Map<String, dynamic> json) {
  return OrgDailyStatsPoint(
    date: json['date'] as String,
    totalEmployees: (json['total_employees'] as num?)?.toInt() ?? 0,
    avgHoursOrg: (json['avg_hours_org'] as num?)?.toDouble() ?? 0.0,
    avgLoginTimeOrg: json['avg_login_time_org'] as String?,
  );
}

OrgInsights _orgInsightsFromJson(Map<String, dynamic> json) {
  return OrgInsights(
    managerCount: (json['manager_count'] as num?)?.toInt() ?? 0,
    totalRegisteredEmployees: (json['total_registered_employees'] as num?)?.toInt() ?? 0,
    totalRegisteredEmployeesGrowthWindowStart:
        (json['total_registered_employees_growth_window_start'] as num?)?.toInt() ?? 0,
    headcountGrowthWindowDays: (json['headcount_growth_window_days'] as num?)?.toInt() ?? 0,
    lowHoursThreshold: (json['low_hours_threshold'] as num?)?.toDouble() ?? 0.0,
    lowHoursEmployeeCount: (json['low_hours_employee_count'] as num?)?.toInt() ?? 0,
    recentHiresCount: (json['recent_hires_count'] as num?)?.toInt() ?? 0,
    recentHiresWindowDays: (json['recent_hires_window_days'] as num?)?.toInt() ?? 0,
  );
}

/// Exposed so `OrgRepositoryImpl` can map both a fresh Dio response and a
/// replayed cached JSON body through the exact same DTO -> Entity logic.
OrgSummary orgSummaryFromJson(Map<String, dynamic> json) => _orgSummaryFromJson(json);

OrgInsights orgInsightsFromJson(Map<String, dynamic> json) => _orgInsightsFromJson(json);
