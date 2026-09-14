# Copyright (c) 2026, EMPLOYEE ANALYTICS PORTAL and Contributors
# See license.txt

import frappe
from frappe.tests import IntegrationTestCase

from analytics_portal.repositories import employee_repo

# A distinctive, unique-per-class marker folded into `employee_name` so
# `q`-filtered queries only ever match this test class's own fixtures - this
# bench's dev database has a separate, very large (30,000-employee) seed job
# committing real Employee rows concurrently, so an unfiltered/unscoped query
# would return an unbounded and constantly-changing result set.
_MARKER = f"ZQATEST{frappe.generate_hash(length=6)}"


class TestEmployeeRepo(IntegrationTestCase):
	"""Tests for docs/04_BACKEND_RULES.md §5/§7 - `employee_repo`."""

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
		cls.report_one = frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": f"{_MARKER} Alice",
				"employee_id": f"{_MARKER}-EMP1",
				"manager": cls.manager.name,
			}
		).insert()
		cls.report_two = frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": f"{_MARKER} Bob",
				"employee_id": f"{_MARKER}-EMP2",
				"manager": cls.manager.name,
			}
		).insert()
		frappe.get_doc(
			{
				"doctype": "Employee Overall Stats",
				"employee": cls.report_one.name,
				"avg_hours_overall": 7.5,
			}
		).insert()

	def test_list_employees_matches_by_name_or_id(self) -> None:
		rows = employee_repo.list_employees(q=_MARKER, manager=None, sort=None, start=0, limit=100)
		matched_ids = {row.employee_id for row in rows}
		self.assertEqual(matched_ids, {self.manager.name, self.report_one.name, self.report_two.name})

	def test_list_employees_filters_by_manager(self) -> None:
		rows = employee_repo.list_employees(
			q=_MARKER, manager=self.manager.name, sort=None, start=0, limit=100
		)
		matched_ids = {row.employee_id for row in rows}
		self.assertEqual(matched_ids, {self.report_one.name, self.report_two.name})

	def test_list_employees_joins_manager_name_and_overall_stats(self) -> None:
		rows = employee_repo.list_employees(q=_MARKER, manager=None, sort=None, start=0, limit=100)
		row = next(r for r in rows if r.employee_id == self.report_one.name)
		self.assertEqual(row.manager_name, f"{_MARKER} Manager")
		self.assertAlmostEqual(row.avg_hours_overall, 7.5, places=1)

	def test_list_employees_is_paginated(self) -> None:
		page_one = employee_repo.list_employees(q=_MARKER, manager=None, sort=None, start=0, limit=2)
		page_two = employee_repo.list_employees(q=_MARKER, manager=None, sort=None, start=2, limit=2)
		self.assertEqual(len(page_one), 2)
		self.assertEqual(len(page_two), 1)

	def test_count_employees_matches_list_filter(self) -> None:
		total = employee_repo.count_employees(q=_MARKER, manager=self.manager.name)
		self.assertEqual(total, 2)

	def test_get_employee_by_id(self) -> None:
		result = employee_repo.get_employee_by_id(self.report_one.name)
		self.assertIsNotNone(result)
		self.assertEqual(result.employee_name, f"{_MARKER} Alice")

	def test_get_employee_by_id_returns_none_when_missing(self) -> None:
		self.assertIsNone(employee_repo.get_employee_by_id(f"{_MARKER}-DOES-NOT-EXIST"))

	def test_get_manager_chain_walks_upward(self) -> None:
		chain = employee_repo.get_manager_chain(self.report_one.name)
		self.assertEqual([m["employee_id"] for m in chain], [self.manager.name])

	def test_get_manager_chain_is_empty_for_top_of_chain(self) -> None:
		self.assertEqual(employee_repo.get_manager_chain(self.manager.name), [])

	def test_get_direct_reports(self) -> None:
		reports = employee_repo.get_direct_reports(self.manager.name)
		self.assertEqual({r.employee_id for r in reports}, {self.report_one.name, self.report_two.name})

	def test_count_all_employees_reflects_the_full_table(self) -> None:
		# Global count, not `_MARKER`-scoped, and deliberately NOT using
		# `_MARKER`/`self.manager` for the throwaway fixture below - the other
		# tests in this class assert exact `q=_MARKER` result sets, and
		# `IntegrationTestCase` only rolls back at class teardown, so an extra
		# `_MARKER`-tagged row here would leak into and break those.
		other_marker = f"ZQATEST-COUNTALL-{frappe.generate_hash(length=6)}"
		before = employee_repo.count_all_employees()
		frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": f"{other_marker} Count Test",
				"employee_id": other_marker,
			}
		).insert()
		after = employee_repo.count_all_employees()
		self.assertEqual(after, before + 1)

	def test_count_distinct_managers_counts_unique_managers_only(self) -> None:
		other_marker = f"ZQATEST-MGRCOUNT-{frappe.generate_hash(length=6)}"
		own_manager = frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": f"{other_marker} Manager",
				"employee_id": f"{other_marker}-MGR",
			}
		).insert()
		before = employee_repo.count_distinct_managers()
		frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": f"{other_marker} Report One",
				"employee_id": f"{other_marker}-EMP1",
				"manager": own_manager.name,
			}
		).insert()
		after_first_report = employee_repo.count_distinct_managers()
		self.assertEqual(after_first_report, before + 1)

		# A second report under the SAME manager must not increase the
		# distinct count further.
		frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": f"{other_marker} Report Two",
				"employee_id": f"{other_marker}-EMP2",
				"manager": own_manager.name,
			}
		).insert()
		after_second_report = employee_repo.count_distinct_managers()
		self.assertEqual(after_second_report, after_first_report)

	def test_count_employees_joined_within_days(self) -> None:
		other_marker = f"ZQATEST-JOINWINDOW-{frappe.generate_hash(length=6)}"
		before = employee_repo.count_employees_joined_within_days(1)
		frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": f"{other_marker} Just Joined",
				"employee_id": other_marker,
				"date_of_joining": frappe.utils.nowdate(),
			}
		).insert()
		after = employee_repo.count_employees_joined_within_days(1)
		self.assertEqual(after, before + 1)

	def test_count_employees_registered_by_excludes_later_joiners(self) -> None:
		from frappe.utils import add_days, nowdate

		other_marker = f"ZQATEST-REGBY-{frappe.generate_hash(length=6)}"
		cutoff = add_days(nowdate(), -1)
		before = employee_repo.count_employees_registered_by(cutoff)
		frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": f"{other_marker} Joins Today",
				"employee_id": other_marker,
				"date_of_joining": nowdate(),
			}
		).insert()
		# Joined today, which is AFTER `cutoff` (yesterday) - must not be counted.
		after = employee_repo.count_employees_registered_by(cutoff)
		self.assertEqual(after, before)
