// docs/07_DESK_UI_ROLE_ACCESS_PLAN.md: bare /desk cannot be redirected via
// hooks.py alone — Frappe's PathResolver hardcodes any path starting with
// "desk" to render the Desk shell directly, bypassing website_redirects and
// every other routing hook (frappe/website/path_resolver.py, "Hardcoded for
// better performance"). This runs client-side instead, once the Desk shell
// has booted, using the same frappe.boot.user.default_workspace that
// get_home_page() uses for the login-time redirect.
(function () {
	if (!frappe.boot || !frappe.boot.user || !frappe.boot.user.default_workspace) {
		return;
	}

	var path = window.location.pathname.replace(/\/+$/, "");
	if (path !== "/desk") {
		return;
	}

	var workspace = frappe.boot.user.default_workspace;
	var prefix = workspace.public ? "/desk/" : "/desk/private/";
	var slug = workspace.name.toLowerCase().replace(/ /g, "-");
	window.location.replace(prefix + slug);
})();
