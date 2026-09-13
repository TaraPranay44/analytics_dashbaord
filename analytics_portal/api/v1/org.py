"""Whitelisted API endpoints: org_dashboard, org_hierarchy.

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
def org_hierarchy(employee_id: str) -> dict:
	"""Manager chain / direct reports for one employee.

	Args:
	    employee_id: the `Employee.employee_id` value.

	Returns:
	    `{"manager_chain": [...], "direct_reports": [...]}`.
	"""
	return org_service.get_org_hierarchy(employee_id)
