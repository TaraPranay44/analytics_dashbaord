import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/delta_badge.dart';
import '../domain/entities/employee_detail.dart';
import '../domain/use_cases/compute_trend_insights.dart';

/// Performance summary card - avg hours/login/logout + attendance, with
/// real deltas derived from the trend series. Mirrors
/// web/src/components/EmployeeSummaryPanel.vue exactly.
class EmployeeSummaryPanel extends StatelessWidget {
  const EmployeeSummaryPanel({super.key, required this.detail});

  final EmployeeDetail detail;

  @override
  Widget build(BuildContext context) {
    final insights = computeTrendInsights(detail.trend);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x1417153D), blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Performance summary', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.7,
            children: [
              _MetricTile(
                color: AppColors.violet500,
                value: formatHours(detail.avgHoursOverall),
                label: 'Avg. time spent / day',
                delta: insights.hoursChangePercent,
                deltaUnit: '%',
              ),
              _MetricTile(
                color: AppColors.amber500,
                value: formatTimeOfDay(detail.avgLoginTimeOverall),
                label: 'Avg. login time',
              ),
              _MetricTile(
                color: AppColors.ink900,
                value: formatTimeOfDay(detail.avgLogoutTimeOverall),
                label: 'Avg. logout time',
              ),
              if (insights.attendanceRatePercent != null)
                _MetricTile(
                  color: AppColors.teal500,
                  value: '${insights.attendanceRatePercent!.round()}%',
                  label: 'Attendance (${insights.attendanceWindowDays}d)',
                  delta: insights.attendanceChangePoints,
                  deltaUnit: ' pts',
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.violet500.withValues(alpha: 0.07), AppColors.pink500.withValues(alpha: 0.07)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _insightSentence(detail, insights),
              style: const TextStyle(fontSize: 11.5, color: AppColors.ink700, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  String _insightSentence(EmployeeDetail detail, TrendInsights insights) {
    final hoursClause = 'Averaging ${formatHours(detail.avgHoursOverall)}/day';
    final trendClause = insights.hoursChangePercent != null
        ? ', ${insights.hoursChangePercent! >= 0 ? 'up' : 'down'} ${insights.hoursChangePercent!.abs().round()}% over the last 7 days'
        : '';
    final attendanceWord = () {
      final change = insights.attendanceChangePoints;
      if (change == null || change.abs() < 3) return 'steady';
      return change > 0 ? 'improving' : 'slipping';
    }();
    final attendanceClause = insights.attendanceRatePercent != null
        ? ' — attendance is $attendanceWord at ${insights.attendanceRatePercent!.round()}%'
        : '';
    return '$hoursClause$trendClause$attendanceClause.';
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.color, required this.value, required this.label, this.delta, this.deltaUnit});

  final Color color;
  final String value;
  final String label;
  final double? delta;
  final String? deltaUnit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(color: AppColors.bgPage, borderRadius: BorderRadius.circular(11)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 18, height: 3, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 5),
          Row(
            children: [
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (delta != null) ...[const SizedBox(width: 6), DeltaBadge(value: delta!, unit: deltaUnit ?? '%')],
            ],
          ),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.ink500)),
        ],
      ),
    );
  }
}
