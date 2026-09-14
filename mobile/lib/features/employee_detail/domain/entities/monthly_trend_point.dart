/// One point of `employee_monthly_trend` - lifetime monthly averages from
/// `Employee Monthly Stats`, oldest first. See docs/04_BACKEND_RULES.md §5.
class MonthlyTrendPoint {
  const MonthlyTrendPoint({required this.yearMonth, required this.avgHours});

  final String yearMonth;
  final double avgHours;
}
