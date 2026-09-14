/// <reference types="vite/client" />

// Boot globals injected by frappe-ui's jinjaBootData plugin in production
// (via www/analytics-portal.html's Jinja template) and by the dev-mode
// `get_context_for_dev` fetch in main.ts - see docs/05_FRONTEND_WEB_RULES.md.
interface Window {
  csrf_token?: string;
  frappe_version?: string;
  site_name?: string;
  /** The real Frappe role driving this login ("CEO"/"Manager"/"Employee"), or null/undefined. */
  portal_role?: string | null;
}
