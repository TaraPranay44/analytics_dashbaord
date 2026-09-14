# Copyright (c) 2026, EMPLOYEE ANALYTICS PORTAL and Contributors
# See license.txt

from datetime import date

import frappe
from frappe.tests import IntegrationTestCase

# Fixed, far-future dates - not `add_days(nowdate(), -N)` - so this test never
# collides with a real `Org Daily Stats` row once `jobs/recompute_org_daily_stats.py`
# (Part 3) has actually run against real/seeded data for "yesterday".


class TestOrgDailyStats(IntegrationTestCase):
	"""Schema smoke tests for docs/04_BACKEND_RULES.md §4.5. Populated only by
	`jobs/recompute_org_daily_stats.py` (Part 3) - no controller logic here yet."""

	def test_create_org_daily_stats_row(self) -> None:
		stats = frappe.get_doc(
			{
				"doctype": "Org Daily Stats",
				"date": date(2099, 1, 1),
				"total_employees": 30000,
				"avg_hours_org": 7.4,
				"avg_login_time_org": "09:02:00",
			}
		).insert()
		self.assertEqual(stats.total_employees, 30000)

	def test_date_must_be_unique(self) -> None:
		target_date = date(2099, 1, 2)
		frappe.get_doc(
			{
				"doctype": "Org Daily Stats",
				"date": target_date,
				"total_employees": 100,
				"avg_hours_org": 7.0,
			}
		).insert()
		with self.assertRaises(frappe.DuplicateEntryError):
			frappe.get_doc(
				{
					"doctype": "Org Daily Stats",
					"date": target_date,
					"total_employees": 200,
					"avg_hours_org": 8.0,
				}
			).insert()
