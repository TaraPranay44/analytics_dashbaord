"""Business logic for the org-wide dashboard and org hierarchy views.

Plain Python, no `frappe.whitelist()` here. See docs/04_BACKEND_RULES.md §1.
"""

from typing import Any


def get_org_dashboard() -> dict[str, Any]:
	"""Org-wide tiles for the landing dashboard, cached per `cache_keys.org_dashboard_key`.

	Sourced from `Org Daily Stats` — never computed by scanning raw activity logs.

	Returns:
	    Dashboard tile fields (e.g. total_employees, avg_hours_org).
	"""
	raise NotImplementedError


def get_org_hierarchy(employee_id: str) -> dict[str, Any]:
	"""Manager chain and direct reports for one employee.

	Validates the employee exists first (raises `frappe.DoesNotExistError` if not).

	Args:
	    employee_id: the `Employee.employee_id` value.

	Returns:
	    `{"manager_chain": [...], "direct_reports": [...]}`.
	"""
	raise NotImplementedError
