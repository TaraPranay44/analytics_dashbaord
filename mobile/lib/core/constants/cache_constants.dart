/// Isar collection names and local cache TTLs. No literal Isar collection
/// name or TTL number may appear inline elsewhere - see docs/06_MOBILE_RULES.md §7.
class CacheConstants {
  CacheConstants._();

  /// Single Isar collection backing every feature's read-through cache - one
  /// consistent caching pattern across all repositories, per
  /// docs/06_MOBILE_RULES.md §2 ("this single pattern is used by every
  /// repository - don't invent a different caching strategy per feature").
  /// Each row is one cached JSON response, keyed by [cacheKeyFor].
  static const String cachedJsonCollectionName = 'CachedJsonEntry';

  /// Mirrors analytics_portal/constants/api_constants.py EMPLOYEE_LIST_CACHE_TTL_SECONDS.
  static const int employeeListCacheTtlSeconds = 90;

  /// `employee_detail`, `org_dashboard` are cached "until next aggregation
  /// run" server-side (docs/04_BACKEND_RULES.md §6) - the client has no
  /// event channel for that, so it treats them as session-cached (no TTL,
  /// refreshed on pull-to-refresh) rather than inventing a client-side TTL
  /// the backend doesn't actually promise.
  static const int? untilNextAggregationTtlSeconds = null;

  static String employeeListKey(String q, String? manager, String? sort, int start, int limit) =>
      'employee_list:$q:${manager ?? ''}:${sort ?? ''}:$start:$limit';

  static String employeeDetailKey(String employeeId) => 'employee_detail:$employeeId';

  static String employeeMonthlyTrendKey(String employeeId) => 'employee_monthly_trend:$employeeId';

  static String employeeLogsKey(
    String employeeId,
    String? fromDate,
    String? toDate,
    int start,
    int limit,
  ) => 'employee_logs:$employeeId:${fromDate ?? ''}:${toDate ?? ''}:$start:$limit';

  static const String orgDashboardKey = 'org_dashboard';

  static const String orgInsightsKey = 'org_insights';

  static String orgHierarchyKey(String employeeId) => 'org_hierarchy:$employeeId';
}
