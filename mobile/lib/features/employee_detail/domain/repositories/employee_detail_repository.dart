import '../../../../shared/models/paginated_result.dart';
import '../entities/activity_log_row.dart';
import '../entities/employee_detail.dart';
import '../entities/monthly_trend_point.dart';
import '../entities/org_hierarchy.dart';

/// Repository interface (Domain layer) covering every `employee_detail`
/// screen data need: identity/summary/trend, org hierarchy, paginated logs,
/// and the lifetime monthly trend. See docs/06_MOBILE_RULES.md §1.
abstract class EmployeeDetailRepository {
  Future<EmployeeDetail> getEmployeeDetail(String employeeId);

  Future<OrgHierarchy> getOrgHierarchy(String employeeId);

  Future<PaginatedResult<ActivityLogRow>> getEmployeeLogsPage({
    required String employeeId,
    String? fromDate,
    String? toDate,
    required int start,
    required int limit,
  });

  Future<List<MonthlyTrendPoint>> getEmployeeMonthlyTrend(String employeeId);
}
