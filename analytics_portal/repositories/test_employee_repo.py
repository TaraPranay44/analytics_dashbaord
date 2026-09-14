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
