"""All DB access for the precomputed aggregate DocTypes:
`Employee Monthly Stats`, `Employee Overall Stats`, `Org Daily Stats`.

Anything "average" is read from these tables, never computed by scanning
`Employee Activity Log` at request time - see docs/04_BACKEND_RULES.md §7.
The write-side functions here are used only by the nightly jobs in `jobs/`.
"""

from datetime import date, time
from typing import Any

import frappe
from frappe.utils import now_datetime


def get_employee_monthly_stats(employee_id: str, year_month: str) -> dict[str, Any] | None:
	"""Fetch one `Employee Monthly Stats` row.

	Args:
	    employee_id: the `Employee.employee_id` value.
	    year_month: month in `YYYY-MM` format.

	Returns:
	    The stats row as a dict, or None if not yet computed.
	"""
	rows = frappe.get_all(
		"Employee Monthly Stats",
		filters={"employee": employee_id, "year_month": year_month},
		fields=[
			"name",
			"employee",
			"year_month",
			"avg_hours",
			"avg_login_time",
			"avg_logout_time",
			"days_present",
		],
		limit=1,
	)
	return rows[0] if rows else None


def get_all_employee_monthly_stats(employee_id: str) -> list[dict[str, Any]]:
	"""Fetch every `Employee Monthly Stats` row for one employee (all months).

	Used by `jobs/recompute_overall_stats.py` to fold monthly rows into the
	employee's lifetime aggregate - never reads raw activity logs.

	Args:
	    employee_id: the `Employee.employee_id` value.

	Returns:
	    A list of monthly stats row dicts, one per month with data.
	"""
	return frappe.get_all(
		"Employee Monthly Stats",
		filters={"employee": employee_id},
		fields=["year_month", "avg_hours", "avg_login_time", "avg_logout_time", "days_present"],
		order_by="year_month asc",
	)


def get_employees_with_monthly_stats() -> list[str]:
	"""Return distinct employee IDs that have at least one `Employee Monthly Stats` row.

	Used by `jobs/recompute_overall_stats.py` to know which employees need
	their `Employee Overall Stats` row refreshed.

	Returns:
	    A list of distinct `Employee.employee_id` values.
	"""
	rows = frappe.get_all("Employee Monthly Stats", fields=["employee"], distinct=True)
	return [row.employee for row in rows]


def get_employee_overall_stats(employee_id: str) -> dict[str, Any] | None:
	"""Fetch the `Employee Overall Stats` row for an employee.

	Args:
	    employee_id: the `Employee.employee_id` value.

	Returns:
	    The stats row as a dict, or None if not yet computed.
	"""
	rows = frappe.get_all(
		"Employee Overall Stats",
		filters={"employee": employee_id},
		fields=[
			"name",
			"employee",
			"avg_hours_overall",
			"avg_login_time_overall",
			"avg_logout_time_overall",
			"last_computed",
		],
		limit=1,
	)
	return rows[0] if rows else None


def get_org_daily_stats(target_date: date) -> dict[str, Any] | None:
	"""Fetch the `Org Daily Stats` row for one day.

	Args:
	    target_date: the day to fetch stats for.

	Returns:
	    The stats row as a dict, or None if not yet computed.
	"""
	rows = frappe.get_all(
		"Org Daily Stats",
		filters={"date": target_date},
		fields=["name", "date", "total_employees", "avg_hours_org", "avg_login_time_org"],
		limit=1,
	)
	return rows[0] if rows else None


def get_latest_org_daily_stats() -> dict[str, Any] | None:
	"""Fetch the most recent `Org Daily Stats` row, for the landing dashboard tiles.

	Args:
	    None.

	Returns:
	    The most recent stats row as a dict, or None if none have been computed yet.
	"""
	rows = frappe.get_all(
		"Org Daily Stats",
		fields=["name", "date", "total_employees", "avg_hours_org", "avg_login_time_org"],
		order_by="date desc",
		limit=1,
	)
	return rows[0] if rows else None


def count_employees_below_hours(threshold: float) -> int:
	"""Count `Employee Overall Stats` rows with `avg_hours_overall` below `threshold`.

	Args:
	    threshold: the avg-hours cutoff (exclusive).

	Returns:
	    Matching row count.
	"""
	return frappe.db.count("Employee Overall Stats", filters={"avg_hours_overall": ["<", threshold]})


def get_recent_org_daily_stats(days: int) -> list[dict[str, Any]]:
	"""Fetch the last `days` `Org Daily Stats` rows, for the dashboard sparkline/trend.

	Args:
	    days: how many most-recent days to fetch.

	Returns:
	    A list of stats row dicts, ordered by `date` ascending (oldest first).
	"""
	rows = frappe.get_all(
		"Org Daily Stats",
		fields=["date", "total_employees", "avg_hours_org", "avg_login_time_org"],
		order_by="date desc",
		limit=days,
	)
	return list(reversed(rows))


def upsert_employee_monthly_stats(
	employee_id: str,
	year_month: str,
	avg_hours: float,
	avg_login_time: time,
	avg_logout_time: time,
	days_present: int,
) -> None:
	"""Create or update the `Employee Monthly Stats` row for one employee/month.

	Called only from `jobs/recompute_monthly_stats.py`.

	Args:
	    employee_id: the `Employee.employee_id` value.
	    year_month: month in `YYYY-MM` format.
	    avg_hours: recomputed average hours for the month.
	    avg_login_time: recomputed average login time for the month.
	    avg_logout_time: recomputed average logout time for the month.
	    days_present: number of days with a logged activity row this month.
	"""
	existing_name = frappe.db.get_value(
		"Employee Monthly Stats", {"employee": employee_id, "year_month": year_month}, "name"
	)

	if existing_name:
		doc = frappe.get_doc("Employee Monthly Stats", existing_name)
	else:
		doc = frappe.new_doc("Employee Monthly Stats")
		doc.employee = employee_id
		doc.year_month = year_month

	doc.avg_hours = avg_hours
	doc.avg_login_time = avg_login_time
	doc.avg_logout_time = avg_logout_time
	doc.days_present = days_present

	if existing_name:
		doc.save(ignore_permissions=True)
	else:
		doc.insert(ignore_permissions=True)


def upsert_employee_overall_stats(
	employee_id: str,
	avg_hours_overall: float,
	avg_login_time_overall: time,
	avg_logout_time_overall: time,
) -> None:
	"""Create or update the `Employee Overall Stats` row for one employee.

	Called only from `jobs/recompute_overall_stats.py`, reading from
	`Employee Monthly Stats` - never from raw activity logs.

	Args:
	    employee_id: the `Employee.employee_id` value.
	    avg_hours_overall: recomputed all-time average hours.
	    avg_login_time_overall: recomputed all-time average login time.
	    avg_logout_time_overall: recomputed all-time average logout time.
	"""
	existing_name = frappe.db.get_value("Employee Overall Stats", {"employee": employee_id}, "name")

	if existing_name:
		doc = frappe.get_doc("Employee Overall Stats", existing_name)
	else:
		doc = frappe.new_doc("Employee Overall Stats")
		doc.employee = employee_id

	doc.avg_hours_overall = avg_hours_overall
	doc.avg_login_time_overall = avg_login_time_overall
	doc.avg_logout_time_overall = avg_logout_time_overall
	doc.last_computed = now_datetime()

	if existing_name:
		doc.save(ignore_permissions=True)
	else:
		doc.insert(ignore_permissions=True)


def upsert_org_daily_stats(
	target_date: date,
	total_employees: int,
	avg_hours_org: float,
	avg_login_time_org: time,
) -> None:
	"""Create or update the `Org Daily Stats` row for one day.

	Called only from `jobs/recompute_org_daily_stats.py`.

	Args:
	    target_date: the day these stats are for.
	    total_employees: headcount with activity on this day.
	    avg_hours_org: org-wide average hours for this day.
	    avg_login_time_org: org-wide average login time for this day.
	"""
	existing_name = frappe.db.get_value("Org Daily Stats", {"date": target_date}, "name")

	if existing_name:
		doc = frappe.get_doc("Org Daily Stats", existing_name)
	else:
		doc = frappe.new_doc("Org Daily Stats")
		doc.date = target_date

	doc.total_employees = total_employees
	doc.avg_hours_org = avg_hours_org
	doc.avg_login_time_org = avg_login_time_org

	if existing_name:
		doc.save(ignore_permissions=True)
	else:
		doc.insert(ignore_permissions=True)
