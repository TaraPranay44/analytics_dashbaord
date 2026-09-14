/**
 * Whitelisted endpoint paths - must match docs/04_BACKEND_RULES.md §5 and
 * analytics_portal/api/v1/*.py exactly. No literal endpoint path may appear
 * inline in api/ or composables/ code - see docs/05_FRONTEND_WEB_RULES.md §7.
 */
export const API_METHODS = {
  employeeList: "analytics_portal.api.v1.employee.employee_list",
  employeeDetail: "analytics_portal.api.v1.employee.employee_detail",
  employeeMonthlyTrend: "analytics_portal.api.v1.employee.employee_monthly_trend",
  employeeLogs: "analytics_portal.api.v1.logs.employee_logs",
  orgDashboard: "analytics_portal.api.v1.org.org_dashboard",
  orgInsights: "analytics_portal.api.v1.org.org_insights",
  orgHierarchy: "analytics_portal.api.v1.org.org_hierarchy",
} as const;

// Mirrors analytics_portal/constants/api_constants.py - keep in sync.
export const PAGE_SIZE_DEFAULT = 20;
export const PAGE_SIZE_MAX = 100;

// Search-as-you-type debounce - docs/05_FRONTEND_WEB_RULES.md §5 ("≥300ms").
export const SEARCH_DEBOUNCE_MS = 300;
