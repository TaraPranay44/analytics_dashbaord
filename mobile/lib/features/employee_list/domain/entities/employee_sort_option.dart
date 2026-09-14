/// The only two sorts `employee_list` actually supports server-side
/// (`analytics_portal/repositories/employee_repo.py::list_employees`):
/// `sort == "hours"` orders by `avg_hours_overall` descending, anything else
/// (including omitted) orders by name ascending. There is no server-side
/// ascending-hours sort - don't add a third option that can't be honored.
enum EmployeeSortOption {
  nameAsc('Name A–Z', null),
  hoursDesc('Avg hrs/day (high–low)', 'hours');

  const EmployeeSortOption(this.label, this.apiValue);

  final String label;
  final String? apiValue;
}
