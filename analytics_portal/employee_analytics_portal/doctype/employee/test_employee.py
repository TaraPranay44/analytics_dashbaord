# Copyright (c) 2026, EMPLOYEE ANALYTICS PORTAL and Contributors
# See license.txt

import frappe
from frappe.tests import IntegrationTestCase


class TestEmployee(IntegrationTestCase):
	"""Tests for docs/04_BACKEND_RULES.md §4.1 (fields) and the manager-chain guards."""

	def test_create_employee_uses_employee_id_as_name(self) -> None:
		employee = frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": "Test Employee One",
				"employee_id": "TEST-EMP-001",
			}
		).insert()
		self.assertEqual(employee.name, "TEST-EMP-001")

	def test_employee_id_must_be_unique(self) -> None:
		frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": "Dup A",
				"employee_id": "TEST-EMP-DUP",
			}
		).insert()
		with self.assertRaises(frappe.DuplicateEntryError):
			frappe.get_doc(
				{
					"doctype": "Employee",
					"employee_name": "Dup B",
					"employee_id": "TEST-EMP-DUP",
				}
			).insert()

	def test_manager_cannot_be_self(self) -> None:
		employee = frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": "Self Manager",
				"employee_id": "TEST-EMP-SELF",
			}
		).insert()
		employee.manager = employee.name
		with self.assertRaises(frappe.ValidationError):
			employee.save()

	def test_two_employee_manager_cycle_is_rejected(self) -> None:
		emp_a = frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": "Cycle A",
				"employee_id": "TEST-EMP-CYCLE-A",
			}
		).insert()
		emp_b = frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": "Cycle B",
				"employee_id": "TEST-EMP-CYCLE-B",
				"manager": emp_a.name,
			}
		).insert()

		emp_a.manager = emp_b.name
		with self.assertRaises(frappe.ValidationError):
			emp_a.save()

	def test_transitive_manager_cycle_is_rejected(self) -> None:
		emp_a = frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": "Chain A",
				"employee_id": "TEST-EMP-CHAIN-A",
			}
		).insert()
		emp_b = frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": "Chain B",
				"employee_id": "TEST-EMP-CHAIN-B",
				"manager": emp_a.name,
			}
		).insert()
		emp_c = frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": "Chain C",
				"employee_id": "TEST-EMP-CHAIN-C",
				"manager": emp_b.name,
			}
		).insert()

		emp_a.manager = emp_c.name
		with self.assertRaises(frappe.ValidationError):
			emp_a.save()

	def test_valid_multilevel_manager_chain_is_allowed(self) -> None:
		top = frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": "Top",
				"employee_id": "TEST-EMP-TOP",
			}
		).insert()
		middle = frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": "Middle",
				"employee_id": "TEST-EMP-MIDDLE",
				"manager": top.name,
			}
		).insert()
		leaf = frappe.get_doc(
			{
				"doctype": "Employee",
				"employee_name": "Leaf",
				"employee_id": "TEST-EMP-LEAF",
				"manager": middle.name,
			}
		).insert()

		self.assertEqual(leaf.manager, middle.name)
		self.assertEqual(middle.manager, top.name)
