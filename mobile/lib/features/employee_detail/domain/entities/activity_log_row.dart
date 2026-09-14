/// One `Employee Activity Log` row, as returned by `employee_logs`.
/// `loginTime`/`logoutTime` are Frappe Datetime strings ("YYYY-MM-DD HH:MM:SS");
/// `totalHours` is server-computed, never derived client-side. See
/// docs/04_BACKEND_RULES.md §4.2/§5.
class ActivityLogRow {
  const ActivityLogRow({
    required this.employee,
    required this.date,
    required this.loginTime,
    required this.logoutTime,
    required this.totalHours,
  });

  final String employee;
  final String date;
  final String? loginTime;
  final String? logoutTime;
  final double? totalHours;
}
