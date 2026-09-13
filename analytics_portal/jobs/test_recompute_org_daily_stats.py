# Copyright (c) 2026, EMPLOYEE ANALYTICS PORTAL and Contributors
# See license.txt

from datetime import date, datetime, timedelta
from unittest.mock import patch

import frappe
from frappe.tests import IntegrationTestCase

from analytics_portal.constants.cache_keys import org_dashboard_key
from analytics_portal.jobs.recompute_org_daily_stats import (
	_recompute_org_daily_stats_for_date,
	enqueue_recompute_org_daily_stats,
)
from analytics_portal.repositories import stats_repo

# Org Daily Stats has one row per calendar date, shared across every employee -
# there is no per-employee scope to isolate a test by. This bench's dev
# database has a very large (30,000-employee, ~365 day) seed job that backfills
# HISTORICAL dates, so a future date such as this one is guaranteed to never
# collide with real seeded/production rows.
_ISOLATED_TEST_DATE = date(2099, 6, 15)


class TestRecomputeOrgDailyStats(IntegrationTestCase):
	"""Tests for docs/04_BACKEND_RULES.md §7/§8 - `recompute_org_daily_stats`."""

	def _make_employee(self) -> str:
		employee_id = f"TEST-ORGSTATS-{frappe.generate_hash(length=8)}"
		frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": "Org Daily Stats Test Employee",
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

	def test_org_daily_stats_aggregates_every_employee_on_the_date(self) -> None:
		employee_a = self._make_employee()
		employee_b = self._make_employee()
		self._make_log(employee_a, _ISOLATED_TEST_DATE, login_hour=9, hours_worked=8)
		self._make_log(employee_b, _ISOLATED_TEST_DATE, login_hour=10, hours_worked=6)

		_recompute_org_daily_stats_for_date(_ISOLATED_TEST_DATE)

		stats = stats_repo.get_org_daily_stats(_ISOLATED_TEST_DATE)
		self.assertIsNotNone(stats)
		self.assertEqual(stats.total_employees, 2)
		self.assertAlmostEqual(stats.avg_hours_org, 7.0, places=1)

	def test_org_daily_stats_is_safe_to_rerun(self) -> None:
		employee_id = self._make_employee()
		rerun_date = date(2099, 7, 20)
		self._make_log(employee_id, rerun_date, login_hour=9, hours_worked=8)

		_recompute_org_daily_stats_for_date(rerun_date)
		_recompute_org_daily_stats_for_date(rerun_date)

		rows = frappe.get_all("Org Daily Stats", filters={"date": rerun_date})
		self.assertEqual(len(rows), 1)

	def test_org_daily_stats_with_no_activity_yields_zero_headcount(self) -> None:
		empty_date = date(2099, 8, 1)

		_recompute_org_daily_stats_for_date(empty_date)

		stats = stats_repo.get_org_daily_stats(empty_date)
		self.assertIsNotNone(stats)
		self.assertEqual(stats.total_employees, 0)
		self.assertEqual(stats.avg_hours_org, 0.0)

	def test_recompute_clears_the_stale_org_dashboard_cache(self) -> None:
		employee_id = self._make_employee()
		clear_cache_date = date(2099, 9, 1)
		self._make_log(employee_id, clear_cache_date, login_hour=9, hours_worked=8)

		frappe.cache().set_value(org_dashboard_key(), {"stale": "data"})

		_recompute_org_daily_stats_for_date(clear_cache_date)

		self.assertIsNone(frappe.cache().get_value(org_dashboard_key()))

	def test_enqueue_pushes_the_real_job_onto_the_long_queue(self) -> None:
		with patch("frappe.enqueue") as mock_enqueue:
			enqueue_recompute_org_daily_stats()

		mock_enqueue.assert_called_once_with(
			"analytics_portal.jobs.recompute_org_daily_stats.recompute_org_daily_stats",
			queue="long",
		)
