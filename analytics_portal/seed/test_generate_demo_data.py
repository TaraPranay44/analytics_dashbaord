# Copyright (c) 2026, EMPLOYEE ANALYTICS PORTAL and Contributors
# See license.txt

import frappe
from frappe.tests import IntegrationTestCase

from analytics_portal.seed.generate_demo_data import run

TEST_ID_PREFIX = "TEST-SEED-EMP-"
EMPLOYEE_COUNT = 15
DAYS = 4


class TestGenerateDemoData(IntegrationTestCase):
	"""Tests for the Phase 1 seed script (docs/03_PHASED_ROADMAP.md).

	Runs at a tiny scale with `commit=False` so everything stays inside this
	test's transaction and rolls back at class teardown - it must never
	persist rows into the real site database. Every query below is also
	scoped to `TEST_ID_PREFIX` (not a plain, unfiltered `frappe.get_all`),
	because the real 30,000-employee dataset may already exist committed in
	this same database - an unfiltered count would include it and give a
	wrong result.
	"""

	@classmethod
	def setUpClass(cls) -> None:
		super().setUpClass()
		run(employee_count=EMPLOYEE_COUNT, days=DAYS, commit=False, id_prefix=TEST_ID_PREFIX)

	def _seeded_employees(self) -> dict[str, str | None]:
		rows = frappe.get_all(
			"Employee",
			filters=[["name", "like", f"{TEST_ID_PREFIX}%"]],
			fields=["name", "manager"],
			as_list=True,
		)
		return dict(rows)

	def _seeded_logs(self) -> list[frappe._dict]:
		return frappe.get_all(
			"Employee Activity Log",
			filters=[["employee", "like", f"{TEST_ID_PREFIX}%"]],
			fields=["employee", "login_time", "logout_time", "total_hours"],
		)

	def test_generates_the_requested_row_counts(self) -> None:
		self.assertEqual(len(self._seeded_employees()), EMPLOYEE_COUNT)
		self.assertEqual(len(self._seeded_logs()), EMPLOYEE_COUNT * DAYS)

	def test_manager_hierarchy_has_no_cycles(self) -> None:
		managers_by_employee = self._seeded_employees()
		for employee in managers_by_employee:
			seen = {employee}
			current = managers_by_employee[employee]
			while current:
				self.assertNotIn(current, seen, msg=f"manager cycle detected starting at {employee}")
				seen.add(current)
				current = managers_by_employee.get(current)

	def test_total_hours_matches_login_and_logout_gap(self) -> None:
		logs = self._seeded_logs()
		self.assertTrue(logs)
		for log in logs:
			if not log.logout_time:
				self.assertEqual(log.total_hours, 0.0)
				continue
			expected_hours = round((log.logout_time - log.login_time).total_seconds() / 3600, 2)
			self.assertAlmostEqual(log.total_hours, expected_hours, places=2)

	def test_every_activity_log_links_to_a_seeded_employee(self) -> None:
		employee_ids = set(self._seeded_employees())
		log_employee_ids = {log.employee for log in self._seeded_logs()}
		self.assertTrue(log_employee_ids.issubset(employee_ids))
