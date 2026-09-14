"""All DB access for the `Employee Activity Log` DocType.

This is the 11M+ row table - every query here must be paginated and must use
the `(employee, date)` composite index. See docs/04_BACKEND_RULES.md §7.
"""

from datetime import date
from typing import Any

import frappe


def _apply_date_filters(
	filters: dict[str, Any], from_date: date | None, to_date: date | None
) -> dict[str, Any]:
	"""Add a `date` range filter to `filters` if either bound is given."""
	if from_date and to_date:
		filters["date"] = ["between", [from_date, to_date]]
	elif from_date:
		filters["date"] = [">=", from_date]
	elif to_date:
		filters["date"] = ["<=", to_date]
	return filters


def get_employee_logs_page(
	employee_id: str,
	from_date: date | None,
	to_date: date | None,
	start: int,
	limit: int,
) -> list[dict[str, Any]]:
	"""Fetch one page of `Employee Activity Log` rows for an employee.

	Args:
	    employee_id: the `Employee.employee_id` value.
	    from_date: inclusive lower bound on `date`, or None for no lower bound.
	    to_date: inclusive upper bound on `date`, or None for no upper bound.
	    start: zero-based row offset.
	    limit: max rows to return; caller has already capped this at PAGE_SIZE_MAX.

	Returns:
	    A list of activity log row dicts, ordered by `date` descending.
	"""
	filters = _apply_date_filters({"employee": employee_id}, from_date, to_date)
	return frappe.get_all(
		"Employee Activity Log",
		filters=filters,
		fields=["employee", "date", "login_time", "logout_time", "total_hours"],
		order_by="date desc",
		offset=start,
		limit=limit,
	)


def count_employee_logs(
	employee_id: str,
	from_date: date | None,
	to_date: date | None,
) -> int:
	"""Count `Employee Activity Log` rows matching the same filter as the page query.

	Used to derive `has_more` for the paginated response envelope.

	Args:
	    employee_id: the `Employee.employee_id` value.
	    from_date: inclusive lower bound on `date`, or None for no lower bound.
	    to_date: inclusive upper bound on `date`, or None for no upper bound.

	Returns:
	    Total matching row count.
	"""
	filters = _apply_date_filters({"employee": employee_id}, from_date, to_date)
	return frappe.db.count("Employee Activity Log", filters=filters)


def get_employees_with_activity_on(target_date: date) -> list[str]:
	"""Return distinct employee IDs with an `Employee Activity Log` row on `target_date`.

	Used by `jobs/recompute_monthly_stats.py` to know which employees' current-
	month row needs refreshing after a given day's logs land - an indexed
	lookup on `date`, not a scan of the full 11M+ row table.

	Args:
	    target_date: the date to check for activity.

	Returns:
	    A list of distinct `Employee.employee_id` values.
	"""
	rows = frappe.get_all(
		"Employee Activity Log", filters={"date": target_date}, fields=["employee"], distinct=True
	)
	return [row.employee for row in rows]


def get_activity_log_rows_for_month(
	employee_id: str, month_start: date, month_end: date
) -> list[dict[str, Any]]:
	"""Fetch one employee's `Employee Activity Log` rows within an inclusive date range.

	Bounded by the `(employee, date)` composite index - a range scan over at
	most one month's rows for a single employee, never a table scan.

	Args:
	    employee_id: the `Employee.employee_id` value.
	    month_start: inclusive lower bound on `date`.
	    month_end: inclusive upper bound on `date`.

	Returns:
	    A list of dicts with `login_time`, `logout_time`, `total_hours`.
	"""
	return frappe.get_all(
		"Employee Activity Log",
		filters={"employee": employee_id, "date": ["between", [month_start, month_end]]},
		fields=["login_time", "logout_time", "total_hours"],
	)


def get_recent_daily_hours(employee_id: str, days: int) -> list[dict[str, Any]]:
	"""Fetch one employee's last `days` days of `total_hours`, for the detail-page trend chart.

	Bounded by the `(employee, date)` composite index. This is raw, recent,
	small (`days`-row) data for a chart - not an "average" figure, so it is
	not subject to the aggregate-table-only rule in docs/04_BACKEND_RULES.md §7.

	Args:
	    employee_id: the `Employee.employee_id` value.
	    days: how many most-recent days to fetch.

	Returns:
	    A list of `{"date": ..., "total_hours": ...}` dicts, ordered by `date`
	    ascending (oldest first, chart-ready).
	"""
	rows = frappe.get_all(
		"Employee Activity Log",
		filters={"employee": employee_id},
		fields=["date", "total_hours"],
		order_by="date desc",
		limit=days,
	)
	return list(reversed(rows))


def get_activity_log_rows_for_date(target_date: date) -> list[dict[str, Any]]:
	"""Fetch every `Employee Activity Log` row for one date, across all employees.

	Used by `jobs/recompute_org_daily_stats.py` - one date's rows are a bounded,
	indexed slice (via the `date` index), not a scan of the full table.

	Args:
	    target_date: the date to fetch rows for.

	Returns:
	    A list of dicts with `employee`, `login_time`, `logout_time`, `total_hours`.
	"""
	return frappe.get_all(
		"Employee Activity Log",
		filters={"date": target_date},
		fields=["employee", "login_time", "logout_time", "total_hours"],
	)
