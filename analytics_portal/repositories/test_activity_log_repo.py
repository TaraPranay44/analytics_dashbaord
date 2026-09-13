# Copyright (c) 2026, EMPLOYEE ANALYTICS PORTAL and Contributors
# See license.txt

from datetime import date, datetime, timedelta

import frappe
from frappe.tests import IntegrationTestCase

from analytics_portal.repositories import activity_log_repo


class TestActivityLogRepo(IntegrationTestCase):
	"""Tests for docs/04_BACKEND_RULES.md §5/§7 - `activity_log_repo` query functions.

	Every query here is scoped to one freshly-created employee, so the
	concurrently-running 30,000-employee seed job in this bench's dev database
	cannot contaminate the result sets being asserted on.
	"""

	@classmethod
	def setUpClass(cls) -> None:
		super().setUpClass()
		cls.employee = frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": "Activity Log Repo Test Employee",
				"employee_id": f"TEST-ALREPO-{frappe.generate_hash(length=8)}",
			}
		).insert()

		for day_offset, hours in ((3, 8.0), (2, 6.0), (1, 4.0)):
			day = date(2026, 2, 10) + timedelta(days=day_offset)
			login = datetime(day.year, day.month, day.day, 9, 0, 0)
			logout = login + timedelta(hours=hours)
			frappe.get_doc(
				{
					"doctype": "Employee Activity Log",
					"employee": cls.employee.name,
					"date": day,
					"login_time": login,
					"logout_time": logout,
				}
			).insert()

	def test_get_employee_logs_page_orders_by_date_descending(self) -> None:
		rows = activity_log_repo.get_employee_logs_page(self.employee.name, None, None, start=0, limit=10)
		dates = [row.date for row in rows]
		self.assertEqual(dates, sorted(dates, reverse=True))
		self.assertEqual(len(rows), 3)

	def test_get_employee_logs_page_applies_date_range(self) -> None:
		rows = activity_log_repo.get_employee_logs_page(
			self.employee.name, date(2026, 2, 12), date(2026, 2, 13), start=0, limit=10
		)
		self.assertEqual(len(rows), 2)

	def test_get_employee_logs_page_is_paginated(self) -> None:
		page_one = activity_log_repo.get_employee_logs_page(self.employee.name, None, None, start=0, limit=2)
		page_two = activity_log_repo.get_employee_logs_page(self.employee.name, None, None, start=2, limit=2)
		self.assertEqual(len(page_one), 2)
		self.assertEqual(len(page_two), 1)

	def test_count_employee_logs_matches_date_range(self) -> None:
		total = activity_log_repo.count_employee_logs(
			self.employee.name, date(2026, 2, 12), date(2026, 2, 13)
		)
		self.assertEqual(total, 2)

	def test_get_recent_daily_hours_is_oldest_first(self) -> None:
		# Fixture maps day_offset (3, 2, 1) -> hours (8.0, 6.0, 4.0), so the
		# oldest date (day_offset=1, 2026-02-11) has 4.0 hours and the most
		# recent (day_offset=3, 2026-02-13) has 8.0 hours.
		rows = activity_log_repo.get_recent_daily_hours(self.employee.name, days=3)
		self.assertEqual([row.date for row in rows], sorted(row.date for row in rows))
		self.assertAlmostEqual(rows[0].total_hours, 4.0, places=1)
		self.assertAlmostEqual(rows[-1].total_hours, 8.0, places=1)
