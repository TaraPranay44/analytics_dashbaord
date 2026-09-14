import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/area_trend_chart.dart';
import '../domain/entities/employee_detail.dart';
import 'employee_detail_view_model.dart';

/// "Time spent / day" chart with 7d / `EMPLOYEE_DETAIL_TREND_DAYS`d / Lifetime
/// tabs. The daily `trend` on `employee_detail` only ever covers
/// `EMPLOYEE_DETAIL_TREND_DAYS` days, so "Lifetime" is answered by the
/// separate `employee_monthly_trend` endpoint (monthly averages), fetched
/// lazily only once selected. Mirrors web/src/components/EmployeeTrendChart.vue.
class EmployeeTrendChartCard extends ConsumerWidget {
  const EmployeeTrendChartCard({super.key, required this.employeeId, required this.trend});

  final String employeeId;
  final List<TrendPoint> trend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final window = ref.watch(chartWindowProvider(employeeId));
    final monthlyAsync = window == ChartWindow.lifetime ? ref.watch(employeeMonthlyTrendProvider(employeeId)) : null;

    List<double> values;
    List<String> labels;
    String? note;

    switch (window) {
      case ChartWindow.sevenDays:
        final last7 = trend.length > 7 ? trend.sublist(trend.length - 7) : trend;
        values = last7.map((p) => p.totalHours).toList();
        labels = last7.map((p) => formatShortDate(p.date)).toList();
        break;
      case ChartWindow.thirtyDays:
        values = trend.map((p) => p.totalHours).toList();
        labels = trend.map((p) => formatShortDate(p.date)).toList();
        break;
      case ChartWindow.lifetime:
        final months = monthlyAsync?.valueOrNull ?? const [];
        values = months.map((p) => p.avgHours).toList();
        labels = months.map((p) => formatMonthLabel(p.yearMonth)).toList();
        if (monthlyAsync?.isLoading ?? false) {
          note = 'Loading lifetime trend…';
        } else if (months.isEmpty) {
          note = 'No monthly stats computed yet for this employee.';
        } else if (months.length < 2) {
          note = 'Only ${months.length} month of history computed so far.';
        }
    }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Time spent / day', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
              _WindowTabs(
                current: window,
                onChanged: (w) => ref.read(chartWindowProvider(employeeId).notifier).state = w,
              ),
            ],
          ),
          if (note != null) ...[
            const SizedBox(height: 6),
            Text(note, style: const TextStyle(fontSize: 10.5, color: AppColors.ink500)),
          ],
          const SizedBox(height: 10),
          AreaTrendChart(values: values, labels: labels),
        ],
      ),
    );
  }
}

class _WindowTabs extends StatelessWidget {
  const _WindowTabs({required this.current, required this.onChanged});

  final ChartWindow current;
  final ValueChanged<ChartWindow> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Tab(label: '7d', selected: current == ChartWindow.sevenDays, onTap: () => onChanged(ChartWindow.sevenDays)),
        _Tab(label: '30d', selected: current == ChartWindow.thirtyDays, onTap: () => onChanged(ChartWindow.thirtyDays)),
        _Tab(label: 'All', selected: current == ChartWindow.lifetime, onTap: () => onChanged(ChartWindow.lifetime)),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: selected ? null : AppColors.bgPage,
            gradient: selected ? AppColors.gradientBrand : null,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.ink500,
            ),
          ),
        ),
      ),
    );
  }
}
