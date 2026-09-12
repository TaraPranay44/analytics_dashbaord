"""Nightly job: refresh `Employee Overall Stats` from `Employee Monthly Stats`.

Scheduled via `scheduler_events["cron"]` in hooks.py, after the monthly-stats
job. The scheduler calls `enqueue_recompute_overall_stats`, which pushes the
actual work onto the dedicated "long" queue per docs/04_BACKEND_RULES.md §8.
"""

import frappe


def enqueue_recompute_overall_stats() -> None:
	"""Entry point wired into hooks.py; enqueues the real job on the "long" queue."""
	frappe.enqueue(
		"analytics_portal.jobs.recompute_overall_stats.recompute_overall_stats",
		queue="long",
	)


def recompute_overall_stats() -> None:
	"""Refresh each employee's `Employee Overall Stats` row.

	Reads from `Employee Monthly Stats` — never from raw activity logs — via
	`stats_repo.upsert_employee_overall_stats`. Must log start, row-count
	processed, duration, and outcome — no silent runs.
	"""
	raise NotImplementedError
