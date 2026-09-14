import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/utils/debouncer.dart';
import 'employee_list_view_model.dart';

/// Manager filter field - mobile adaptation of web's `ManagerFilterCombobox.vue`
/// (an inline dropdown-while-typing combobox, a web-only affordance). Opens a
/// modal sheet with the same debounced search over `employee_list` (small
/// `limit`, no `manager`/`sort` filters) and the same "first N matches, keep
/// typing" hint - same endpoint/semantics, mobile-appropriate presentation.
class ManagerFilterField extends ConsumerWidget {
  const ManagerFilterField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(employeeListFilterProvider);

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _openManagerSearchSheet(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Text('MGR', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.ink300)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                filter.managerLabel ?? 'Any',
                style: const TextStyle(fontSize: 11.5),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openManagerSearchSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ManagerSearchSheet(),
    );
  }
}

class _ManagerSearchSheet extends ConsumerStatefulWidget {
  const _ManagerSearchSheet();

  @override
  ConsumerState<_ManagerSearchSheet> createState() => _ManagerSearchSheetState();
}

class _ManagerSearchSheetState extends ConsumerState<_ManagerSearchSheet> {
  final _debouncer = Debouncer(const Duration(milliseconds: ApiConstants.searchDebounceMs));

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(managerSearchIsOpenProvider.notifier).state = true);
  }

  @override
  void dispose() {
    _debouncer.dispose();
    ref.read(managerSearchIsOpenProvider.notifier).state = false;
    ref.read(managerSearchQueryProvider.notifier).setQuery('');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(managerSearchResultsProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter by manager', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              TextField(
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Search managers by name or ID…'),
                onChanged: (value) => _debouncer.run(
                  () => ref.read(managerSearchQueryProvider.notifier).setQuery(value),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  ref.read(employeeListFilterProvider.notifier).setManager(null, null);
                  Navigator.of(context).pop();
                },
                child: const Text('Clear manager filter'),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: resultsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
                  ),
                  error: (_, __) => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Search failed.', style: TextStyle(color: AppColors.ink500)),
                  ),
                  data: (results) {
                    if (results.data.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No employees found.', style: TextStyle(color: AppColors.ink500)),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: results.data.length,
                      itemBuilder: (context, index) {
                        final row = results.data[index];
                        return ListTile(
                          title: Text(row.employeeName),
                          subtitle: Text(row.employeeId),
                          onTap: () {
                            ref
                                .read(employeeListFilterProvider.notifier)
                                .setManager(row.employeeId, '${row.employeeName} (${row.employeeId})');
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
