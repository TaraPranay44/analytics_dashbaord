import 'dart:async';
import 'dart:developer' as developer;

import '../../../core/errors/failures.dart';
import '../domain/entities/org_insights.dart';
import '../domain/entities/org_summary.dart';
import '../domain/repositories/org_repository.dart';
import 'org_local_data_source.dart';
import 'org_remote_data_source.dart';

/// Read-through cache pattern from docs/06_MOBILE_RULES.md §2: check Isar
/// first - if present, return it and refresh from Dio in the background; if
/// missing, call Dio, write through to Isar, then return.
class OrgRepositoryImpl implements OrgRepository {
  const OrgRepositoryImpl(this._remote, this._local);

  final OrgRemoteDataSource _remote;
  final OrgLocalDataSource _local;

  @override
  Future<OrgSummary> getOrgDashboard() async {
    final cachedJson = await _local.readCachedOrgDashboard();
    if (cachedJson != null) {
      // Fire-and-forget: keeps the cache warm for next time without
      // blocking this call. Errors are swallowed inside the method itself.
      unawaited(_refreshOrgDashboardSilently());
      return orgSummaryFromJson(cachedJson);
    }
    return _fetchAndCacheOrgDashboard();
  }

  Future<OrgSummary> _fetchAndCacheOrgDashboard() async {
    try {
      final json = await _remote.fetchOrgDashboardJson();
      await _local.writeCachedOrgDashboard(json);
      return orgSummaryFromJson(json);
    } catch (e) {
      developer.log('org_dashboard fetch failed: $e', name: 'OrgRepositoryImpl');
      throw const NetworkFailure();
    }
  }

  Future<void> _refreshOrgDashboardSilently() async {
    try {
      final json = await _remote.fetchOrgDashboardJson();
      await _local.writeCachedOrgDashboard(json);
    } catch (e) {
      developer.log('org_dashboard background refresh failed: $e', name: 'OrgRepositoryImpl');
    }
  }

  @override
  Future<OrgInsights> getOrgInsights() async {
    final cachedJson = await _local.readCachedOrgInsights();
    if (cachedJson != null) {
      unawaited(_refreshOrgInsightsSilently());
      return orgInsightsFromJson(cachedJson);
    }
    return _fetchAndCacheOrgInsights();
  }

  Future<OrgInsights> _fetchAndCacheOrgInsights() async {
    try {
      final json = await _remote.fetchOrgInsightsJson();
      await _local.writeCachedOrgInsights(json);
      return orgInsightsFromJson(json);
    } catch (e) {
      developer.log('org_insights fetch failed: $e', name: 'OrgRepositoryImpl');
      throw const NetworkFailure();
    }
  }

  Future<void> _refreshOrgInsightsSilently() async {
    try {
      final json = await _remote.fetchOrgInsightsJson();
      await _local.writeCachedOrgInsights(json);
    } catch (e) {
      developer.log('org_insights background refresh failed: $e', name: 'OrgRepositoryImpl');
    }
  }
}
