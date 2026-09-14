import '../../../core/cache/isar_client.dart';
import '../../../core/constants/cache_constants.dart';

/// Isar read-through cache for `org_dashboard`/`org_insights` raw JSON
/// bodies. Mapping to entities happens in `OrgRepositoryImpl`, reusing the
/// same mapper as the remote data source - see docs/06_MOBILE_RULES.md §2.
class OrgLocalDataSource {
  const OrgLocalDataSource(this._isar);

  final IsarClient _isar;

  Future<Map<String, dynamic>?> readCachedOrgDashboard() async {
    final cached = await _isar.readCached(
      CacheConstants.orgDashboardKey,
      ttlSeconds: CacheConstants.untilNextAggregationTtlSeconds,
    );
    return cached as Map<String, dynamic>?;
  }

  Future<void> writeCachedOrgDashboard(Map<String, dynamic> json) =>
      _isar.writeCached(CacheConstants.orgDashboardKey, json);

  Future<Map<String, dynamic>?> readCachedOrgInsights() async {
    final cached = await _isar.readCached(CacheConstants.orgInsightsKey);
    return cached as Map<String, dynamic>?;
  }

  Future<void> writeCachedOrgInsights(Map<String, dynamic> json) =>
      _isar.writeCached(CacheConstants.orgInsightsKey, json);
}
