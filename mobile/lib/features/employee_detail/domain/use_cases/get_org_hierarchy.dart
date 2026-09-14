import '../entities/org_hierarchy.dart';
import '../repositories/employee_detail_repository.dart';

/// Single-purpose use case - manager chain and direct reports for one employee.
class GetOrgHierarchy {
  const GetOrgHierarchy(this._repository);

  final EmployeeDetailRepository _repository;

  Future<OrgHierarchy> call(String employeeId) => _repository.getOrgHierarchy(employeeId);
}
