# Copyright (c) 2026, EMPLOYEE ANALYTICS PORTAL and Contributors
# See license.txt

import frappe
from frappe.tests import IntegrationTestCase

from analytics_portal.services import employee_service

_MARKER = f"ZSVCTEST{frappe.generate_hash(length=6)}"


class TestEmployeeService(IntegrationTestCase):
	"""Tests for docs/04_BACKEND_RULES.md §5/§6 - `employee_service`.

	`_MARKER` keeps `list_employees(q=...)` scoped to this class's own fixtures,
	since this bench's dev database has a large, separately-running seed job.
	"""

	@classmethod
	def setUpClass(cls) -> None:
		super().setUpClass()
		cls.manager = frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": f"{_MARKER} Manager",
				"employee_id": f"{_MARKER}-MGR",
			}
		).insert()
		cls.employee = frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": f"{_MARKER} Employee",
				"employee_id": f"{_MARKER}-EMP",
				"manager": cls.manager.name,
				"date_of_joining": "2024-01-15",
			}
		).insert()
		frappe.get_doc(
			{
				"doctype": "Employee Overall Stats",
				"employee": cls.employee.name,
				"avg_hours_overall": 7.25,
			}
		).insert()

	def test_list_employees_response_envelope(self) -> None:
		result = employee_service.list_employees(q=_MARKER, manager=None, sort=None, start=0, limit=20)
		self.assertEqual(result["start"], 0)
		self.assertEqual(result["limit"], 20)
		self.assertFalse(result["has_more"])
		self.assertEqual(len(result["data"]), 2)

	def test_list_employees_has_more_when_a_further_page_exists(self) -> None:
		result = employee_service.list_employees(q=_MARKER, manager=None, sort=None, start=0, limit=1)
		self.assertTrue(result["has_more"])
		self.assertEqual(len(result["data"]), 1)

	def test_get_employee_detail_includes_manager_chain_and_stats(self) -> None:
		detail = employee_service.get_employee_detail(self.employee.name)
		self.assertEqual(detail["employee_id"], self.employee.name)
		self.assertEqual([m["employee_id"] for m in detail["manager_chain"]], [self.manager.name])
		self.assertAlmostEqual(detail["avg_hours_overall"], 7.25, places=1)
		self.assertIn("trend", detail)

	def test_get_employee_detail_raises_for_unknown_employee(self) -> None:
		with self.assertRaises(frappe.DoesNotExistError):
			employee_service.get_employee_detail(f"{_MARKER}-NOT-REAL")

	def test_get_employee_monthly_trend_returns_months_oldest_first(self) -> None:
		frappe.get_doc(
			{
				"doctype": "Employee Monthly Stats",
				"employee": self.employee.name,
				"year_month": "2026-03",
				"avg_hours": 8.0,
				"days_present": 20,
			}
		).insert()
		frappe.get_doc(
			{
				"doctype": "Employee Monthly Stats",
				"employee": self.employee.name,
				"year_month": "2026-01",
				"avg_hours": 6.5,
				"days_present": 18,
			}
		).insert()

		trend = employee_service.get_employee_monthly_trend(self.employee.name)

		self.assertEqual([row["year_month"] for row in trend], ["2026-01", "2026-03"])
		self.assertAlmostEqual(trend[0]["avg_hours"], 6.5, places=1)

	def test_get_employee_monthly_trend_raises_for_unknown_employee(self) -> None:
		with self.assertRaises(frappe.DoesNotExistError):
			employee_service.get_employee_monthly_trend(f"{_MARKER}-NOT-REAL")
