/// One compact row from `employee_list` - the landing directory table.
/// Intentionally narrower than `EmployeeDetail` - not a slice of it. See the
/// correction note in docs/06_MOBILE_RULES.md §6: a list row never carries
/// charts or multi-metric detail, only what powers a dense list row.
class EmployeeListItem {
  const EmployeeListItem({
    required this.employeeId,
    required this.employeeName,
    required this.manager,
    required this.managerName,
    required this.avgHoursOverall,
    required this.avgLoginTimeOverall,
  });

  final String employeeId;
  final String employeeName;
  final String? manager;
  final String? managerName;
  final double? avgHoursOverall;
  final String? avgLoginTimeOverall;
}
