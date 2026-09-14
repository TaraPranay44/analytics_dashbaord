import '../../../../shared/models/paginated_result.dart';
import '../entities/employee_list_item.dart';
import '../entities/employee_sort_option.dart';

/// Repository interface (Domain layer) for `employee_list`.
abstract class EmployeeListRepository {
  Future<PaginatedResult<EmployeeListItem>> getEmployeeList({
    required String q,
    required String? manager,
    required EmployeeSortOption? sort,
    required int start,
    required int limit,
  });
}
