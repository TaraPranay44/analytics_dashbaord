import '../../../../core/constants/api_constants.dart';
import '../../../../shared/models/paginated_result.dart';
import '../entities/employee_list_item.dart';
import '../entities/employee_sort_option.dart';
import '../repositories/employee_list_repository.dart';

/// Single-purpose use case - the paginated, filterable employee directory
/// (`employee_list`). Reused for both the landing directory and the manager
/// filter's search, same as web's `useEmployeeList` composable.
class GetEmployeeList {
  const GetEmployeeList(this._repository);

  final EmployeeListRepository _repository;

  Future<PaginatedResult<EmployeeListItem>> call({
    String q = '',
    String? manager,
    EmployeeSortOption? sort,
    int start = 0,
    int limit = ApiConstants.pageSizeDefault,
  }) {
    return _repository.getEmployeeList(q: q, manager: manager, sort: sort, start: start, limit: limit);
  }
}
