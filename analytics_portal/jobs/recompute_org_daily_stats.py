"""Nightly job: refresh `Org Daily Stats` for the prior day.

Scheduled via `scheduler_events["cron"]` in hooks.py. The scheduler calls
`enqueue_recompute_org_daily_stats`, which pushes the actual work onto the
dedicated "long" queue per docs/04_BACKEND_RULES.md §8.
"""

import time as time_module
from datetime import date, time

import frappe
from frappe.utils import add_days, get_datetime, getdate, nowdate

from analytics_portal.constants.cache_keys import org_dashboard_key
from analytics_portal.repositories import activity_log_repo, stats_repo
from analytics_portal.utils.time_avg import average_time_of_day

logger = frappe.logger("analytics_portal.jobs")


def enqueue_recompute_org_daily_stats() -> None:
	"""Entry point wired into hooks.py; enqueues the real job on the "long" queue."""
	frappe.enqueue(
		"analytics_portal.jobs.recompute_org_daily_stats.recompute_org_daily_stats",
		queue="long",
	)


def recompute_org_daily_stats() -> None:
	"""Refresh the prior day's `Org Daily Stats` row.

	Writes via `stats_repo.upsert_org_daily_stats`. Must log start, row-count
	processed, duration, and outcome - no silent runs.
	"""
	target_date = getdate(add_days(nowdate(), -1))
	_recompute_org_daily_stats_for_date(target_date)


def _recompute_org_daily_stats_for_date(target_date: date) -> None:
	"""Refresh the `Org Daily Stats` row for one specific date.

	Split out from `recompute_org_daily_stats` so tests can target a date that
	can't collide with real seeded/production data, while the scheduled entry
	point always targets "yesterday".

	Args:
	    target_date: the date to (re)compute the `Org Daily Stats` row for.
	"""
	started_at = time_module.monotonic()
	logger.info(f"recompute_org_daily_stats: start target_date={target_date}")

	try:
		rows = activity_log_repo.get_activity_log_rows_for_date(target_date)
		distinct_employees = {row.employee for row in rows}
		total_employees = len(distinct_employees)
		avg_hours_org = round(sum(row.total_hours or 0.0 for row in rows) / len(rows), 2) if rows else 0.0
		avg_login_time_org = average_time_of_day(
			get_datetime(row.login_time).time() for row in rows if row.login_time
		)

		stats_repo.upsert_org_daily_stats(
			target_date=target_date,
			total_employees=total_employees,
			avg_hours_org=avg_hours_org,
			avg_login_time_org=avg_login_time_org or time(0, 0, 0),
		)
		# org_dashboard always reads the most-recent row and is cached with no
		# TTL (docs/04_BACKEND_RULES.md §6) - this is the one place that ever
		# invalidates it.
		frappe.cache().delete_value(org_dashboard_key())
	except Exception:
		duration_seconds = time_module.monotonic() - started_at
		logger.error(
			f"recompute_org_daily_stats: failed target_date={target_date} "
			f"duration_seconds={duration_seconds:.2f}",
			exc_info=True,
		)
		raise

	duration_seconds = time_module.monotonic() - started_at
	logger.info(
		f"recompute_org_daily_stats: done outcome=success target_date={target_date} "
		f"rows_processed={len(rows)} total_employees={total_employees} "
		f"duration_seconds={duration_seconds:.2f}"
	)
