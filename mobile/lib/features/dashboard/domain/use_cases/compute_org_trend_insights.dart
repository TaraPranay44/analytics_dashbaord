import '../entities/org_summary.dart';

/// Derives real "recent momentum" indicators from `org_dashboard`'s embedded
/// `history` - small, pure reductions over an already-fetched, bounded
/// (`ORG_DASHBOARD_HISTORY_DAYS`-row) list. Mirrors web/src/utils/orgTrend.ts
/// exactly - see docs/04_BACKEND_RULES.md §5.
class OrgTrendInsights {
  const OrgTrendInsights({required this.avgHoursChangePercent, required this.avgLoginMinutesDelta});

  /// % change in `avg_hours_org`, last 7 days vs. the 7 before that - null if
  /// there aren't 14 days of history yet.
  final double? avgHoursChangePercent;

  /// Minutes later (positive) or earlier (negative) `avg_login_time_org`
  /// shifted, last 7 vs. prior 7 days.
  final double? avgLoginMinutesDelta;
}

int _timeToMinutes(String time) {
  final parts = time.split(':');
  final hours = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
  final minutes = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
  return hours * 60 + minutes;
}

// `fold<num>` (not `reduce`) deliberately: `reduce`'s combine callback must
// return exactly the list's own runtime element type (`double` here, `int`
// for the login-minutes call site below), so a callback inferred against
// this function's `List<num>` parameter type crashes at runtime with
// "type '(num, num) => num' is not a subtype of type '(double, double) =>
// double'". `fold` pins the accumulator type explicitly instead, sidestepping it.
double _average(List<num> values) => values.fold<num>(0, (sum, v) => sum + v) / values.length;

OrgTrendInsights computeOrgTrendInsights(List<OrgDailyStatsPoint> history) {
  if (history.length < 14) {
    return const OrgTrendInsights(avgHoursChangePercent: null, avgLoginMinutesDelta: null);
  }
  final last7 = history.sublist(history.length - 7);
  final prev7 = history.sublist(history.length - 14, history.length - 7);

  final prevAvgHours = _average(prev7.map((p) => p.avgHoursOrg).toList());
  final avgHoursChangePercent = prevAvgHours > 0
      ? ((_average(last7.map((p) => p.avgHoursOrg).toList()) - prevAvgHours) / prevAvgHours) * 100
      : null;

  final last7Login = last7.map((p) => p.avgLoginTimeOrg).whereType<String>().toList();
  final prev7Login = prev7.map((p) => p.avgLoginTimeOrg).whereType<String>().toList();
  final avgLoginMinutesDelta = (last7Login.isNotEmpty && prev7Login.isNotEmpty)
      ? _average(last7Login.map(_timeToMinutes).toList()) - _average(prev7Login.map(_timeToMinutes).toList())
      : null;

  return OrgTrendInsights(avgHoursChangePercent: avgHoursChangePercent, avgLoginMinutesDelta: avgLoginMinutesDelta);
}
