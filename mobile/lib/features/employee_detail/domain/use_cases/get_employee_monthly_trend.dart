import '../entities/monthly_trend_point.dart';
import '../repositories/employee_detail_repository.dart';

/// Single-purpose use case - lifetime monthly avg-hours trend, for the
/// detail page's "Lifetime" chart view. Not paginated - naturally bounded by
/// tenure, see docs/04_BACKEND_RULES.md §5.
class GetEmployeeMonthlyTrend {
  const GetEmployeeMonthlyTrend(this._repository);

  final EmployeeDetailRepository _repository;

  Future<List<MonthlyTrendPoint>> call(String employeeId) => _repository.getEmployeeMonthlyTrend(employeeId);
}
