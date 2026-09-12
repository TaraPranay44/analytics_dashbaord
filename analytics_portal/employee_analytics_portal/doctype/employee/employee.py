# Copyright (c) 2026, EMPLOYEE ANALYTICS PORTAL and contributors
# For license information, please see license.txt

import frappe
from frappe.model.document import Document

from analytics_portal.constants.string_constants import (
	EMPLOYEE_MANAGER_CYCLE_MESSAGE,
	EMPLOYEE_MANAGER_SELF_REFERENCE_MESSAGE,
)


class Employee(Document):
	"""Controller for the `Employee` DocType. See docs/04_BACKEND_RULES.md §4.1."""

	def validate(self) -> None:
		"""Guard the self-referential `manager` link against self-reference and cycles."""
		self.validate_manager_not_self()
		self.validate_no_manager_cycle()

	def validate_manager_not_self(self) -> None:
		"""Raise if `manager` points at this same employee."""
		if self.manager and self.manager == self.name:
			frappe.throw(EMPLOYEE_MANAGER_SELF_REFERENCE_MESSAGE)

	def validate_no_manager_cycle(self) -> None:
		"""Walk the manager chain upward and raise if it loops back to this employee.

		Two employees cannot end up in each other's manager chain (directly or
		transitively) — that would break `employee_repo.get_manager_chain`, which
		assumes the chain terminates.
		"""
		seen = {self.name}
		current = self.manager
		while current:
			if current in seen:
				frappe.throw(EMPLOYEE_MANAGER_CYCLE_MESSAGE)
			seen.add(current)
			current = frappe.db.get_value("Employee", current, "manager")
