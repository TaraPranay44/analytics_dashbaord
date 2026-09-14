import '../entities/employee_detail.dart';
import '../repositories/employee_detail_repository.dart';

/// Single-purpose use case - full employee detail (identity, manager chain,
/// summary metrics, trend series).
class GetEmployeeDetail {
  const GetEmployeeDetail(this._repository);

  final EmployeeDetailRepository _repository;

  Future<EmployeeDetail> call(String employeeId) => _repository.getEmployeeDetail(employeeId);
}
