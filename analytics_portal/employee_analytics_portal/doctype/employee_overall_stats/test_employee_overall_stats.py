# Copyright (c) 2026, EMPLOYEE ANALYTICS PORTAL and Contributors
# See license.txt

import frappe
from frappe.tests import IntegrationTestCase


class TestEmployeeOverallStats(IntegrationTestCase):
	"""Schema smoke tests for docs/04_BACKEND_RULES.md §4.4. Populated only by
	`jobs/recompute_overall_stats.py` (Part 3) - no controller logic here yet.

	The shared `Employee` fixture is created once in `setUpClass`, not `setUp` -
	`IntegrationTestCase` only rolls the DB back at class teardown.
	"""

	@classmethod
	def setUpClass(cls) -> None:
		super().setUpClass()
		cls.employee = frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": "Overall Stats Test Employee",
				"employee_id": "TEST-EMP-OSTATS",
			}
		).insert()

	def test_create_overall_stats_row(self) -> None:
		stats = frappe.get_doc(
			{
				"doctype": "Employee Overall Stats",
				"employee": self.employee.name,
				"avg_hours_overall": 7.8,
				"avg_login_time_overall": "09:05:00",
				"avg_logout_time_overall": "17:45:00",
				"last_computed": frappe.utils.now_datetime(),
			}
		).insert()
		self.assertEqual(stats.avg_hours_overall, 7.8)

	def test_employee_link_must_be_unique(self) -> None:
		# Uses its own employee (not the shared class fixture) so this test doesn't
		# collide with the stats row `test_create_overall_stats_row` leaves behind -
		# there's no DB rollback between test methods in the same class.
		other_employee = frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": "Overall Stats Uniqueness Test Employee",
				"employee_id": "TEST-EMP-OSTATS-UNIQ",
			}
		).insert()
		frappe.get_doc(
			{
				"doctype": "Employee Overall Stats",
				"employee": other_employee.name,
				"avg_hours_overall": 7.0,
			}
		).insert()
		with self.assertRaises(frappe.DuplicateEntryError):
			frappe.get_doc(
				{
					"doctype": "Employee Overall Stats",
					"employee": other_employee.name,
					"avg_hours_overall": 8.0,
				}
			).insert()
