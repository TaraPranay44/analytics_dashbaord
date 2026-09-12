"""Whitelisted API endpoints: employee_search, employee_summary, employee_detail.

Thin layer only — parse/validate params, call the service, shape the response.
No business logic here. See docs/04_BACKEND_RULES.md §1/§5.
"""

import frappe

from analytics_portal.constants.api_constants import PAGE_SIZE_DEFAULT
from analytics_portal.services import employee_service


@frappe.whitelist()
def employee_search(q: str, limit: int = PAGE_SIZE_DEFAULT) -> dict:
	"""Autocomplete employee search by name/ID.

	Args:
	    q: search query string.
	    limit: max results to return (default PAGE_SIZE_DEFAULT, capped at PAGE_SIZE_MAX).

	Returns:
	    `{"data": [...], "start": int, "limit": int, "has_more": bool}`.
	"""
	raise NotImplementedError


@frappe.whitelist()
def employee_summary(employee_id: str) -> dict:
	"""Summary card data for one employee.

	Args:
	    employee_id: the `Employee.employee_id` value.

	Returns:
	    Summary fields sourced from `Employee Overall Stats`.
	"""
	raise NotImplementedError


@frappe.whitelist()
def employee_detail(employee_id: str) -> dict:
	"""Full employee detail including the manager chain.

	Args:
	    employee_id: the `Employee.employee_id` value.

	Returns:
	    Employee detail fields plus the manager chain.
	"""
	raise NotImplementedError
