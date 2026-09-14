import '../entities/org_summary.dart';
import '../repositories/org_repository.dart';

/// Single-purpose use case - fetches org-wide dashboard tiles + history.
class GetOrgDashboard {
  const GetOrgDashboard(this._repository);

  final OrgRepository _repository;

  Future<OrgSummary> call() => _repository.getOrgDashboard();
}
