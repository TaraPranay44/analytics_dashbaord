# Copyright (c) 2026, EMPLOYEE ANALYTICS PORTAL and Contributors
# See license.txt

"""Website route handler for the Vue3 frontend (docs/05_FRONTEND_WEB_RULES.md).

Serves the built SPA (analytics_portal/public/frontend, copied to
analytics-portal.html by `web/`'s build script) and supplies the boot data
(csrf token, etc.) the frontend needs for authenticated API calls.
"""

import frappe
from frappe import _

no_cache = 1

# The Frappe roles that map to a portal persona - see
# docs/07_DESK_UI_ROLE_ACCESS_PLAN.md §2. First match wins if a user
# somehow holds more than one (shouldn't normally happen).
PORTAL_ROLES = ("CEO", "Manager", "Employee")


def get_context():
	if frappe.session.user == "Guest":
		frappe.throw(_("Please log in to access the Analytics Portal"), frappe.PermissionError)

	frappe.db.commit()
	context = frappe._dict()
	context.boot = get_boot()
	return context


@frappe.whitelist(methods=["POST"], allow_guest=True)
def get_context_for_dev():
	"""Dev-only boot data fetch - the Vite dev server can't run Jinja, so
	`web/src/main.ts` fetches these globals directly on startup instead.
	"""
	if not frappe.conf.developer_mode:
		frappe.throw(_("This method is only meant for developer mode"))
	return get_boot()


def get_boot():
	user_roles = frappe.get_roles()
	portal_role = next((role for role in PORTAL_ROLES if role in user_roles), None)

	return frappe._dict(
		{
			"csrf_token": frappe.sessions.get_csrf_token(),
			"frappe_version": frappe.__version__,
			"site_name": frappe.local.site,
			# The real Frappe role driving this login, if any - lets the
			# frontend skip the manual role-picker for actual CEO/Manager/
			# Employee accounts instead of making them click their own role
			# after Frappe already authenticated them as it.
			"portal_role": portal_role,
		}
	)
