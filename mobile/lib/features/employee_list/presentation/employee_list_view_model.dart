import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/providers/core_providers.dart';
import '../../../shared/models/paginated_result.dart';
import '../data/employee_list_local_data_source.dart';
import '../data/employee_list_remote_data_source.dart';
import '../data/employee_list_repository_impl.dart';
import '../domain/entities/employee_list_item.dart';
import '../domain/entities/employee_sort_option.dart';
import '../domain/repositories/employee_list_repository.dart';
import '../domain/use_cases/get_employee_list.dart';

// --- Data-layer wiring -------------------------------------------------

final _employeeListRemoteDataSourceProvider = Provider(
  (ref) => EmployeeListRemoteDataSource(ref.watch(dioClientProvider)),
);

final _employeeListLocalDataSourceProvider = Provider(
  (ref) => EmployeeListLocalDataSource(ref.watch(isarClientProvider)),
);

final employeeListRepositoryProvider = Provider<EmployeeListRepository>(
  (ref) => EmployeeListRepositoryImpl(
    ref.watch(_employeeListRemoteDataSourceProvider),
    ref.watch(_employeeListLocalDataSourceProvider),
  ),
);

final _getEmployeeListProvider = Provider((ref) => GetEmployeeList(ref.watch(employeeListRepositoryProvider)));

// --- Client-only UI filter state (mirrors web's uiFilterStore.ts) --------

class EmployeeListFilterState {
  const EmployeeListFilterState({
    this.q = '',
    this.manager,
    this.managerLabel,
    this.sort,
    this.start = 0,
  });

  final String q;
  final String? manager;

  /// Display label for the selected manager (e.g. "Maya Rao (EMPX-M0002)"),
  /// kept alongside the id so the manager filter field can show it without
  /// re-fetching. Purely presentation state, mirrors the combobox's own
  /// `selectedName` ref on web.
  final String? managerLabel;
  final EmployeeSortOption? sort;
  final int start;

  EmployeeListFilterState copyWith({
    String? q,
    String? manager,
    bool clearManager = false,
    String? managerLabel,
    EmployeeSortOption? sort,
    bool clearSort = false,
    int? start,
  }) {
    return EmployeeListFilterState(
      q: q ?? this.q,
      manager: clearManager ? null : (manager ?? this.manager),
      managerLabel: clearManager ? null : (managerLabel ?? this.managerLabel),
      sort: clearSort ? null : (sort ?? this.sort),
      start: start ?? this.start,
    );
  }
}

class EmployeeListFilterNotifier extends Notifier<EmployeeListFilterState> {
  @override
  EmployeeListFilterState build() => const EmployeeListFilterState();

  void setQuery(String q) => state = state.copyWith(q: q, start: 0);

  void setManager(String? employeeId, String? label) {
    state = employeeId == null
        ? state.copyWith(clearManager: true, start: 0)
        : state.copyWith(manager: employeeId, managerLabel: label, start: 0);
  }

  void setSort(EmployeeSortOption? sort) {
    state = sort == null ? state.copyWith(clearSort: true, start: 0) : state.copyWith(sort: sort, start: 0);
  }

  void nextPage(bool hasMore) {
    if (hasMore) state = state.copyWith(start: state.start + ApiConstants.pageSizeDefault);
  }

  void prevPage() {
    final prev = state.start - ApiConstants.pageSizeDefault;
    state = state.copyWith(start: prev < 0 ? 0 : prev);
  }

  void reset() => state = const EmployeeListFilterState();
}

final employeeListFilterProvider = NotifierProvider<EmployeeListFilterNotifier, EmployeeListFilterState>(
  EmployeeListFilterNotifier.new,
);

/// The landing directory page for the current filter state.
final employeeListProvider = FutureProvider<PaginatedResult<EmployeeListItem>>((ref) {
  final filter = ref.watch(employeeListFilterProvider);
  final getEmployeeList = ref.watch(_getEmployeeListProvider);
  return getEmployeeList(
    q: filter.q,
    manager: filter.manager,
    sort: filter.sort,
    start: filter.start,
    limit: ApiConstants.pageSizeDefault,
  );
});

// --- Manager-filter combobox search (reuses the same use case/endpoint,
// smaller limit, own debounced query - mirrors web's ManagerFilterCombobox) --

class ManagerSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String q) => state = q;
}

final managerSearchQueryProvider = NotifierProvider<ManagerSearchQueryNotifier, String>(
  ManagerSearchQueryNotifier.new,
);

final managerSearchIsOpenProvider = StateProvider<bool>((ref) => false);

final managerSearchResultsProvider = FutureProvider<PaginatedResult<EmployeeListItem>>((ref) {
  final q = ref.watch(managerSearchQueryProvider);
  final isOpen = ref.watch(managerSearchIsOpenProvider);
  if (!isOpen) return Future.value(const PaginatedResult(data: [], start: 0, limit: 0, hasMore: false));
  final getEmployeeList = ref.watch(_getEmployeeListProvider);
  return getEmployeeList(q: q, start: 0, limit: ApiConstants.managerResultLimit);
});
