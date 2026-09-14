import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/stat_tile.dart';
import '../../employee_detail/presentation/employee_detail_view.dart';
import '../../employee_list/presentation/employee_list_view.dart';
import '../domain/entities/org_insights.dart';
import '../domain/entities/org_summary.dart';
import '../domain/use_cases/compute_org_trend_insights.dart';
import 'dashboard_view_model.dart';

/// Executive dashboard - stat tiles, insight chips, and the employee
/// directory, matching the attached `mobile-dashboard.html` mockup and
/// web/src/views/DashboardView.vue's data wiring.
class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(orgDashboardProvider);
    final insightsAsync = ref.watch(orgInsightsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      _LogoMark(),
                      SizedBox(width: 8),
                      Text('Analytics', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    ],
                  ),
                  if (dashboardAsync.valueOrNull?.date != null)
                    Text(
                      'as of ${formatDateLabel(dashboardAsync.valueOrNull!.date!)}',
                      style: const TextStyle(fontSize: 10.5, color: AppColors.ink300),
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Executive Dashboard',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink500),
                    ),
                    const SizedBox(height: 10),
                    _StatGrid(dashboardAsync: dashboardAsync, insightsAsync: insightsAsync),
                    const SizedBox(height: 14),
                    AsyncValueView(
                      value: insightsAsync,
                      loading: () => const SizedBox.shrink(),
                      error: (_) => const SizedBox.shrink(),
                      data: (insights) => SizedBox(
                        height: 34,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _InsightChip('${_thousands(insights.managerCount)} people-managers'),
                            const SizedBox(width: 8),
                            _InsightChip(
                              '${_thousands(insights.lowHoursEmployeeCount)} under ${insights.lowHoursThreshold.toStringAsFixed(1)} hrs/day',
                            ),
                            const SizedBox(width: 8),
                            _InsightChip(
                              '${_thousands(insights.recentHiresCount)} joined in the last ${insights.recentHiresWindowDays}d',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    EmployeeListView(
                      onEmployeeTap: (employeeId) => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => EmployeeDetailView(employeeId: employeeId)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNav(),
    );
  }

  String _thousands(int value) {
    final text = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) buffer.write(',');
      buffer.write(text[i]);
    }
    return buffer.toString();
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.dashboardAsync, required this.insightsAsync});

  final AsyncValue<OrgSummary> dashboardAsync;
  final AsyncValue<OrgInsights> insightsAsync;

  @override
  Widget build(BuildContext context) {
    final dashboard = dashboardAsync.valueOrNull;
    final insights = insightsAsync.valueOrNull;
    final orgTrend = dashboard != null ? computeOrgTrendInsights(dashboard.history) : null;

    final headcountDelta = (insights != null && insights.totalRegisteredEmployeesGrowthWindowStart > 0)
        ? ((insights.totalRegisteredEmployees - insights.totalRegisteredEmployeesGrowthWindowStart) /
                  insights.totalRegisteredEmployeesGrowthWindowStart) *
              100
        : null;

    // Exactly the 3 real org-wide figures the backend exposes
    // (`org_insights.total_registered_employees`, `org_dashboard.avg_hours_org`,
    // `org_dashboard.avg_login_time_org`) - mirrors web/src/views/DashboardView.vue's
    // `.stat-grid` exactly. The reference mockup's 4th "Attendance %" tile has
    // no backing field on `org_dashboard`/`org_insights` (it was fabricated
    // client-side demo data in the static HTML), so it's intentionally
    // dropped rather than inventing a field - see CLAUDE.md §1.
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: 'Employees tracked',
                value: insights == null ? '—' : _thousands(insights.totalRegisteredEmployees),
                dotColor: AppColors.violet500,
                delta: headcountDelta,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatTile(
                label: 'Avg hrs/day',
                value: dashboard == null ? '—' : formatHours(dashboard.avgHoursOrg),
                dotColor: AppColors.teal500,
                delta: orgTrend?.avgHoursChangePercent,
                sparklineValues: dashboard?.history.map((p) => p.avgHoursOrg).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        StatTile(
          label: 'Org-wide avg login time',
          value: dashboard == null ? '—' : formatTimeOfDay(dashboard.avgLoginTimeOrg),
          dotColor: AppColors.amber500,
          delta: orgTrend?.avgLoginMinutesDelta,
          deltaUnit: ' min',
        ),
      ],
    );
  }

  String _thousands(int value) {
    final text = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) buffer.write(',');
      buffer.write(text[i]);
    }
    return buffer.toString();
  }
}

class _InsightChip extends StatelessWidget {
  const _InsightChip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: const TextStyle(fontSize: 11, color: AppColors.ink700)),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(gradient: AppColors.gradientBrand, borderRadius: BorderRadius.circular(7)),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: AppColors.violet500,
      unselectedItemColor: AppColors.ink300,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}
