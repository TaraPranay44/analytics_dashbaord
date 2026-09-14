# Copyright (c) 2026, EMPLOYEE ANALYTICS PORTAL and Contributors
# See license.txt

import frappe
from frappe.query_builder import DocType
from frappe.tests import IntegrationTestCase

from analytics_portal.constants.api_constants import PAGE_SIZE_MAX
from analytics_portal.utils.pagination import paginate


class TestPagination(IntegrationTestCase):
	"""Tests for docs/04_BACKEND_RULES.md §7/§9 - `utils.pagination.paginate`."""

	def test_paginate_applies_limit_and_offset(self) -> None:
		employee = DocType("Employee")
		query = frappe.qb.from_(employee).select(employee.employee_id)

		paginated = paginate(query, start=10, limit=20)

		sql = paginated.get_sql()
		self.assertIn("LIMIT 20", sql)
		self.assertIn("OFFSET 10", sql)

	def test_paginate_caps_limit_at_page_size_max(self) -> None:
		employee = DocType("Employee")
		query = frappe.qb.from_(employee).select(employee.employee_id)

		paginated = paginate(query, start=0, limit=PAGE_SIZE_MAX * 10)

		self.assertIn(f"LIMIT {PAGE_SIZE_MAX}", paginated.get_sql())
