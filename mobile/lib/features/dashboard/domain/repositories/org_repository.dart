import '../entities/org_insights.dart';
import '../entities/org_summary.dart';

/// Repository interface (Domain layer) - implemented in `data/`, depended on
/// only by use cases. No Dio/Isar types appear here. See docs/06_MOBILE_RULES.md §1.
abstract class OrgRepository {
  Future<OrgSummary> getOrgDashboard();

  Future<OrgInsights> getOrgInsights();
}
