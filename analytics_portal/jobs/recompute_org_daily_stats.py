"""Nightly job: refresh `Org Daily Stats` for the prior day.

Scheduled via `scheduler_events["cron"]` in hooks.py. The scheduler calls
`enqueue_recompute_org_daily_stats`, which pushes the actual work onto the
dedicated "long" queue per docs/04_BACKEND_RULES.md §8.
"""

import frappe


def enqueue_recompute_org_daily_stats() -> None:
	"""Entry point wired into hooks.py; enqueues the real job on the "long" queue."""
	frappe.enqueue(
		"analytics_portal.jobs.recompute_org_daily_stats.recompute_org_daily_stats",
		queue="long",
	)


def recompute_org_daily_stats() -> None:
	"""Refresh the prior day's `Org Daily Stats` row.

	Writes via `stats_repo.upsert_org_daily_stats`. Must log start, row-count
	processed, duration, and outcome — no silent runs.
	"""
	raise NotImplementedError
