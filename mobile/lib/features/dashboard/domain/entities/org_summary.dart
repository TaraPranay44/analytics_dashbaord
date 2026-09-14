/// One point of `org_dashboard`'s embedded `history` - a day's
/// `Org Daily Stats` row. See docs/04_BACKEND_RULES.md §5.
class OrgDailyStatsPoint {
  const OrgDailyStatsPoint({
    required this.date,
    required this.totalEmployees,
    required this.avgHoursOrg,
    required this.avgLoginTimeOrg,
  });

  final String date;
  final int totalEmployees;
  final double avgHoursOrg;
  final String? avgLoginTimeOrg;
}

/// Full shape returned by `org_dashboard` - org-wide tiles for the landing
/// dashboard header, plus a trailing `ORG_DASHBOARD_HISTORY_DAYS`-day
/// `history` for sparklines/trend badges.
class OrgSummary {
  const OrgSummary({
    required this.date,
    required this.totalEmployees,
    required this.avgHoursOrg,
    required this.avgLoginTimeOrg,
    required this.history,
  });

  final String? date;
  final int totalEmployees;
  final double avgHoursOrg;
  final String? avgLoginTimeOrg;
  final List<OrgDailyStatsPoint> history;
}
