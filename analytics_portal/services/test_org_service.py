# Copyright (c) 2026, EMPLOYEE ANALYTICS PORTAL and Contributors
# See license.txt

from datetime import date

import frappe
from frappe.tests import IntegrationTestCase

from analytics_portal.constants.cache_keys import org_dashboard_key
from analytics_portal.services import org_service


class TestOrgService(IntegrationTestCase):
	"""Tests for docs/04_BACKEND_RULES.md §5/§6 - `org_service`."""

	def test_org_dashboard_reads_the_most_recent_org_daily_stats_row(self) -> None:
		# org_dashboard_key() carries no params, so it's one shared cache entry
		# across the whole test run (ttl=None, invalidated only by the nightly
		# job in real use) - clear it first so an earlier test's cached value
		# can't leak into this assertion regardless of test execution order.
		frappe.cache().delete_value(org_dashboard_key())

		frappe.get_doc(
			{
				"doctype": "Org Daily Stats",
				"date": date(2031, 1, 1),
				"total_employees": 100,
				"avg_hours_org": 6.5,
			}
		).insert()
		frappe.get_doc(
			{
				"doctype": "Org Daily Stats",
				"date": date(2031, 1, 2),
				"total_employees": 105,
				"avg_hours_org": 7.0,
			}
		).insert()

		result = org_service.get_org_dashboard()

		self.assertEqual(result["total_employees"], 105)
		self.assertAlmostEqual(result["avg_hours_org"], 7.0, places=1)

	def test_org_hierarchy_returns_chain_and_reports(self) -> None:
		manager = frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": "Org Hierarchy Test Manager",
				"employee_id": f"TEST-ORGHIER-MGR-{frappe.generate_hash(length=8)}",
			}
		).insert()
		report = frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": "Org Hierarchy Test Report",
				"employee_id": f"TEST-ORGHIER-EMP-{frappe.generate_hash(length=8)}",
				"manager": manager.name,
			}
		).insert()

		result = org_service.get_org_hierarchy(report.name)
		self.assertEqual([m["employee_id"] for m in result["manager_chain"]], [manager.name])

		manager_result = org_service.get_org_hierarchy(manager.name)
		self.assertEqual([r.employee_id for r in manager_result["direct_reports"]], [report.name])

	def test_org_hierarchy_raises_for_unknown_employee(self) -> None:
		with self.assertRaises(frappe.DoesNotExistError):
			org_service.get_org_hierarchy("NOT-A-REAL-EMPLOYEE-ID")
