import '../../../../core/constants/api_constants.dart';
import '../../../../shared/models/paginated_result.dart';
import '../entities/activity_log_row.dart';
import '../repositories/employee_detail_repository.dart';

/// Single-purpose use case - one paginated page of an employee's activity log.
class GetEmployeeLogsPage {
  const GetEmployeeLogsPage(this._repository);

  final EmployeeDetailRepository _repository;

  Future<PaginatedResult<ActivityLogRow>> call({
    required String employeeId,
    String? fromDate,
    String? toDate,
    int start = 0,
    int limit = ApiConstants.pageSizeDefault,
  }) {
    return _repository.getEmployeeLogsPage(
      employeeId: employeeId,
      fromDate: fromDate,
      toDate: toDate,
      start: start,
      limit: limit,
    );
  }
}
