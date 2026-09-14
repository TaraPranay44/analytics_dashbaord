import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/providers/core_providers.dart';
import '../../../shared/models/paginated_result.dart';
import '../data/employee_detail_local_data_source.dart';
import '../data/employee_detail_remote_data_source.dart';
import '../data/employee_detail_repository_impl.dart';
import '../domain/entities/activity_log_row.dart';
import '../domain/entities/employee_detail.dart';
import '../domain/entities/monthly_trend_point.dart';
import '../domain/entities/org_hierarchy.dart';
import '../domain/repositories/employee_detail_repository.dart';
import '../domain/use_cases/get_employee_detail.dart';
import '../domain/use_cases/get_employee_logs_page.dart';
import '../domain/use_cases/get_employee_monthly_trend.dart';
import '../domain/use_cases/get_org_hierarchy.dart';

// --- Data-layer wiring -------------------------------------------------

final _employeeDetailRemoteDataSourceProvider = Provider(
  (ref) => EmployeeDetailRemoteDataSource(ref.watch(dioClientProvider)),
);

final _employeeDetailLocalDataSourceProvider = Provider(
  (ref) => EmployeeDetailLocalDataSource(ref.watch(isarClientProvider)),
);

final employeeDetailRepositoryProvider = Provider<EmployeeDetailRepository>(
  (ref) => EmployeeDetailRepositoryImpl(
    ref.watch(_employeeDetailRemoteDataSourceProvider),
    ref.watch(_employeeDetailLocalDataSourceProvider),
  ),
);

// --- Use cases -----------------------------------------------------------

final _getEmployeeDetailProvider = Provider((ref) => GetEmployeeDetail(ref.watch(employeeDetailRepositoryProvider)));
final _getOrgHierarchyProvider = Provider((ref) => GetOrgHierarchy(ref.watch(employeeDetailRepositoryProvider)));
final _getEmployeeLogsPageProvider = Provider(
  (ref) => GetEmployeeLogsPage(ref.watch(employeeDetailRepositoryProvider)),
);
final _getEmployeeMonthlyTrendProvider = Provider(
  (ref) => GetEmployeeMonthlyTrend(ref.watch(employeeDetailRepositoryProvider)),
);

// --- ViewModel (screen state), one family per employeeId ------------------

final employeeDetailProvider = FutureProvider.family<EmployeeDetail, String>(
  (ref, employeeId) => ref.watch(_getEmployeeDetailProvider)(employeeId),
);

final orgHierarchyProvider = FutureProvider.family<OrgHierarchy, String>(
  (ref, employeeId) => ref.watch(_getOrgHierarchyProvider)(employeeId),
);

/// Activity-log date-range quick filter + pagination offset for one
/// employee. Leaving both bounds null means "all time" - mirrors web's
/// `useDateRangeFilter` composable.
class EmployeeLogsFilterState {
  const EmployeeLogsFilterState({this.fromDate, this.toDate, this.start = 0});

  final String? fromDate;
  final String? toDate;
  final int start;
}

class EmployeeLogsFilterNotifier extends FamilyNotifier<EmployeeLogsFilterState, String> {
  @override
  EmployeeLogsFilterState build(String arg) => const EmployeeLogsFilterState();

  void applyLastNDays(int days) {
    final today = DateTime.now();
    final from = today.subtract(Duration(days: days));
    state = EmployeeLogsFilterState(fromDate: _isoDate(from), toDate: _isoDate(today), start: 0);
  }

  void clearRange() => state = const EmployeeLogsFilterState();

  void nextPage(bool hasMore) {
    if (hasMore) state = EmployeeLogsFilterState(fromDate: state.fromDate, toDate: state.toDate, start: state.start + ApiConstants.pageSizeDefault);
  }

  void prevPage() {
    final prev = state.start - ApiConstants.pageSizeDefault;
    state = EmployeeLogsFilterState(fromDate: state.fromDate, toDate: state.toDate, start: prev < 0 ? 0 : prev);
  }

  static String _isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

final employeeLogsFilterProvider = NotifierProvider.family<EmployeeLogsFilterNotifier, EmployeeLogsFilterState, String>(
  EmployeeLogsFilterNotifier.new,
);

final employeeLogsProvider = FutureProvider.family<PaginatedResult<ActivityLogRow>, String>((ref, employeeId) {
  final filter = ref.watch(employeeLogsFilterProvider(employeeId));
  final getEmployeeLogsPage = ref.watch(_getEmployeeLogsPageProvider);
  return getEmployeeLogsPage(
    employeeId: employeeId,
    fromDate: filter.fromDate,
    toDate: filter.toDate,
    start: filter.start,
    limit: ApiConstants.pageSizeDefault,
  );
});

/// Which window the "Time spent / day" chart is showing.
enum ChartWindow { sevenDays, thirtyDays, lifetime }

final chartWindowProvider = StateProvider.family<ChartWindow, String>((ref, employeeId) => ChartWindow.thirtyDays);

/// Lazy: `employee_monthly_trend` is a separate endpoint from the daily
/// `trend` on `employee_detail`, fetched only once the user actually
/// switches to the "Lifetime" view - mirrors web's `useEmployeeMonthlyTrend`.
final employeeMonthlyTrendProvider = FutureProvider.family<List<MonthlyTrendPoint>, String>((ref, employeeId) {
  final window = ref.watch(chartWindowProvider(employeeId));
  if (window != ChartWindow.lifetime) return Future.value(const <MonthlyTrendPoint>[]);
  return ref.watch(_getEmployeeMonthlyTrendProvider)(employeeId);
});
