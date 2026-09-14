import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../../shared/models/paginated_result.dart';
import '../domain/entities/employee_list_item.dart';
import '../domain/entities/employee_sort_option.dart';

/// Dio calls for `employee_list`, plus JSON -> Entity mapping. See
/// docs/06_MOBILE_RULES.md §1 - the only layer allowed to import `dio`.
class EmployeeListRemoteDataSource {
  const EmployeeListRemoteDataSource(this._dio);

  final DioClient _dio;

  Future<Map<String, dynamic>> fetchEmployeeListJson({
    required String q,
    required String? manager,
    required EmployeeSortOption? sort,
    required int start,
    required int limit,
  }) async {
    final json = await _dio.callMethod(ApiConstants.employeeList, {
      'q': q,
      if (manager != null) 'manager': manager,
      if (sort?.apiValue != null) 'sort': sort!.apiValue,
      'start': start,
      'limit': limit,
    });
    return json as Map<String, dynamic>;
  }
}

PaginatedResult<EmployeeListItem> employeeListResultFromJson(Map<String, dynamic> json) {
  return PaginatedResult<EmployeeListItem>(
    data: ((json['data'] as List?) ?? const [])
        .map((row) => _employeeListItemFromJson(row as Map<String, dynamic>))
        .toList(),
    start: (json['start'] as num?)?.toInt() ?? 0,
    limit: (json['limit'] as num?)?.toInt() ?? ApiConstants.pageSizeDefault,
    hasMore: json['has_more'] as bool? ?? false,
  );
}

EmployeeListItem _employeeListItemFromJson(Map<String, dynamic> json) {
  return EmployeeListItem(
    employeeId: json['employee_id'] as String,
    employeeName: json['employee_name'] as String,
    manager: json['manager'] as String?,
    managerName: json['manager_name'] as String?,
    avgHoursOverall: (json['avg_hours_overall'] as num?)?.toDouble(),
    avgLoginTimeOverall: json['avg_login_time_overall'] as String?,
  );
}
