# Copyright (c) 2026, EMPLOYEE ANALYTICS PORTAL and contributors
# For license information, please see license.txt

import frappe
from frappe.model.document import Document
from frappe.utils import get_datetime

from analytics_portal.constants.string_constants import (
	ACTIVITY_LOG_LOGOUT_BEFORE_LOGIN_MESSAGE,
)


class EmployeeActivityLog(Document):
	"""Controller for `Employee Activity Log`. See docs/04_BACKEND_RULES.md §4.2."""

	def before_save(self) -> None:
		"""Compute `total_hours` from `login_time`/`logout_time`.

		`total_hours` is never accepted from client input — it is always
		derived here, overwriting whatever the client may have submitted.
		"""
		self.total_hours = self.compute_total_hours()

	def compute_total_hours(self) -> float:
		"""Return hours between `login_time` and `logout_time`, or 0.0 if not yet logged out.

		Raises:
		    frappe.ValidationError: if `logout_time` is earlier than `login_time`.
		"""
		if not self.login_time or not self.logout_time:
			return 0.0

		login_time = get_datetime(self.login_time)
		logout_time = get_datetime(self.logout_time)
		seconds_worked = (logout_time - login_time).total_seconds()

		if seconds_worked < 0:
			frappe.throw(ACTIVITY_LOG_LOGOUT_BEFORE_LOGIN_MESSAGE)

		return round(seconds_worked / 3600, 2)
