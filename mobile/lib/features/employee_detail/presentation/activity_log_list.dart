import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/string_constants.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/pagination_bar.dart';
import '../domain/entities/activity_log_row.dart';
import 'employee_detail_view_model.dart';

/// Date-range quick filter + paginated daily activity log - mirrors
/// web/src/components/DateRangeFilter.vue + ActivityLogTable.vue combined
/// into one card, matching the attached mobile mockup's "Daily activity log"
/// section.
class ActivityLogList extends ConsumerWidget {
  const ActivityLogList({super.key, required this.employeeId});

  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(employeeLogsFilterProvider(employeeId));
    final logsAsync = ref.watch(employeeLogsProvider(employeeId));
    final notifier = ref.read(employeeLogsFilterProvider(employeeId).notifier);

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
          const Text('Daily activity log', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(label: 'Last 7 days', onTap: () => notifier.applyLastNDays(7)),
              _FilterChip(label: 'Last 30 days', onTap: () => notifier.applyLastNDays(30)),
              _FilterChip(label: 'All time', onTap: notifier.clearRange),
              if (filter.fromDate != null && filter.toDate != null)
                Chip(
                  label: Text('${filter.fromDate} → ${filter.toDate}', style: const TextStyle(fontSize: 10.5)),
                  backgroundColor: AppColors.bgPage,
                  side: BorderSide.none,
                ),
            ],
          ),
          const SizedBox(height: 12),
          AsyncValueView(
            value: logsAsync,
            data: (page) {
              if (page.data.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text(StringConstants.noLogs, style: TextStyle(color: AppColors.ink300, fontSize: 12))),
                );
              }
              return Column(
                children: [
                  ...page.data.map((row) => _LogRow(row: row)),
                  const SizedBox(height: 4),
                  PaginationBar(
                    start: page.start,
                    rowCount: page.data.length,
                    hasMore: page.hasMore,
                    onPrev: notifier.prevPage,
                    onNext: () => notifier.nextPage(page.hasMore),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.bgPage,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.ink700)),
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({required this.row});

  final ActivityLogRow row;

  @override
  Widget build(BuildContext context) {
    final inProgress = row.logoutTime == null;
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppColors.bgPage, borderRadius: BorderRadius.circular(11)),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(formatDateLabel(row.date), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: inProgress ? AppColors.violet500 : AppColors.teal500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      inProgress ? 'In progress' : 'Completed',
                      style: const TextStyle(fontSize: 9.5, color: AppColors.ink300),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                _TimeCol(label: 'Login', value: formatClockTime(row.loginTime)),
                const SizedBox(width: 10),
                _TimeCol(label: 'Logout', value: formatClockTime(row.logoutTime)),
              ],
            ),
          ),
          Text(
            row.totalHours == null ? '—' : formatHours(row.totalHours),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.violet500),
          ),
        ],
      ),
    );
  }
}

class _TimeCol extends StatelessWidget {
  const _TimeCol({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        Text(label, style: const TextStyle(fontSize: 8.5, color: AppColors.ink300)),
      ],
    );
  }
}
