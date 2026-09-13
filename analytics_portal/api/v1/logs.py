"""Whitelisted API endpoint: employee_logs.

Thin layer only - parse/validate params, call the service, shape the response.
No business logic here. See docs/04_BACKEND_RULES.md §1/§5.
"""

import frappe

from analytics_portal.constants.api_constants import PAGE_SIZE_DEFAULT, PAGE_SIZE_MAX
from analytics_portal.services import logs_service


@frappe.whitelist()
def employee_logs(
	employee_id: str,
	from_date: str | None = None,
	to_date: str | None = None,
	start: int = 0,
	limit: int = PAGE_SIZE_DEFAULT,
) -> dict:
	"""Paginated activity log for one employee.

	Args:
	    employee_id: the `Employee.employee_id` value.
	    from_date: optional ISO date string lower bound.
	    to_date: optional ISO date string upper bound.
	    start: zero-based row offset (default 0).
	    limit: page size (default PAGE_SIZE_DEFAULT, capped at PAGE_SIZE_MAX).

	Returns:
	    `{"data": [...], "start": int, "limit": int, "has_more": bool}`.
	"""
	capped_limit = min(int(limit), PAGE_SIZE_MAX)
	return logs_service.get_employee_logs_page(employee_id, from_date, to_date, int(start), capped_limit)
