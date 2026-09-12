# Copyright (c) 2026, EMPLOYEE ANALYTICS PORTAL and Contributors
# See license.txt

import frappe
from frappe.tests import IntegrationTestCase
from frappe.utils import add_to_date, now_datetime


class TestEmployeeActivityLog(IntegrationTestCase):
	"""Tests for docs/04_BACKEND_RULES.md §4.2 - `total_hours` is always server-computed.

	The shared `Employee` fixture is created once in `setUpClass`, not `setUp` -
	Frappe's `IntegrationTestCase` only rolls the DB back at class teardown, so
	re-inserting the same fixture before every test method would collide.
	"""

	@classmethod
	def setUpClass(cls) -> None:
		super().setUpClass()
		cls.employee = frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": "Activity Log Test Employee",
				"employee_id": "TEST-EMP-LOG",
			}
		).insert()

	def test_total_hours_computed_from_login_and_logout(self) -> None:
		login = now_datetime()
		logout = add_to_date(login, hours=8)
		log = frappe.get_doc(
			{
				"doctype": "Employee Activity Log",
				"employee": self.employee.name,
				"date": login.date(),
				"login_time": login,
				"logout_time": logout,
			}
		).insert()
		self.assertAlmostEqual(log.total_hours, 8.0, places=1)

	def test_total_hours_ignores_client_submitted_value(self) -> None:
		login = now_datetime()
		logout = add_to_date(login, hours=2)
		log = frappe.get_doc(
			{
				"doctype": "Employee Activity Log",
				"employee": self.employee.name,
				"date": login.date(),
				"login_time": login,
				"logout_time": logout,
				"total_hours": 999,
			}
		).insert()
		self.assertAlmostEqual(log.total_hours, 2.0, places=1)

	def test_total_hours_is_zero_when_not_yet_logged_out(self) -> None:
		login = now_datetime()
		log = frappe.get_doc(
			{
				"doctype": "Employee Activity Log",
				"employee": self.employee.name,
				"date": login.date(),
				"login_time": login,
			}
		).insert()
		self.assertEqual(log.total_hours, 0.0)

	def test_logout_before_login_is_rejected(self) -> None:
		login = now_datetime()
		logout = add_to_date(login, hours=-1)
		with self.assertRaises(frappe.ValidationError):
			frappe.get_doc(
				{
					"doctype": "Employee Activity Log",
					"employee": self.employee.name,
					"date": login.date(),
					"login_time": login,
					"logout_time": logout,
				}
			).insert()

	def test_total_hours_recomputed_on_update(self) -> None:
		login = now_datetime()
		log = frappe.get_doc(
			{
				"doctype": "Employee Activity Log",
				"employee": self.employee.name,
				"date": login.date(),
				"login_time": login,
				"logout_time": add_to_date(login, hours=4),
			}
		).insert()

		log.logout_time = add_to_date(login, hours=6)
		log.save()

		self.assertAlmostEqual(log.total_hours, 6.0, places=1)

	def test_activity_log_requires_a_valid_employee_link(self) -> None:
		login = now_datetime()
		with self.assertRaises(frappe.LinkValidationError):
			frappe.get_doc(
				{
					"doctype": "Employee Activity Log",
					"employee": "NON-EXISTENT-EMPLOYEE",
					"date": login.date(),
					"login_time": login,
					"logout_time": add_to_date(login, hours=1),
				}
			).insert()
