# Copyright (c) 2026, EMPLOYEE ANALYTICS PORTAL and contributors
# For license information, please see license.txt

from frappe.model.document import Document


class EmployeeActivityLog(Document):
	"""Controller for `Employee Activity Log`. See docs/04_BACKEND_RULES.md §4.2."""

	def before_save(self) -> None:
		"""Compute `total_hours` from `login_time`/`logout_time`.

		`total_hours` is never accepted from client input — it is always
		derived here.
		"""
		raise NotImplementedError
