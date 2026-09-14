import 'dart:async';
import 'dart:developer' as developer;

import '../../../core/errors/failures.dart';
import '../../../shared/models/paginated_result.dart';
import '../domain/entities/employee_list_item.dart';
import '../domain/entities/employee_sort_option.dart';
import '../domain/repositories/employee_list_repository.dart';
import 'employee_list_local_data_source.dart';
import 'employee_list_remote_data_source.dart';

/// Read-through cache pattern from docs/06_MOBILE_RULES.md §2 - see
/// `OrgRepositoryImpl` for the full explanation, same shape here.
class EmployeeListRepositoryImpl implements EmployeeListRepository {
  const EmployeeListRepositoryImpl(this._remote, this._local);

  final EmployeeListRemoteDataSource _remote;
  final EmployeeListLocalDataSource _local;

  @override
  Future<PaginatedResult<EmployeeListItem>> getEmployeeList({
    required String q,
    required String? manager,
    required EmployeeSortOption? sort,
    required int start,
    required int limit,
  }) async {
    final cachedJson = await _local.readCached(
      q: q,
      manager: manager,
      sort: sort,
      start: start,
      limit: limit,
    );
    if (cachedJson != null) {
      unawaited(_refreshSilently(q: q, manager: manager, sort: sort, start: start, limit: limit));
      return employeeListResultFromJson(cachedJson);
    }
    return _fetchAndCache(q: q, manager: manager, sort: sort, start: start, limit: limit);
  }

  Future<PaginatedResult<EmployeeListItem>> _fetchAndCache({
    required String q,
    required String? manager,
    required EmployeeSortOption? sort,
    required int start,
    required int limit,
  }) async {
    try {
      final json = await _remote.fetchEmployeeListJson(
        q: q,
        manager: manager,
        sort: sort,
        start: start,
        limit: limit,
      );
      await _local.writeCached(q: q, manager: manager, sort: sort, start: start, limit: limit, json: json);
      return employeeListResultFromJson(json);
    } catch (e) {
      developer.log('employee_list fetch failed: $e', name: 'EmployeeListRepositoryImpl');
      throw const NetworkFailure();
    }
  }

  Future<void> _refreshSilently({
    required String q,
    required String? manager,
    required EmployeeSortOption? sort,
    required int start,
    required int limit,
  }) async {
    try {
      final json = await _remote.fetchEmployeeListJson(
        q: q,
        manager: manager,
        sort: sort,
        start: start,
        limit: limit,
      );
      await _local.writeCached(q: q, manager: manager, sort: sort, start: start, limit: limit, json: json);
    } catch (e) {
      developer.log('employee_list background refresh failed: $e', name: 'EmployeeListRepositoryImpl');
    }
  }
}
