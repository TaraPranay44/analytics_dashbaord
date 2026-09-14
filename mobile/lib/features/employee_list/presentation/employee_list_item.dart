import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/avatar_badge.dart';
import '../domain/entities/employee_list_item.dart' as domain;

/// One compact directory row - no charts, no multi-metric summary (that
/// content belongs only in `employee_detail`). See the correction note in
/// docs/06_MOBILE_RULES.md §6.
class EmployeeListItemRow extends StatelessWidget {
  const EmployeeListItemRow({
    super.key,
    required this.employee,
    required this.lowHoursThreshold,
    required this.onTap,
  });

  final domain.EmployeeListItem employee;

  /// Real, derived from `org_insights.low_hours_threshold` - not a
  /// fabricated status field. Null while insights are still loading.
  final double? lowHoursThreshold;
  final VoidCallback onTap;

  bool get _isLowHours =>
      lowHoursThreshold != null && employee.avgHoursOverall != null && employee.avgHoursOverall! < lowHoursThreshold!;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(13),
          boxShadow: const [BoxShadow(color: Color(0x1417153D), blurRadius: 16, offset: Offset(0, 4))],
        ),
        child: Row(
          children: [
            AvatarBadge(name: employee.employeeName, seed: employee.employeeId),
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
                          employee.employeeName,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_isLowHours) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.amber500.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Text(
                            'Low',
                            style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: AppColors.amber500),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '${employee.employeeId} · Mgr: ${employee.managerName ?? '—'}',
                    style: const TextStyle(fontSize: 10.5, color: AppColors.ink300),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              formatHours(employee.avgHoursOverall),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.ink700),
            ),
          ],
        ),
      ),
    );
  }
}
