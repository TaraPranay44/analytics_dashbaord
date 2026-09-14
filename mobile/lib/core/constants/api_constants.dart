/// Whitelisted endpoint paths - must match docs/04_BACKEND_RULES.md §5 and
/// analytics_portal/api/v1/*.py exactly. No literal endpoint path may appear
/// inline in a widget/provider/repository - see docs/06_MOBILE_RULES.md §7.
class ApiConstants {
  ApiConstants._();

  /// Frappe site base URL. Override per environment with
  /// `--dart-define=ANALYTICS_PORTAL_BASE_URL=https://your-site`.
  ///
  /// Defaults to `10.0.2.2` (the Android emulator's alias for the host
  /// machine's `localhost`, not a real external address - see
  /// https://developer.android.com/studio/run/emulator-networking) so a
  /// locally-running `bench` is reachable out of the box on the emulator;
  /// override for a physical device (host LAN IP) or desktop/web (`localhost`).
  static const String baseUrl = String.fromEnvironment(
    'ANALYTICS_PORTAL_BASE_URL',
    defaultValue: 'http://10.0.2.2:8002',
  );

  /// The `Host` header value for the target Frappe site - required because
  /// Frappe routes multi-tenant `bench` requests by hostname, and
  /// `10.0.2.2`/`localhost` alone won't resolve to the right site.
  /// Override alongside [baseUrl] with `--dart-define=ANALYTICS_PORTAL_SITE_HOST=...`.
  static const String siteHost = String.fromEnvironment(
    'ANALYTICS_PORTAL_SITE_HOST',
    defaultValue: 'employee-analytics.in',
  );

  static const String employeeList = 'analytics_portal.api.v1.employee.employee_list';
  static const String employeeDetail = 'analytics_portal.api.v1.employee.employee_detail';
  static const String employeeMonthlyTrend =
      'analytics_portal.api.v1.employee.employee_monthly_trend';
  static const String employeeLogs = 'analytics_portal.api.v1.logs.employee_logs';
  static const String orgDashboard = 'analytics_portal.api.v1.org.org_dashboard';
  static const String orgInsights = 'analytics_portal.api.v1.org.org_insights';
  static const String orgHierarchy = 'analytics_portal.api.v1.org.org_hierarchy';

  // Mirrors analytics_portal/constants/api_constants.py - keep in sync.
  static const int pageSizeDefault = 20;
  static const int pageSizeMax = 100;

  /// Search-as-you-type debounce - docs/06_MOBILE_RULES.md §5 ("≥300ms").
  static const int searchDebounceMs = 300;

  /// How many rows the manager-filter combobox shows before asking the user
  /// to keep typing - mirrors web's `ManagerFilterCombobox.MANAGER_RESULT_LIMIT`.
  static const int managerResultLimit = 8;
}
