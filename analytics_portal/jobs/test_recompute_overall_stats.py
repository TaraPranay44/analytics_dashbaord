# Copyright (c) 2026, EMPLOYEE ANALYTICS PORTAL and Contributors
# See license.txt

from datetime import time
from unittest.mock import patch

import frappe
from frappe.tests import IntegrationTestCase

from analytics_portal.constants.cache_keys import employee_detail_key
from analytics_portal.jobs.recompute_overall_stats import (
	_recompute_employee_overall,
	enqueue_recompute_overall_stats,
)
from analytics_portal.repositories import stats_repo


class TestRecomputeOverallStats(IntegrationTestCase):
	"""Tests for docs/04_BACKEND_RULES.md §7/§8 - `recompute_overall_stats`.

	Seeds `Employee Monthly Stats` rows directly (this job must never read raw
	activity logs) - each test uses its own employee to avoid cross-test data
	leakage, since `IntegrationTestCase` only rolls back at class teardown.

	Exercises `_recompute_employee_overall` directly rather than the full
	`recompute_overall_stats()` entry point, for the same reason as
	`test_recompute_monthly_stats.py`: the full job has no per-employee scope
	and this dev database has a large, separately-running seed job committing
	real `Employee Monthly Stats` rows concurrently.
	"""

	def _make_employee(self) -> str:
		employee_id = f"TEST-OSTATS-{frappe.generate_hash(length=8)}"
		frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": "Overall Stats Test Employee",
				"employee_id": employee_id,
			}
		).insert()
		return employee_id

	def _make_monthly_stats(
		self, employee_id: str, year_month: str, avg_hours: float, days_present: int
	) -> None:
		frappe.get_doc(
			{
				"doctype": "Employee Monthly Stats",
				"employee": employee_id,
				"year_month": year_month,
				"avg_hours": avg_hours,
				"avg_login_time": time(9, 0, 0),
				"avg_logout_time": time(17, 0, 0),
				"days_present": days_present,
			}
		).insert()

	def test_overall_stats_weighted_by_days_present(self) -> None:
		employee_id = self._make_employee()
		self._make_monthly_stats(employee_id, "2026-01", avg_hours=10.0, days_present=1)
		self._make_monthly_stats(employee_id, "2026-02", avg_hours=6.0, days_present=19)

		_recompute_employee_overall(employee_id)

		stats = stats_repo.get_employee_overall_stats(employee_id)
		self.assertIsNotNone(stats)
		# (10*1 + 6*19) / 20 = 6.2
		self.assertAlmostEqual(stats.avg_hours_overall, 6.2, places=1)
		self.assertIsNotNone(stats.last_computed)

	def test_overall_stats_is_safe_to_rerun(self) -> None:
		employee_id = self._make_employee()
		self._make_monthly_stats(employee_id, "2026-03", avg_hours=8.0, days_present=5)

		_recompute_employee_overall(employee_id)
		_recompute_employee_overall(employee_id)

		overall_rows = frappe.get_all("Employee Overall Stats", filters={"employee": employee_id})
		self.assertEqual(len(overall_rows), 1)

	def test_overall_stats_picks_up_a_newly_added_month(self) -> None:
		employee_id = self._make_employee()
		self._make_monthly_stats(employee_id, "2026-04", avg_hours=8.0, days_present=10)
		_recompute_employee_overall(employee_id)

		self._make_monthly_stats(employee_id, "2026-05", avg_hours=4.0, days_present=10)
		_recompute_employee_overall(employee_id)

		stats = stats_repo.get_employee_overall_stats(employee_id)
		self.assertAlmostEqual(stats.avg_hours_overall, 6.0, places=1)

	def test_recompute_clears_the_stale_employee_detail_cache(self) -> None:
		employee_id = self._make_employee()
		self._make_monthly_stats(employee_id, "2026-06", avg_hours=5.0, days_present=5)

		cache_key = employee_detail_key(employee_id)
		frappe.cache().set_value(cache_key, {"stale": "data"})

		_recompute_employee_overall(employee_id)

		self.assertIsNone(frappe.cache().get_value(cache_key))

	def test_enqueue_pushes_the_real_job_onto_the_long_queue(self) -> None:
		with patch("frappe.enqueue") as mock_enqueue:
			enqueue_recompute_overall_stats()

		mock_enqueue.assert_called_once_with(
			"analytics_portal.jobs.recompute_overall_stats.recompute_overall_stats",
			queue="long",
		)
