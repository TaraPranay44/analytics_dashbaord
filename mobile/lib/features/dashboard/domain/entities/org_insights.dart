/// Full shape returned by `org_insights` - supplementary real-data callouts
/// for the dashboard's insight chips. See docs/04_BACKEND_RULES.md §5.
class OrgInsights {
  const OrgInsights({
    required this.managerCount,
    required this.totalRegisteredEmployees,
    required this.totalRegisteredEmployeesGrowthWindowStart,
    required this.headcountGrowthWindowDays,
    required this.lowHoursThreshold,
    required this.lowHoursEmployeeCount,
    required this.recentHiresCount,
    required this.recentHiresWindowDays,
  });

  final int managerCount;
  final int totalRegisteredEmployees;
  final int totalRegisteredEmployeesGrowthWindowStart;
  final int headcountGrowthWindowDays;
  final double lowHoursThreshold;
  final int lowHoursEmployeeCount;
  final int recentHiresCount;
  final int recentHiresWindowDays;
}
