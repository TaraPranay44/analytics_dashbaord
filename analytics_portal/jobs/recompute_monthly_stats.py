"""Nightly job: recompute each employee's current-month row in `Employee Monthly Stats`.

Scheduled via `scheduler_events["cron"]` in hooks.py at ~01:00. The scheduler
calls `enqueue_recompute_monthly_stats`, which pushes the actual work onto the
dedicated "long" queue per docs/04_BACKEND_RULES.md §8 - never the default queue.
"""

import calendar
import time as time_module
from datetime import date, time

import frappe
from frappe.utils import add_days, get_datetime, getdate, nowdate

from analytics_portal.repositories import activity_log_repo, stats_repo
from analytics_portal.utils.time_avg import average_time_of_day

logger = frappe.logger("analytics_portal.jobs")


def enqueue_recompute_monthly_stats() -> None:
	"""Entry point wired into hooks.py; enqueues the real job on the "long" queue."""
	frappe.enqueue(
		"analytics_portal.jobs.recompute_monthly_stats.recompute_monthly_stats",
		queue="long",
	)


def recompute_monthly_stats() -> None:
	"""Recompute the current month's `Employee Monthly Stats` row per employee.

	Reads the prior day's `Employee Activity Log` rows, folds them into the
	running monthly aggregate via `stats_repo.upsert_employee_monthly_stats`.
	Must log start, row-count processed, duration, and outcome - no silent runs.
	"""
	started_at = time_module.monotonic()
	target_date = getdate(add_days(nowdate(), -1))
	year_month = target_date.strftime("%Y-%m")
	logger.info(f"recompute_monthly_stats: start target_date={target_date} year_month={year_month}")

	employee_ids = sorted(activity_log_repo.get_employees_with_activity_on(target_date))
	processed = 0
	failed = 0

	for employee_id in employee_ids:
		try:
			_recompute_employee_month(employee_id, year_month)
			processed += 1
		except Exception:
			failed += 1
			logger.error(
				f"recompute_monthly_stats: failed employee={employee_id} year_month={year_month}",
				exc_info=True,
			)

	duration_seconds = time_module.monotonic() - started_at
	outcome = "success" if failed == 0 else "partial_failure"
	logger.info(
		f"recompute_monthly_stats: done outcome={outcome} employees_found={len(employee_ids)} "
		f"processed={processed} failed={failed} duration_seconds={duration_seconds:.2f}"
	)


def _recompute_employee_month(employee_id: str, year_month: str) -> None:
	"""Recompute one employee's `Employee Monthly Stats` row for `year_month`.

	Re-derives the whole month from `Employee Activity Log` (bounded by the
	`(employee, date)` index to at most ~31 rows) rather than incrementally
	blending in just the prior day - simpler, and safe to re-run for the same
	day without double-counting.

	Args:
	    employee_id: the `Employee.employee_id` value.
	    year_month: month in `YYYY-MM` format.
	"""
	year, month = (int(part) for part in year_month.split("-"))
	month_start = date(year, month, 1)
	month_end = date(year, month, calendar.monthrange(year, month)[1])

	rows = activity_log_repo.get_activity_log_rows_for_month(employee_id, month_start, month_end)
	days_present = len(rows)
	avg_hours = round(sum(row.total_hours or 0.0 for row in rows) / days_present, 2) if days_present else 0.0
	avg_login_time = average_time_of_day(
		get_datetime(row.login_time).time() for row in rows if row.login_time
	)
	avg_logout_time = average_time_of_day(
		get_datetime(row.logout_time).time() for row in rows if row.logout_time
	)

	stats_repo.upsert_employee_monthly_stats(
		employee_id=employee_id,
		year_month=year_month,
		avg_hours=avg_hours,
		avg_login_time=avg_login_time or time(0, 0, 0),
		avg_logout_time=avg_logout_time or time(0, 0, 0),
		days_present=days_present,
	)
