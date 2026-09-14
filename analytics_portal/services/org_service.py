"""Business logic for the org-wide dashboard and org hierarchy views.

Plain Python, no `frappe.whitelist()` here. See docs/04_BACKEND_RULES.md §1.
"""

from typing import Any

from analytics_portal.constants.cache_keys import org_dashboard_key
from analytics_portal.repositories import employee_repo, stats_repo
from analytics_portal.utils.cache_utils import get_or_set
from analytics_portal.utils.validators import assert_employee_exists


def get_org_dashboard() -> dict[str, Any]:
	"""Org-wide tiles for the landing dashboard, cached per `cache_keys.org_dashboard_key`.

	Sourced from the most recent `Org Daily Stats` row - never computed by
	scanning raw activity logs.

	Returns:
	    Dashboard tile fields: `date`, `total_employees`, `avg_hours_org`,
	    `avg_login_time_org` - all `0`/None if no stats have been computed yet.
	"""

	def _compute() -> dict[str, Any]:
		latest = stats_repo.get_latest_org_daily_stats()
		if not latest:
			return {"date": None, "total_employees": 0, "avg_hours_org": 0.0, "avg_login_time_org": None}
		return {
			"date": latest.date,
			"total_employees": latest.total_employees,
			"avg_hours_org": latest.avg_hours_org,
			"avg_login_time_org": latest.avg_login_time_org,
		}

	return get_or_set(org_dashboard_key(), None, _compute)


def get_org_hierarchy(employee_id: str) -> dict[str, Any]:
	"""Manager chain and direct reports for one employee.

	Validates the employee exists first (raises `frappe.DoesNotExistError` if not).

	Args:
	    employee_id: the `Employee.employee_id` value.

	Returns:
	    `{"manager_chain": [...], "direct_reports": [...]}`.
	"""
	assert_employee_exists(employee_id)
	return {
		"manager_chain": employee_repo.get_manager_chain(employee_id),
		"direct_reports": employee_repo.get_direct_reports(employee_id),
	}
