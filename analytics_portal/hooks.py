app_name = "analytics_portal"
app_title = "EMPLOYEE ANALYTICS PORTAL"
app_publisher = "EMPLOYEE ANALYTICS PORTAL"
app_description = "EMPLOYEE ANALYTICS PORTAL"
app_email = "tara@yopmail.com"
app_license = "mit"

# Apps
# ------------------

# required_apps = []

# Each item in the list will be shown as an app in the apps page
# add_to_apps_screen = [
# 	{
# 		"name": "analytics_portal",
# 		"logo": "/assets/analytics_portal/logo.png",
# 		"title": "EMPLOYEE ANALYTICS PORTAL",
# 		"route": "/analytics_portal",
# 		"has_permission": "analytics_portal.api.permission.has_app_permission"
# 	}
# ]

# Includes in <head>
# ------------------

# include js, css files in header of desk.html
# app_include_css = "/assets/analytics_portal/css/analytics_portal.css"
#
# Bare /desk cannot be redirected via hooks.py alone: Frappe's PathResolver
# hardcodes any path starting with "desk" straight to the Desk template,
# bypassing website_redirects and every other routing hook entirely
# (frappe/website/path_resolver.py: "Hardcoded for better performance").
# role_home_page (below) + User.default_workspace already cover the
# login-time redirect; this JS covers someone landing on bare /desk
# mid-session by reading that same frappe.boot.user.default_workspace.
app_include_js = "/assets/analytics_portal/js/desk_default_workspace_redirect.js"

# include js, css files in header of web template
# web_include_css = "/assets/analytics_portal/css/analytics_portal.css"
# web_include_js = "/assets/analytics_portal/js/analytics_portal.js"

# include custom scss in every website theme (without file extension ".scss")
# website_theme_scss = "analytics_portal/public/scss/website"

# include js, css files in header of web form
# webform_include_js = {"doctype": "public/js/doctype.js"}
# webform_include_css = {"doctype": "public/css/doctype.css"}

# include js in page
# page_js = {"page" : "public/js/file.js"}

# include js in doctype views
# doctype_js = {"doctype" : "public/js/doctype.js"}
# doctype_list_js = {"doctype" : "public/js/doctype_list.js"}
# doctype_tree_js = {"doctype" : "public/js/doctype_tree.js"}
# doctype_calendar_js = {"doctype" : "public/js/doctype_calendar.js"}

# Svg Icons
# ------------------
# include app icons in desk
# app_include_icons = "analytics_portal/public/icons.svg"

# Home Pages
# ----------

# application home page (will override Website Settings)
# home_page = "login"

# Website Routes
# --------------
# Vue3 frontend (docs/05_FRONTEND_WEB_RULES.md) - built to
# analytics_portal/public/frontend and served via analytics_portal/www.
website_route_rules = [
	{"from_route": "/analytics-portal/<path:app_path>", "to_route": "analytics-portal"},
]

# website user home page (by Role)
# Data Admin (docs/07_DESK_UI_ROLE_ACCESS_PLAN.md): land straight on the
# scoped "Employee Analytics Portal" workspace instead of Desk's default
# empty landing page.
role_home_page = {
	"Data Admin": "desk/employee-analytics-portal",
}

# Fixtures
# --------
# Ship the Data Admin role and its Custom DocPerm grants (on core doctypes
# this app doesn't own, e.g. Scheduled Job Log / RQ Job / Error Log) as
# version-controlled fixtures rather than manual Desk edits, per
# docs/07_DESK_UI_ROLE_ACCESS_PLAN.md. Run `bench export-fixtures` after
# granting these in Desk to regenerate the JSON under fixtures/.
fixtures = [
	{"dt": "Role", "filters": [["name", "=", "Data Admin"]]},
	{"dt": "Custom DocPerm", "filters": [["role", "=", "Data Admin"]]},
]

# Generators
# ----------

# automatically create page for each record of this doctype
# website_generators = ["Web Page"]

# automatically load and sync documents of this doctype from downstream apps
# importable_doctypes = [doctype_1]

# Jinja
# ----------

# add methods and filters to jinja environment
# jinja = {
# 	"methods": "analytics_portal.utils.jinja_methods",
# 	"filters": "analytics_portal.utils.jinja_filters"
# }

# Installation
# ------------

# before_install = "analytics_portal.install.before_install"
# after_install = "analytics_portal.install.after_install"

# Uninstallation
# ------------

# before_uninstall = "analytics_portal.uninstall.before_uninstall"
# after_uninstall = "analytics_portal.uninstall.after_uninstall"

# Integration Setup
# ------------------
# To set up dependencies/integrations with other apps
# Name of the app being installed is passed as an argument

# before_app_install = "analytics_portal.utils.before_app_install"
# after_app_install = "analytics_portal.utils.after_app_install"

# Integration Cleanup
# -------------------
# To clean up dependencies/integrations with other apps
# Name of the app being uninstalled is passed as an argument

# before_app_uninstall = "analytics_portal.utils.before_app_uninstall"
# after_app_uninstall = "analytics_portal.utils.after_app_uninstall"

# Build
# ------------------
# To hook into the build process

# after_build = "analytics_portal.build.after_build"

# Desk Notifications
# ------------------
# See frappe.core.notifications.get_notification_config

# notification_config = "analytics_portal.notifications.get_notification_config"

# Awesome Bar
# -----------
# Extra search results: list of dicts with label, description, route, index.
# route: ["List", "ToDo"], "/desk/docs/some/page", or "https://example.com"
# awesomebar_search = ["analytics_portal.search.awesomebar_results"]

# Permissions
# -----------
# Permissions evaluated in scripted ways

# permission_query_conditions = {
# 	"Event": "frappe.desk.doctype.event.event.get_permission_query_conditions",
# }
#
# has_permission = {
# 	"Event": "frappe.desk.doctype.event.event.has_permission",
# }

# Document Events
# ---------------
# Hook on document methods and events

# doc_events = {
# 	"*": {
# 		"on_update": "method",
# 		"on_cancel": "method",
# 		"on_trash": "method"
# 	}
# }

# Scheduled Tasks
# ---------------
# See docs/04_BACKEND_RULES.md §8. Each cron entry below calls a thin
# `enqueue_*` function that pushes the real job onto the "long" queue —
# never the default queue interactive requests share.

scheduler_events = {
	"cron": {
		"0 1 * * *": [
			"analytics_portal.jobs.recompute_monthly_stats.enqueue_recompute_monthly_stats",
		],
		"30 1 * * *": [
			"analytics_portal.jobs.recompute_overall_stats.enqueue_recompute_overall_stats",
		],
		"0 2 * * *": [
			"analytics_portal.jobs.recompute_org_daily_stats.enqueue_recompute_org_daily_stats",
		],
	},
}

# Testing
# -------

# before_tests = "analytics_portal.install.before_tests"

# Extend DocType Class
# ------------------------------
#
# Specify custom mixins to extend the standard doctype controller.
# extend_doctype_class = {
# 	"Task": "analytics_portal.custom.task.CustomTaskMixin"
# }

# Overriding Methods
# ------------------------------
#
# override_whitelisted_methods = {
# 	"frappe.desk.doctype.event.event.get_events": "analytics_portal.event.get_events"
# }
#
# each overriding function accepts a `data` argument;
# generated from the base implementation of the doctype dashboard,
# along with any modifications made in other Frappe apps
# override_doctype_dashboards = {
# 	"Task": "analytics_portal.task.get_dashboard_data"
# }

# exempt linked doctypes from being automatically cancelled
#
# auto_cancel_exempted_doctypes = ["Auto Repeat"]

# Ignore links to specified DocTypes when deleting documents
# -----------------------------------------------------------

# ignore_links_on_delete = ["Communication", "ToDo"]

# Request Events
# ----------------
# before_request = ["analytics_portal.utils.before_request"]
# after_request = ["analytics_portal.utils.after_request"]

# Job Events
# ----------
# before_job = ["analytics_portal.utils.before_job"]
# after_job = ["analytics_portal.utils.after_job"]

# User Data Protection
# --------------------

# user_data_fields = [
# 	{
# 		"doctype": "{doctype_1}",
# 		"filter_by": "{filter_by}",
# 		"redact_fields": ["{field_1}", "{field_2}"],
# 		"partial": 1,
# 	},
# 	{
# 		"doctype": "{doctype_2}",
# 		"filter_by": "{filter_by}",
# 		"partial": 1,
# 	},
# 	{
# 		"doctype": "{doctype_3}",
# 		"strict": False,
# 	},
# 	{
# 		"doctype": "{doctype_4}"
# 	}
# ]

# Authentication and authorization
# --------------------------------

# auth_hooks = [
# 	"analytics_portal.auth.validate"
# ]

# Automatically update python controller files with type annotations for this app.
# export_python_type_annotations = True

# default_log_clearing_doctypes = {
# 	"Logging DocType Name": 30  # days to retain logs
# }

# Translation
# ------------
# List of apps whose translatable strings should be excluded from this app's translations.
# ignore_translatable_strings_from = []
