import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Shared pager for every paginated list (`employee_list`, `employee_logs`)
/// - mirrors web/src/components/Pagination.vue. Drives the backend's
/// `start`/`limit` contract; never used to paginate an already-fetched full
/// list client-side - see docs/06_MOBILE_RULES.md §5/§8.
class PaginationBar extends StatelessWidget {
  const PaginationBar({
    super.key,
    required this.start,
    required this.rowCount,
    required this.hasMore,
    required this.onPrev,
    required this.onNext,
    this.loading = false,
  });

  final int start;
  final int rowCount;
  final bool hasMore;
  final bool loading;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final label = rowCount > 0
        ? 'Showing ${start + 1}–${start + rowCount}${hasMore ? ' · more available' : ''}'
        : 'No rows to show';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.ink300),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: (start > 0 && !loading) ? onPrev : null,
            child: const Text('← Prev', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: (hasMore && !loading) ? onNext : null,
            child: const Text(
              'Next →',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.violet500),
            ),
          ),
        ],
      ),
    );
  }
}
