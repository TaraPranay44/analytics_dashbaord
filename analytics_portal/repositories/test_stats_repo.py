# Copyright (c) 2026, EMPLOYEE ANALYTICS PORTAL and Contributors
# See license.txt

from datetime import date

import frappe
from frappe.tests import IntegrationTestCase

from analytics_portal.repositories import stats_repo

_MARKER = f"ZSTATSREPOTEST{frappe.generate_hash(length=6)}"


class TestStatsRepo(IntegrationTestCase):
	"""Tests for docs/04_BACKEND_RULES.md §5/§7 - `stats_repo`'s `org_insights`/
	`org_dashboard` support functions."""

	def test_count_employees_below_hours(self) -> None:
		employee_id = f"{_MARKER}-EMP"
		frappe.get_doc(
			{"doctype": "Employee", "employee_name": f"{_MARKER} Employee", "employee_id": employee_id}
		).insert()
		frappe.get_doc(
			{"doctype": "Employee Overall Stats", "employee": employee_id, "avg_hours_overall": 5.0}
		).insert()

		above = stats_repo.count_employees_below_hours(5.5)
		self.assertGreaterEqual(above, 1)

	def test_get_recent_org_daily_stats_is_oldest_first_and_bounded(self) -> None:
		for day_offset, hours in [(1, 6.0), (2, 7.0), (3, 8.0)]:
			frappe.get_doc(
				{
					"doctype": "Org Daily Stats",
					"date": date(2033, 1, day_offset),
					"total_employees": 10,
					"avg_hours_org": hours,
				}
			).insert()

		rows = stats_repo.get_recent_org_daily_stats(2)

		self.assertEqual(len(rows), 2)
		self.assertEqual([row.date for row in rows], [date(2033, 1, 2), date(2033, 1, 3)])
