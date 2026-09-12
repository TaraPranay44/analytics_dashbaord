"""All DB access for the `Employee` DocType.

Only `frappe.qb` / `frappe.db.sql` / `frappe.get_all` calls touching `Employee`
belong here — see docs/04_BACKEND_RULES.md §1 (API -> Service -> Repository -> DB,
never skip a layer) and §7 (always explicit `fields=[...]`, never `select *`).
"""

from typing import Any


def search_employees(query: str, limit: int) -> list[dict[str, Any]]:
	"""Search `Employee` by name/ID for autocomplete.

	Args:
	    query: the raw search string (name or employee_id fragment).
	    limit: max rows to return; caller has already capped this at PAGE_SIZE_MAX.

	Returns:
	    A list of matching employee summary dicts.
	"""
	raise NotImplementedError


def get_employee_by_id(employee_id: str) -> dict[str, Any] | None:
	"""Fetch one `Employee` row by its `employee_id`.

	Args:
	    employee_id: the `Employee.employee_id` value.

	Returns:
	    The employee record as a dict, or None if not found.
	"""
	raise NotImplementedError


def get_manager_chain(employee_id: str) -> list[dict[str, Any]]:
	"""Walk the self-referential `manager` link up to the top of the chain.

	Args:
	    employee_id: the `Employee.employee_id` value to start from.

	Returns:
	    Ordered list of manager records, immediate manager first.
	"""
	raise NotImplementedError


def get_direct_reports(employee_id: str) -> list[dict[str, Any]]:
	"""Fetch employees whose `manager` points at `employee_id`.

	Args:
	    employee_id: the `Employee.employee_id` value of the manager.

	Returns:
	    A list of direct-report employee records.
	"""
	raise NotImplementedError
