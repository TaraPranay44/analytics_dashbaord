import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/errors/failures.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/avatar_badge.dart';
import 'activity_log_list.dart';
import 'employee_detail_view_model.dart';
import 'employee_summary_panel.dart';
import 'employee_trend_chart.dart';
import 'org_hierarchy_card.dart';

/// Employee detail screen - header, manager/reports, profile, performance
/// summary, trend chart, and paginated activity log. Matches the attached
/// `mobile-employee-detail.html` mockup and
/// web/src/views/EmployeeDetailView.vue's data wiring.
class EmployeeDetailView extends ConsumerWidget {
  const EmployeeDetailView({super.key, required this.employeeId});

  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(employeeDetailProvider(employeeId));

    return Scaffold(
      backgroundColor: AppColors.bgOuter,
      body: SafeArea(
        child: detailAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
          error: (err, _) {
            final message = err is Failure ? err.message : StringConstants.employeeNotFound;
            return _ErrorState(message: message);
          },
          data: (detail) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back, size: 20),
                        style: IconButton.styleFrom(backgroundColor: AppColors.white, shape: const StadiumBorder()),
                      ),
                      const SizedBox(width: 10),
                      AvatarBadge(name: detail.employeeName, seed: detail.employeeId, size: 44, fontSize: 13),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    detail.employeeName,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(100)),
                                  child: Text(
                                    detail.employeeId,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.ink500),
                                  ),
                                ),
                              ],
                            ),
                            if (detail.dateOfJoining != null)
                              Text(
                                'Joined ${detail.dateOfJoining}',
                                style: const TextStyle(fontSize: 10.5, color: AppColors.ink500),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                sliver: SliverList.list(
                  children: [
                    Consumer(
                      builder: (context, ref, _) {
                        final hierarchyAsync = ref.watch(orgHierarchyProvider(employeeId));
                        return hierarchyAsync.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
                          ),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (hierarchy) => OrgHierarchyCard(
                            hierarchy: hierarchy,
                            onPersonTap: (id) => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => EmployeeDetailView(employeeId: id)),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    EmployeeSummaryPanel(detail: detail),
                    const SizedBox(height: 14),
                    EmployeeTrendChartCard(employeeId: employeeId, trend: detail.trend),
                    const SizedBox(height: 14),
                    ActivityLogList(employeeId: employeeId),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_off_outlined, size: 32, color: AppColors.ink300),
            const SizedBox(height: 10),
            Text(message, style: const TextStyle(color: AppColors.ink500, fontSize: 13), textAlign: TextAlign.center),
            const SizedBox(height: 14),
            TextButton(onPressed: () => Navigator.of(context).maybePop(), child: const Text('Back to dashboard')),
          ],
        ),
      ),
    );
  }
}
