# Copyright (c) 2026, EMPLOYEE ANALYTICS PORTAL and Contributors
# See license.txt

from datetime import date, datetime, timedelta

import frappe
from frappe.tests import IntegrationTestCase

from analytics_portal.services import logs_service


class TestLogsService(IntegrationTestCase):
	"""Tests for docs/04_BACKEND_RULES.md §5/§9 - `logs_service.get_employee_logs_page`."""

	@classmethod
	def setUpClass(cls) -> None:
		super().setUpClass()
		cls.employee = frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": "Logs Service Test Employee",
				"employee_id": f"TEST-LOGSVC-{frappe.generate_hash(length=8)}",
			}
		).insert()
		for day_offset in range(3):
			day = date(2026, 3, 1) + timedelta(days=day_offset)
			login = datetime(day.year, day.month, day.day, 9, 0, 0)
			frappe.get_doc(
				{
					"doctype": "Employee Activity Log",
					"employee": cls.employee.name,
					"date": day,
					"login_time": login,
					"logout_time": login + timedelta(hours=8),
				}
			).insert()

	def test_returns_paginated_envelope(self) -> None:
		result = logs_service.get_employee_logs_page(
			self.employee.name, "2026-03-01", "2026-03-03", start=0, limit=20
		)
		self.assertEqual(len(result["data"]), 3)
		self.assertFalse(result["has_more"])

	def test_has_more_on_partial_page(self) -> None:
		result = logs_service.get_employee_logs_page(
			self.employee.name, "2026-03-01", "2026-03-03", start=0, limit=2
		)
		self.assertEqual(len(result["data"]), 2)
		self.assertTrue(result["has_more"])

	def test_raises_for_unknown_employee(self) -> None:
		with self.assertRaises(frappe.DoesNotExistError):
			logs_service.get_employee_logs_page("NOT-A-REAL-EMPLOYEE-ID", None, None, start=0, limit=20)
