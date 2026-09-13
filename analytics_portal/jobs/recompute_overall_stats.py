"""Nightly job: refresh `Employee Overall Stats` from `Employee Monthly Stats`.

Scheduled via `scheduler_events["cron"]` in hooks.py, after the monthly-stats
job. The scheduler calls `enqueue_recompute_overall_stats`, which pushes the
actual work onto the dedicated "long" queue per docs/04_BACKEND_RULES.md §8.
"""

import time as time_module
from datetime import time

import frappe

from analytics_portal.repositories import stats_repo
from analytics_portal.utils.time_avg import weighted_average, weighted_average_time_of_day

logger = frappe.logger("analytics_portal.jobs")


def enqueue_recompute_overall_stats() -> None:
	"""Entry point wired into hooks.py; enqueues the real job on the "long" queue."""
	frappe.enqueue(
		"analytics_portal.jobs.recompute_overall_stats.recompute_overall_stats",
		queue="long",
	)


def recompute_overall_stats() -> None:
	"""Refresh each employee's `Employee Overall Stats` row.

	Reads from `Employee Monthly Stats` - never from raw activity logs - via
	`stats_repo.upsert_employee_overall_stats`. Must log start, row-count
	processed, duration, and outcome - no silent runs.
	"""
	started_at = time_module.monotonic()
	logger.info("recompute_overall_stats: start")

	employee_ids = sorted(stats_repo.get_employees_with_monthly_stats())
	processed = 0
	failed = 0

	for employee_id in employee_ids:
		try:
			_recompute_employee_overall(employee_id)
			processed += 1
		except Exception:
			failed += 1
			logger.error(f"recompute_overall_stats: failed employee={employee_id}", exc_info=True)

	duration_seconds = time_module.monotonic() - started_at
	outcome = "success" if failed == 0 else "partial_failure"
	logger.info(
		f"recompute_overall_stats: done outcome={outcome} employees_found={len(employee_ids)} "
		f"processed={processed} failed={failed} duration_seconds={duration_seconds:.2f}"
	)


def _recompute_employee_overall(employee_id: str) -> None:
	"""Recompute one employee's `Employee Overall Stats` row from all their monthly rows.

	Each month is weighted by `days_present` so a sparsely-attended month does
	not skew the lifetime average as much as a fuller one.

	Args:
	    employee_id: the `Employee.employee_id` value.
	"""
	monthly_rows = stats_repo.get_all_employee_monthly_stats(employee_id)

	avg_hours_overall = round(
		weighted_average((row.avg_hours or 0.0, row.days_present or 0) for row in monthly_rows), 2
	)
	avg_login_time_overall = weighted_average_time_of_day(
		(row.avg_login_time, row.days_present or 0) for row in monthly_rows if row.avg_login_time is not None
	)
	avg_logout_time_overall = weighted_average_time_of_day(
		(row.avg_logout_time, row.days_present or 0)
		for row in monthly_rows
		if row.avg_logout_time is not None
	)

	stats_repo.upsert_employee_overall_stats(
		employee_id=employee_id,
		avg_hours_overall=avg_hours_overall,
		avg_login_time_overall=avg_login_time_overall or time(0, 0, 0),
		avg_logout_time_overall=avg_logout_time_overall or time(0, 0, 0),
	)
