# Copyright (c) 2026, EMPLOYEE ANALYTICS PORTAL and Contributors
# See license.txt

from datetime import date, datetime, timedelta

import frappe
from frappe.tests import IntegrationTestCase

from analytics_portal.api.v1 import employee as employee_api
from analytics_portal.api.v1 import logs as logs_api
from analytics_portal.api.v1 import org as org_api
from analytics_portal.constants.api_constants import PAGE_SIZE_MAX
from analytics_portal.constants.cache_keys import org_dashboard_key

_MARKER = f"ZAPITEST{frappe.generate_hash(length=6)}"


class TestApiV1(IntegrationTestCase):
	"""Thin-wiring tests for docs/04_BACKEND_RULES.md §5 - the whitelisted `api/v1` layer.

	These call the whitelisted functions directly (they're plain Python
	functions under `@frappe.whitelist()`) rather than over HTTP - that's
	enough to prove the API layer parses params and delegates to the service
	layer correctly; the service/repository logic itself is covered by their
	own test files.
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
			}
		).insert()
		for day_offset in range(2):
			day = date(2026, 8, 1) + timedelta(days=day_offset)
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

	def test_employee_list_returns_paginated_envelope(self) -> None:
		result = employee_api.employee_list(q=_MARKER, start=0, limit=10)
		self.assertEqual({"data", "start", "limit", "has_more"}, set(result.keys()))
		self.assertEqual(len(result["data"]), 2)

	def test_employee_list_caps_limit_at_page_size_max(self) -> None:
		result = employee_api.employee_list(q=_MARKER, start=0, limit=PAGE_SIZE_MAX + 500)
		self.assertEqual(result["limit"], PAGE_SIZE_MAX)

	def test_employee_detail_returns_identity_and_trend(self) -> None:
		result = employee_api.employee_detail(self.employee.name)
		self.assertEqual(result["employee_id"], self.employee.name)
		self.assertIn("trend", result)

	def test_employee_detail_raises_for_unknown_employee(self) -> None:
		with self.assertRaises(frappe.DoesNotExistError):
			employee_api.employee_detail(f"{_MARKER}-NOT-REAL")

	def test_employee_monthly_trend_returns_a_plain_unpaginated_list(self) -> None:
		frappe.get_doc(
			{
				"doctype": "Employee Monthly Stats",
				"employee": self.employee.name,
				"year_month": "2026-02",
				"avg_hours": 7.5,
				"days_present": 19,
			}
		).insert()

		result = employee_api.employee_monthly_trend(self.employee.name)

		self.assertEqual(result, [{"year_month": "2026-02", "avg_hours": 7.5}])

	def test_employee_logs_returns_paginated_envelope(self) -> None:
		result = logs_api.employee_logs(self.employee.name, "2026-08-01", "2026-08-02", start=0, limit=10)
		self.assertEqual(len(result["data"]), 2)
		self.assertFalse(result["has_more"])

	def test_org_dashboard_returns_tile_fields(self) -> None:
		frappe.cache().delete_value(org_dashboard_key())
		frappe.get_doc(
			{
				"doctype": "Org Daily Stats",
				"date": date(2032, 1, 1),
				"total_employees": 3,
				"avg_hours_org": 5.0,
			}
		).insert()

		result = org_api.org_dashboard()
		self.assertEqual(result["total_employees"], 3)

	def test_org_hierarchy_returns_manager_chain_and_reports(self) -> None:
		result = org_api.org_hierarchy(self.employee.name)
		self.assertEqual([m["employee_id"] for m in result["manager_chain"]], [self.manager.name])
