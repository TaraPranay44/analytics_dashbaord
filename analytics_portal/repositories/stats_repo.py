"""All DB access for the precomputed aggregate DocTypes:
`Employee Monthly Stats`, `Employee Overall Stats`, `Org Daily Stats`.

Anything "average" is read from these tables, never computed by scanning
`Employee Activity Log` at request time — see docs/04_BACKEND_RULES.md §7.
The write-side functions here are used only by the nightly jobs in `jobs/`.
"""

from datetime import date, time
from typing import Any


def get_employee_monthly_stats(employee_id: str, year_month: str) -> dict[str, Any] | None:
	"""Fetch one `Employee Monthly Stats` row.

	Args:
	    employee_id: the `Employee.employee_id` value.
	    year_month: month in `YYYY-MM` format.

	Returns:
	    The stats row as a dict, or None if not yet computed.
	"""
	raise NotImplementedError


def get_employee_overall_stats(employee_id: str) -> dict[str, Any] | None:
	"""Fetch the `Employee Overall Stats` row for an employee.

	Args:
	    employee_id: the `Employee.employee_id` value.

	Returns:
	    The stats row as a dict, or None if not yet computed.
	"""
	raise NotImplementedError


def get_org_daily_stats(target_date: date) -> dict[str, Any] | None:
	"""Fetch the `Org Daily Stats` row for one day.

	Args:
	    target_date: the day to fetch stats for.

	Returns:
	    The stats row as a dict, or None if not yet computed.
	"""
	raise NotImplementedError


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
	raise NotImplementedError


def upsert_employee_overall_stats(
	employee_id: str,
	avg_hours_overall: float,
	avg_login_time_overall: time,
	avg_logout_time_overall: time,
) -> None:
	"""Create or update the `Employee Overall Stats` row for one employee.

	Called only from `jobs/recompute_overall_stats.py`, reading from
	`Employee Monthly Stats` — never from raw activity logs.

	Args:
	    employee_id: the `Employee.employee_id` value.
	    avg_hours_overall: recomputed all-time average hours.
	    avg_login_time_overall: recomputed all-time average login time.
	    avg_logout_time_overall: recomputed all-time average logout time.
	"""
	raise NotImplementedError


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
	raise NotImplementedError
