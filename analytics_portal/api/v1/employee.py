"""Whitelisted API endpoints: employee_list, employee_detail.

Thin layer only - parse/validate params, call the service, shape the response.
No business logic here. See docs/04_BACKEND_RULES.md §1/§5.

⚠️ Correction note (post-review): `employee_search`/`employee_summary` were
renamed/merged into `employee_list`/`employee_detail` to match the corrected
§5 table - a name/ID search can return hundreds of the 30,000 employees, so
`employee_list` is always a paginated list (optional `q`, browse-all when
empty), and `employee_detail` absorbs the old summary-card fields since they
only ever load once a specific employee is opened.
"""

import frappe

from analytics_portal.constants.api_constants import PAGE_SIZE_DEFAULT, PAGE_SIZE_MAX
from analytics_portal.services import employee_service


@frappe.whitelist()
def employee_list(
	q: str = "",
	manager: str | None = None,
	sort: str | None = None,
	start: int = 0,
	limit: int = PAGE_SIZE_DEFAULT,
) -> dict:
	"""Paginated, filterable employee directory - powers the landing page.

	Args:
	    q: name/ID search fragment; empty string (default) means browse-all.
	    manager: optional manager `employee_id` filter.
	    sort: optional sort spec.
	    start: zero-based row offset (default 0).
	    limit: max results to return (default PAGE_SIZE_DEFAULT, capped at PAGE_SIZE_MAX).

	Returns:
	    `{"data": [...], "start": int, "limit": int, "has_more": bool}`.
	"""
	capped_limit = min(int(limit), PAGE_SIZE_MAX)
	return employee_service.list_employees(q, manager, sort, int(start), capped_limit)


@frappe.whitelist()
def employee_detail(employee_id: str) -> dict:
	"""Full detail for one employee: identity, manager chain, summary metrics, trend series.

	Args:
	    employee_id: the `Employee.employee_id` value.

	Returns:
	    Employee detail fields, manager chain, summary metrics, and trend series.
	"""
	return employee_service.get_employee_detail(employee_id)
