/// UI copy - button labels, empty-state text, error messages. No literal
/// user-facing string may appear inline in a widget - see docs/06_MOBILE_RULES.md §7.
/// Mirrors web/src/constants/stringConstants.ts.
class StringConstants {
  StringConstants._();

  static const String appName = 'Analytics Portal';
  static const String loginHeadline = 'Every clock-in.\nOne radiant view.';
  static const String loginSub = 'Attendance & work-hour insight for every employee.';
  static const String demoNote =
      'Sign in with a CEO-role account (Manager/Employee dashboards coming soon)';
  static const String searchPlaceholder = 'Search employee by name or ID…';
  static const String noResults = 'No employees match these filters.';
  static const String noLogs = 'No activity logged in this range.';
  static const String loadingLabel = 'Loading…';
  static const String employeeNotFound = 'This employee could not be found.';
  static const String comingSoonTitle = 'Coming soon';
  static const String comingSoonBody = "This role's dashboard is on our roadmap — check back soon.";
  static const String backToSignIn = 'Back to sign in';
  static const String emailRequired = 'Enter your email or username.';
  static const String passwordRequired = 'Enter your password.';
  static const String genericErrorMessage = 'Something went wrong. Pull to refresh to try again.';
  static const String offlineNote = 'Showing cached data — you appear to be offline.';
}
