"""Whitelisted API endpoints: org_dashboard, org_insights, org_hierarchy.

Thin layer only - parse/validate params, call the service, shape the response.
No business logic here. See docs/04_BACKEND_RULES.md §1/§5.
"""

import frappe

from analytics_portal.services import org_service


@frappe.whitelist()
def org_dashboard() -> dict:
	"""Org-wide tiles for the landing dashboard.

	Returns:
	    Dashboard tile fields sourced from `Org Daily Stats`.
	"""
	return org_service.get_org_dashboard()


@frappe.whitelist()
def org_insights() -> dict:
	"""Supplementary real-data callouts for the dashboard's insight chips.

	Returns:
	    `manager_count`, `total_registered_employees`, `low_hours_threshold`,
	    `low_hours_employee_count`, `recent_hires_count`, `recent_hires_window_days`.
	"""
	return org_service.get_org_insights()


@frappe.whitelist()
def org_hierarchy(employee_id: str) -> dict:
	"""Manager chain / direct reports for one employee.

	Args:
	    employee_id: the `Employee.employee_id` value.

	Returns:
	    `{"manager_chain": [...], "direct_reports": [...]}`.
	"""
	return org_service.get_org_hierarchy(employee_id)
