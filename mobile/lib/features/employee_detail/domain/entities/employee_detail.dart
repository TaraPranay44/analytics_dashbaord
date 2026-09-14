/// One entry of an employee's manager chain - `employee_detail.manager_chain`
/// / `org_hierarchy.manager_chain`, immediate manager first.
class ManagerChainEntry {
  const ManagerChainEntry({required this.employeeId, required this.employeeName});

  final String employeeId;
  final String employeeName;
}

/// One point of `employee_detail`'s `trend` series - raw recent daily hours,
/// last `EMPLOYEE_DETAIL_TREND_DAYS` days, oldest first.
class TrendPoint {
  const TrendPoint({required this.date, required this.totalHours});

  final String date;
  final double totalHours;
}

/// Full shape returned by `employee_detail`: identity, manager chain,
/// summary metrics (from `Employee Overall Stats`), and the trend series.
/// See docs/04_BACKEND_RULES.md §5.
class EmployeeDetail {
  const EmployeeDetail({
    required this.employeeId,
    required this.employeeName,
    required this.dateOfJoining,
    required this.manager,
    required this.managerChain,
    required this.avgHoursOverall,
    required this.avgLoginTimeOverall,
    required this.avgLogoutTimeOverall,
    required this.trend,
  });

  final String employeeId;
  final String employeeName;
  final String? dateOfJoining;
  final String? manager;
  final List<ManagerChainEntry> managerChain;
  final double avgHoursOverall;
  final String? avgLoginTimeOverall;
  final String? avgLogoutTimeOverall;
  final List<TrendPoint> trend;
}
