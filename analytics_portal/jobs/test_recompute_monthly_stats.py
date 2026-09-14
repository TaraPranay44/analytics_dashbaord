# Copyright (c) 2026, EMPLOYEE ANALYTICS PORTAL and Contributors
# See license.txt

from datetime import date, datetime, timedelta
from unittest.mock import patch

import frappe
from frappe.tests import IntegrationTestCase

from analytics_portal.jobs.recompute_monthly_stats import (
	_recompute_employee_month,
	enqueue_recompute_monthly_stats,
)
from analytics_portal.repositories import stats_repo


class TestRecomputeMonthlyStats(IntegrationTestCase):
	"""Tests for docs/04_BACKEND_RULES.md §7/§8 - `recompute_monthly_stats`.

	Each test creates its own `Employee` fixture (rather than a shared
	`setUpClass` one) because `IntegrationTestCase` only rolls the DB back at
	class teardown, and `_recompute_employee_month` aggregates *all* of an
	employee's activity log rows in a month - reusing one employee across test
	methods would let an earlier test's rows leak into a later test's average.

	These tests exercise `_recompute_employee_month` directly (scoped to one
	employee) rather than the full `recompute_monthly_stats()` entry point:
	this bench's dev database has a separate, very large (30,000-employee)
	seed-data job running/committed concurrently, and the full job has no
	per-employee scope - it processes every employee active on a given date,
	which in this shared database would mean asserting against an unbounded
	and constantly-changing set of real rows. `_recompute_employee_month` is
	exactly the unit the full job loops over, so this still tests the real
	aggregation logic without depending on how much of the concurrent seed
	data happens to be committed when the test runs.
	"""

	def _make_employee(self) -> str:
		employee_id = f"TEST-MSTATS-{frappe.generate_hash(length=8)}"
		frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": "Monthly Stats Test Employee",
				"employee_id": employee_id,
			}
		).insert()
		return employee_id

	def _make_log(self, employee_id: str, day: date, login_hour: int, hours_worked: float) -> None:
		login = datetime(day.year, day.month, day.day, login_hour, 0, 0)
		logout = login + timedelta(hours=hours_worked)
		frappe.get_doc(
			{
				"doctype": "Employee Activity Log",
				"employee": employee_id,
				"date": day,
				"login_time": login,
				"logout_time": logout,
			}
		).insert()

	def test_recompute_folds_the_months_logs_into_one_row(self) -> None:
		employee_id = self._make_employee()
		self._make_log(employee_id, date(2026, 3, 1), login_hour=9, hours_worked=8)
		self._make_log(employee_id, date(2026, 3, 2), login_hour=10, hours_worked=6)

		_recompute_employee_month(employee_id, "2026-03")

		stats = stats_repo.get_employee_monthly_stats(employee_id, "2026-03")
		self.assertIsNotNone(stats)
		self.assertEqual(stats.days_present, 2)
		self.assertAlmostEqual(stats.avg_hours, 7.0, places=1)

	def test_recompute_is_safe_to_rerun_for_the_same_month(self) -> None:
		employee_id = self._make_employee()
		self._make_log(employee_id, date(2026, 4, 5), login_hour=9, hours_worked=8)

		_recompute_employee_month(employee_id, "2026-04")
		_recompute_employee_month(employee_id, "2026-04")

		stats = stats_repo.get_employee_monthly_stats(employee_id, "2026-04")
		self.assertEqual(stats.days_present, 1)
		self.assertAlmostEqual(stats.avg_hours, 8.0, places=1)

	def test_recompute_updates_existing_row_when_a_new_day_is_added(self) -> None:
		employee_id = self._make_employee()
		self._make_log(employee_id, date(2026, 5, 1), login_hour=9, hours_worked=8)
		_recompute_employee_month(employee_id, "2026-05")

		self._make_log(employee_id, date(2026, 5, 2), login_hour=9, hours_worked=4)
		_recompute_employee_month(employee_id, "2026-05")

		stats = stats_repo.get_employee_monthly_stats(employee_id, "2026-05")
		self.assertEqual(stats.days_present, 2)
		self.assertAlmostEqual(stats.avg_hours, 6.0, places=1)

	def test_recompute_averages_login_and_logout_times(self) -> None:
		employee_id = self._make_employee()
		self._make_log(employee_id, date(2026, 6, 1), login_hour=8, hours_worked=8)
		self._make_log(employee_id, date(2026, 6, 2), login_hour=10, hours_worked=8)

		_recompute_employee_month(employee_id, "2026-06")

		stats = stats_repo.get_employee_monthly_stats(employee_id, "2026-06")
		# average of 08:00 and 10:00 login times is 09:00
		self.assertEqual(stats.avg_login_time, timedelta(hours=9))

	def test_recompute_with_no_activity_yields_zeroed_row(self) -> None:
		employee_id = self._make_employee()

		_recompute_employee_month(employee_id, "2026-07")

		stats = stats_repo.get_employee_monthly_stats(employee_id, "2026-07")
		self.assertIsNotNone(stats)
		self.assertEqual(stats.days_present, 0)
		self.assertEqual(stats.avg_hours, 0.0)

	def test_enqueue_pushes_the_real_job_onto_the_long_queue(self) -> None:
		with patch("frappe.enqueue") as mock_enqueue:
			enqueue_recompute_monthly_stats()

		mock_enqueue.assert_called_once_with(
			"analytics_portal.jobs.recompute_monthly_stats.recompute_monthly_stats",
			queue="long",
		)
