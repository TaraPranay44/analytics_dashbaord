import '../entities/org_insights.dart';
import '../repositories/org_repository.dart';

/// Single-purpose use case - fetches the dashboard's insight-chip data.
class GetOrgInsights {
  const GetOrgInsights(this._repository);

  final OrgRepository _repository;

  Future<OrgInsights> call() => _repository.getOrgInsights();
}
