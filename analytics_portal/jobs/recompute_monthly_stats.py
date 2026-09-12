"""Nightly job: recompute each employee's current-month row in `Employee Monthly Stats`.

Scheduled via `scheduler_events["cron"]` in hooks.py at ~01:00. The scheduler
calls `enqueue_recompute_monthly_stats`, which pushes the actual work onto the
dedicated "long" queue per docs/04_BACKEND_RULES.md §8 — never the default queue.
"""

import frappe


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
	Must log start, row-count processed, duration, and outcome — no silent runs.
	"""
	raise NotImplementedError
