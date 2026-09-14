# Copyright (c) 2026, EMPLOYEE ANALYTICS PORTAL and Contributors
# See license.txt

import frappe
from frappe.tests import IntegrationTestCase

from analytics_portal.utils.validators import assert_employee_exists


class TestValidators(IntegrationTestCase):
	"""Tests for docs/04_BACKEND_RULES.md §5/§9 - `utils.validators.assert_employee_exists`."""

	def test_does_not_raise_for_existing_employee(self) -> None:
		employee = frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": "Validator Test Employee",
				"employee_id": f"TEST-VALIDATOR-{frappe.generate_hash(length=8)}",
			}
		).insert()

		assert_employee_exists(employee.name)  # should not raise

	def test_raises_does_not_exist_for_missing_employee(self) -> None:
		with self.assertRaises(frappe.DoesNotExistError):
			assert_employee_exists("TEST-VALIDATOR-DOES-NOT-EXIST")
