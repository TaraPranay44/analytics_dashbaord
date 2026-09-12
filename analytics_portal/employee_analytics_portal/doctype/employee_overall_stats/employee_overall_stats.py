# Copyright (c) 2026, EMPLOYEE ANALYTICS PORTAL and contributors
# For license information, please see license.txt

from frappe.model.document import Document


class EmployeeOverallStats(Document):
	"""Controller for `Employee Overall Stats`. See docs/04_BACKEND_RULES.md §4.4.

	Rows here are written only by `jobs/recompute_overall_stats.py` via
	`repositories/stats_repo.py` — never by API/service code directly.
	"""
