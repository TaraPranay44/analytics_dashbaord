import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/string_constants.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/utils/debouncer.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/pagination_bar.dart';
import '../../dashboard/presentation/dashboard_view_model.dart';
import '../domain/entities/employee_sort_option.dart';
import 'employee_list_item.dart';
import 'employee_list_view_model.dart';
import 'manager_filter_field.dart';

/// The employee directory section (search, filters, paginated rows, pager) -
/// embedded inside `DashboardView`'s scaffold, exactly as the reference
/// mockup composes them on one screen. Kept as its own feature/file per
/// docs/06_MOBILE_RULES.md §6: no inline charts or multi-metric summaries in
/// a row (see `EmployeeListItemRow`'s doc comment).
class EmployeeListView extends ConsumerStatefulWidget {
  const EmployeeListView({super.key, required this.onEmployeeTap});

  final void Function(String employeeId) onEmployeeTap;

  @override
  ConsumerState<EmployeeListView> createState() => _EmployeeListViewState();
}

class _EmployeeListViewState extends ConsumerState<EmployeeListView> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(const Duration(milliseconds: ApiConstants.searchDebounceMs));

  @override
  void dispose() {
    _debouncer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(employeeListFilterProvider);
    final listAsync = ref.watch(employeeListProvider);
    final insightsAsync = ref.watch(orgInsightsProvider);
    final lowHoursThreshold = insightsAsync.valueOrNull?.lowHoursThreshold;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SearchBar(
          controller: _searchController,
          onChanged: (value) => _debouncer.run(
            () => ref.read(employeeListFilterProvider.notifier).setQuery(value),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Expanded(child: ManagerFilterField()),
            const SizedBox(width: 8),
            Expanded(child: _SortFilter(current: filter.sort)),
            TextButton(
              onPressed: () {
                _searchController.clear();
                ref.read(employeeListFilterProvider.notifier).reset();
              },
              child: const Text('Clear', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'All employees',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink500),
            ),
            if (listAsync.valueOrNull != null)
              Text(
                '${_totalKnownSoFar(listAsync.valueOrNull!.start, listAsync.valueOrNull!.data.length, listAsync.valueOrNull!.hasMore)} results',
                style: const TextStyle(fontSize: 11, color: AppColors.ink300),
              ),
          ],
        ),
        const SizedBox(height: 8),
        AsyncValueView(
          value: listAsync,
          data: (page) {
            if (page.data.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(StringConstants.noResults, style: TextStyle(color: AppColors.ink300, fontSize: 12.5)),
                ),
              );
            }
            return Column(
              children: [
                ...page.data.map(
                  (employee) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: EmployeeListItemRow(
                      employee: employee,
                      lowHoursThreshold: lowHoursThreshold,
                      onTap: () => widget.onEmployeeTap(employee.employeeId),
                    ),
                  ),
                ),
                PaginationBar(
                  start: page.start,
                  rowCount: page.data.length,
                  hasMore: page.hasMore,
                  onPrev: () => ref.read(employeeListFilterProvider.notifier).prevPage(),
                  onNext: () => ref.read(employeeListFilterProvider.notifier).nextPage(page.hasMore),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  String _totalKnownSoFar(int start, int rowCount, bool hasMore) =>
      '${start + rowCount}${hasMore ? '+' : ''}';
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: AppColors.ink500),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: StringConstants.searchPlaceholder,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortFilter extends ConsumerWidget {
  const _SortFilter({required this.current});

  final EmployeeSortOption? current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<EmployeeSortOption?>(
          value: current,
          isExpanded: true,
          isDense: true,
          style: const TextStyle(fontSize: 11.5, color: AppColors.ink900),
          items: [
            const DropdownMenuItem(value: null, child: Text('Name A–Z')),
            ...EmployeeSortOption.values
                .where((o) => o != EmployeeSortOption.nameAsc)
                .map((o) => DropdownMenuItem(value: o, child: Text(o.label))),
          ],
          onChanged: (value) => ref.read(employeeListFilterProvider.notifier).setSort(value),
        ),
      ),
    );
  }
}
