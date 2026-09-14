import '../entities/employee_detail.dart';

/// Derives real, honest "recent momentum" indicators from the
/// `employee_detail` trend series (daily `total_hours`) - no fabricated
/// fields, just small pure reductions over the already-fetched, bounded
/// (≤`EMPLOYEE_DETAIL_TREND_DAYS`-row) list. Mirrors
/// web/src/utils/trendInsights.ts exactly - see docs/04_BACKEND_RULES.md §5.
class TrendInsights {
  const TrendInsights({
    required this.attendanceRatePercent,
    required this.attendanceWindowDays,
    required this.attendanceChangePoints,
    required this.hoursChangePercent,
  });

  /// % of days in the available trend window with any logged hours, or null
  /// if the window is empty.
  final double? attendanceRatePercent;

  /// How many days the trend window actually covers (mirrors
  /// `EMPLOYEE_DETAIL_TREND_DAYS`, or fewer for a new hire).
  final int attendanceWindowDays;

  /// Percentage-point change in attendance rate, last 7 days vs. the 7
  /// before that - null if there aren't 14 days yet.
  final double? attendanceChangePoints;

  /// % change in average daily hours, last 7 days vs. the 7 before that -
  /// null if there aren't 14 days yet.
  final double? hoursChangePercent;
}

double _average(List<TrendPoint> points) =>
    points.fold<double>(0, (sum, p) => sum + p.totalHours) / points.length;

double _attendanceRate(List<TrendPoint> points) =>
    (points.where((p) => p.totalHours > 0).length / points.length) * 100;

TrendInsights computeTrendInsights(List<TrendPoint> trend) {
  final attendanceWindowDays = trend.length;
  final attendanceRatePercent = attendanceWindowDays > 0 ? _attendanceRate(trend) : null;

  if (trend.length < 14) {
    return TrendInsights(
      attendanceRatePercent: attendanceRatePercent,
      attendanceWindowDays: attendanceWindowDays,
      attendanceChangePoints: null,
      hoursChangePercent: null,
    );
  }

  final last7 = trend.sublist(trend.length - 7);
  final prev7 = trend.sublist(trend.length - 14, trend.length - 7);

  final prevAvgHours = _average(prev7);
  final hoursChangePercent = prevAvgHours > 0 ? ((_average(last7) - prevAvgHours) / prevAvgHours) * 100 : null;
  final attendanceChangePoints = _attendanceRate(last7) - _attendanceRate(prev7);

  return TrendInsights(
    attendanceRatePercent: attendanceRatePercent,
    attendanceWindowDays: attendanceWindowDays,
    attendanceChangePoints: attendanceChangePoints,
    hoursChangePercent: hoursChangePercent,
  );
}
