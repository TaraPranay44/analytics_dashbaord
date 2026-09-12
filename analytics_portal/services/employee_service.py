"""Business logic for employee search, summary, and detail.

Plain Python, no `frappe.whitelist()` here — testable in isolation from HTTP.
See docs/04_BACKEND_RULES.md §1.
"""

from typing import Any


def search_employees(query: str, limit: int) -> dict[str, Any]:
	"""Search employees by name/ID, cached for 90s per `cache_keys.search_key`.

	Args:
	    query: the raw search string.
	    limit: max results to return, already capped at PAGE_SIZE_MAX by the API layer.

	Returns:
	    `{"data": [...], "start": 0, "limit": limit, "has_more": bool}`.
	"""
	raise NotImplementedError


def get_employee_summary(employee_id: str) -> dict[str, Any]:
	"""Summary card data for one employee, sourced from `Employee Overall Stats`.

	Validates the employee exists first (raises `frappe.DoesNotExistError` if not),
	then reads the cached/precomputed overall stats — never raw activity logs.

	Args:
	    employee_id: the `Employee.employee_id` value.

	Returns:
	    Summary fields for the employee.
	"""
	raise NotImplementedError


def get_employee_detail(employee_id: str) -> dict[str, Any]:
	"""Full employee detail including the manager chain.

	Validates the employee exists first (raises `frappe.DoesNotExistError` if not).

	Args:
	    employee_id: the `Employee.employee_id` value.

	Returns:
	    Employee detail fields plus the ordered manager chain.
	"""
	raise NotImplementedError
