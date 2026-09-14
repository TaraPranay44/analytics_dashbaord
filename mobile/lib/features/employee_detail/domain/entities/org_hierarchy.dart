import 'employee_detail.dart';

/// A direct report - `org_hierarchy.direct_reports` entry.
class DirectReport {
  const DirectReport({required this.employeeId, required this.employeeName});

  final String employeeId;
  final String employeeName;
}

/// Full shape returned by `org_hierarchy` - manager chain and direct reports
/// for one employee. See docs/04_BACKEND_RULES.md §5.
class OrgHierarchy {
  const OrgHierarchy({required this.managerChain, required this.directReports});

  final List<ManagerChainEntry> managerChain;
  final List<DirectReport> directReports;
}
