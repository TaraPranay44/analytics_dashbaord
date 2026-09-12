# Copyright (c) 2026, EMPLOYEE ANALYTICS PORTAL and Contributors
# See license.txt

import frappe
from frappe.tests import IntegrationTestCase


class TestEmployeeMonthlyStats(IntegrationTestCase):
	"""Schema smoke tests for docs/04_BACKEND_RULES.md §4.3. Populated only by
	`jobs/recompute_monthly_stats.py` (Part 3) - no controller logic here yet.

	The shared `Employee` fixture is created once in `setUpClass`, not `setUp` -
	`IntegrationTestCase` only rolls the DB back at class teardown.
	"""

	@classmethod
	def setUpClass(cls) -> None:
		super().setUpClass()
		cls.employee = frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": "Monthly Stats Test Employee",
				"employee_id": "TEST-EMP-MSTATS",
			}
		).insert()

	def test_create_monthly_stats_row(self) -> None:
		stats = frappe.get_doc(
			{
				"doctype": "Employee Monthly Stats",
				"employee": self.employee.name,
				"year_month": "2026-01",
				"avg_hours": 7.5,
				"avg_login_time": "09:00:00",
				"avg_logout_time": "17:30:00",
				"days_present": 20,
			}
		).insert()
		self.assertEqual(stats.avg_hours, 7.5)
		self.assertEqual(stats.days_present, 20)
