"""Business logic for paginated employee activity log retrieval.

Plain Python, no `frappe.whitelist()` here. See docs/04_BACKEND_RULES.md §1.
"""

from typing import Any


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
	raise NotImplementedError
