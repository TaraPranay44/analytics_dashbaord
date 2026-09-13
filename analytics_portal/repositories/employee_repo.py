"""All DB access for the `Employee` DocType.

Only `frappe.qb` / `frappe.db.sql` / `frappe.get_all` calls touching `Employee`
belong here - see docs/04_BACKEND_RULES.md §1 (API -> Service -> Repository -> DB,
never skip a layer) and §7 (always explicit `fields=[...]`, never `select *`).
"""

from typing import Any

import frappe
from frappe.query_builder import Criterion, DocType, Order
from frappe.query_builder.functions import Count

from analytics_portal.utils.pagination import paginate


def _name_or_id_condition(employee: Any, q: str) -> Criterion:
	"""Build the OR-matched name/ID search condition shared by list/count."""
	pattern = f"%{q}%"
	return Criterion.any([employee.employee_name.like(pattern), employee.employee_id.like(pattern)])


def list_employees(
	q: str,
	manager: str | None,
	sort: str | None,
	start: int,
	limit: int,
) -> list[dict[str, Any]]:
	"""Fetch one page of the employee directory for `employee_list`.

	Joined with `Employee Overall Stats` so avg hours/day and avg login time
	are read from the precomputed table, never computed from raw logs here -
	see docs/04_BACKEND_RULES.md §7 (applies with extra force to this function,
	since it can render a full page of rows per request).

	Args:
	    q: name/ID search fragment; empty string means browse-all.
	    manager: optional manager `employee_id` filter.
	    sort: optional sort spec - `"hours"` sorts by avg hours/day descending;
	        anything else (including None) sorts by name ascending.
	    start: zero-based row offset.
	    limit: max rows to return; caller has already capped this at PAGE_SIZE_MAX.

	Returns:
	    A list of compact employee-row dicts: `employee_id`, `employee_name`,
	    `manager`, `manager_name`, `avg_hours_overall`, `avg_login_time_overall`.
	"""
	employee = DocType("Employee")
	manager_employee = DocType("Employee", alias="manager_employee")
	overall_stats = DocType("Employee Overall Stats")

	query = (
		frappe.qb.from_(employee)
		.left_join(overall_stats)
		.on(overall_stats.employee == employee.employee_id)
		.left_join(manager_employee)
		.on(manager_employee.employee_id == employee.manager)
		.select(
			employee.employee_id,
			employee.employee_name,
			employee.manager,
			manager_employee.employee_name.as_("manager_name"),
			overall_stats.avg_hours_overall,
			overall_stats.avg_login_time_overall,
		)
	)

	if q:
		query = query.where(_name_or_id_condition(employee, q))
	if manager:
		query = query.where(employee.manager == manager)

	if sort == "hours":
		query = query.orderby(overall_stats.avg_hours_overall, order=Order.desc)
	else:
		query = query.orderby(employee.employee_name, order=Order.asc)

	query = paginate(query, start, limit)
	return query.run(as_dict=True)


def count_employees(q: str, manager: str | None) -> int:
	"""Count `Employee` rows matching the same filter as `list_employees`.

	Used to derive `has_more` for the paginated response envelope.

	Args:
	    q: name/ID search fragment; empty string means browse-all.
	    manager: optional manager `employee_id` filter.

	Returns:
	    Total matching row count.
	"""
	employee = DocType("Employee")
	query = frappe.qb.from_(employee).select(Count("*").as_("total"))

	if q:
		query = query.where(_name_or_id_condition(employee, q))
	if manager:
		query = query.where(employee.manager == manager)

	result = query.run(as_dict=True)
	return result[0]["total"] if result else 0


def get_employee_by_id(employee_id: str) -> dict[str, Any] | None:
	"""Fetch one `Employee` row by its `employee_id`.

	Args:
	    employee_id: the `Employee.employee_id` value.

	Returns:
	    The employee record as a dict, or None if not found.
	"""
	rows = frappe.get_all(
		"Employee",
		filters={"employee_id": employee_id},
		fields=["employee_id", "employee_name", "manager", "date_of_joining", "user"],
		limit=1,
	)
	return rows[0] if rows else None


def get_manager_chain(employee_id: str) -> list[dict[str, Any]]:
	"""Walk the self-referential `manager` link up to the top of the chain.

	Args:
	    employee_id: the `Employee.employee_id` value to start from.

	Returns:
	    Ordered list of manager records (`employee_id`, `employee_name`),
	    immediate manager first.
	"""
	chain: list[dict[str, Any]] = []
	current_manager_id = frappe.db.get_value("Employee", employee_id, "manager")

	while current_manager_id:
		manager_rows = frappe.get_all(
			"Employee",
			filters={"employee_id": current_manager_id},
			fields=["employee_id", "employee_name", "manager"],
			limit=1,
		)
		if not manager_rows:
			break
		manager_row = manager_rows[0]
		chain.append({"employee_id": manager_row.employee_id, "employee_name": manager_row.employee_name})
		current_manager_id = manager_row.manager

	return chain


def get_direct_reports(employee_id: str) -> list[dict[str, Any]]:
	"""Fetch employees whose `manager` points at `employee_id`.

	Args:
	    employee_id: the `Employee.employee_id` value of the manager.

	Returns:
	    A list of direct-report employee records (`employee_id`, `employee_name`).
	"""
	return frappe.get_all(
		"Employee",
		filters={"manager": employee_id},
		fields=["employee_id", "employee_name"],
	)
