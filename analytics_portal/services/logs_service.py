"""Business logic for paginated employee activity log retrieval.

Plain Python, no `frappe.whitelist()` here. See docs/04_BACKEND_RULES.md §1.
"""

from typing import Any

from analytics_portal.repositories import activity_log_repo
from analytics_portal.utils.date_utils import resolve_date_range
from analytics_portal.utils.validators import assert_employee_exists


def get_employee_logs_page(
	employee_id: str,
	from_date: str | None,
	to_date: str | None,
	start: int,
	limit: int,
) -> dict[str, Any]:
	"""Return one paginated page of an employee's activity log.

	Validates the employee exists first (raises `frappe.DoesNotExistError` if not),
	resolves the date range, then delegates to `activity_log_repo`.

	Args:
	    employee_id: the `Employee.employee_id` value.
	    from_date: ISO date string lower bound, or None.
	    to_date: ISO date string upper bound, or None.
	    start: zero-based row offset.
	    limit: page size, already capped at PAGE_SIZE_MAX by the API layer.

	Returns:
	    `{"data": [...], "start": start, "limit": limit, "has_more": bool}`.
	"""
	assert_employee_exists(employee_id)
	resolved_from, resolved_to = resolve_date_range(from_date, to_date)

	rows = activity_log_repo.get_employee_logs_page(employee_id, resolved_from, resolved_to, start, limit)
	total = activity_log_repo.count_employee_logs(employee_id, resolved_from, resolved_to)

	return {
		"data": rows,
		"start": start,
		"limit": limit,
		"has_more": start + len(rows) < total,
	}
