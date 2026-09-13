"""Business logic for the employee directory and employee detail views.

Plain Python, no `frappe.whitelist()` here - testable in isolation from HTTP.
See docs/04_BACKEND_RULES.md §1.

⚠️ Correction note (post-review): `search_employees`/`get_employee_summary` were
renamed/merged into `list_employees`/`get_employee_detail` to match the
corrected `employee_list`/`employee_detail` endpoints in §5 - a name/ID search
can return hundreds of the 30,000 employees, so there is no single "summary"
result; per-employee detail (including summary metrics) only ever loads once
one specific employee is opened.
"""

from typing import Any

from analytics_portal.constants.cache_keys import employee_detail_key, employee_list_key
from analytics_portal.repositories import activity_log_repo, employee_repo, stats_repo
from analytics_portal.utils.cache_utils import get_or_set
from analytics_portal.utils.validators import assert_employee_exists

_EMPLOYEE_LIST_CACHE_TTL_SECONDS = 90
_TREND_SERIES_DAYS = 30


def list_employees(q: str, manager: str | None, sort: str | None, start: int, limit: int) -> dict[str, Any]:
	"""Paginated, filterable employee directory - powers the landing page.

	Cached for `_EMPLOYEE_LIST_CACHE_TTL_SECONDS`, per docs/04_BACKEND_RULES.md §6.

	Args:
	    q: name/ID search fragment; empty string means browse-all.
	    manager: optional manager `employee_id` filter.
	    sort: optional sort spec.
	    start: zero-based row offset.
	    limit: max results to return, already capped at PAGE_SIZE_MAX by the API layer.

	Returns:
	    `{"data": [...], "start": start, "limit": limit, "has_more": bool}`.
	"""
	cache_key = employee_list_key(q, manager, sort, start, limit)

	def _compute() -> dict[str, Any]:
		rows = employee_repo.list_employees(q, manager, sort, start, limit)
		total = employee_repo.count_employees(q, manager)
		return {
			"data": rows,
			"start": start,
			"limit": limit,
			"has_more": start + len(rows) < total,
		}

	return get_or_set(cache_key, _EMPLOYEE_LIST_CACHE_TTL_SECONDS, _compute)


def get_employee_detail(employee_id: str) -> dict[str, Any]:
	"""Full employee detail: identity, manager chain, summary metrics, trend series.

	Validates the employee exists first (raises `frappe.DoesNotExistError` if
	not), then reads summary metrics from `Employee Overall Stats` - never raw
	activity logs - plus a recent daily-hours trend series for the detail-page
	chart. Cached until the next aggregation run, per docs/04_BACKEND_RULES.md §6.

	Args:
	    employee_id: the `Employee.employee_id` value.

	Returns:
	    Employee identity fields, the ordered manager chain, summary metrics
	    (`avg_hours_overall`, `avg_login_time_overall`, `avg_logout_time_overall`),
	    and a `trend` series of `{"date", "total_hours"}` for the last
	    `_TREND_SERIES_DAYS` days.
	"""
	assert_employee_exists(employee_id)
	cache_key = employee_detail_key(employee_id)

	def _compute() -> dict[str, Any]:
		employee = employee_repo.get_employee_by_id(employee_id)
		manager_chain = employee_repo.get_manager_chain(employee_id)
		overall_stats = stats_repo.get_employee_overall_stats(employee_id)
		trend = activity_log_repo.get_recent_daily_hours(employee_id, _TREND_SERIES_DAYS)

		return {
			"employee_id": employee.employee_id,
			"employee_name": employee.employee_name,
			"date_of_joining": employee.date_of_joining,
			"manager": employee.manager,
			"manager_chain": manager_chain,
			"avg_hours_overall": overall_stats.avg_hours_overall if overall_stats else 0.0,
			"avg_login_time_overall": overall_stats.avg_login_time_overall if overall_stats else None,
			"avg_logout_time_overall": overall_stats.avg_logout_time_overall if overall_stats else None,
			"trend": trend,
		}

	return get_or_set(cache_key, None, _compute)
