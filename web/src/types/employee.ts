/**
 * Response shapes for the `employee_*` and `org_*` endpoints
 * (docs/04_BACKEND_RULES.md §5). Field lists here are intentionally narrow -
 * they mirror exactly what the backend returns today. Do not add fields that
 * aren't actually in the API response (e.g. department/location/status/email
 * do not exist on the `Employee` DocType).
 */

/** One compact row from `employee_list` - the landing directory table. */
export interface EmployeeListRow {
  employee_id: string;
  employee_name: string;
  manager: string | null;
  manager_name: string | null;
  avg_hours_overall: number | null;
  avg_login_time_overall: string | null;
}

export interface ManagerChainEntry {
  employee_id: string;
  employee_name: string;
}

export interface DirectReport {
  employee_id: string;
  employee_name: string;
}

/** One point of the `employee_detail` trend series - raw recent daily hours. */
export interface TrendPoint {
  date: string;
  total_hours: number;
}

/** One point of the `employee_monthly_trend` series - lifetime monthly averages. */
export interface MonthlyTrendPoint {
  year_month: string;
  avg_hours: number;
}

/** Full shape returned by `employee_detail`. */
export interface EmployeeDetail {
  employee_id: string;
  employee_name: string;
  date_of_joining: string | null;
  manager: string | null;
  manager_chain: ManagerChainEntry[];
  avg_hours_overall: number;
  avg_login_time_overall: string | null;
  avg_logout_time_overall: string | null;
  trend: TrendPoint[];
}

/** One point of `org_dashboard`'s embedded `history` - a day's `Org Daily Stats` row. */
export interface OrgDailyStatsPoint {
  date: string;
  total_employees: number;
  avg_hours_org: number;
  avg_login_time_org: string | null;
}

/** One point of `org_dashboard`'s embedded `headcount_trend` - a month's registered headcount. */
export interface HeadcountTrendPoint {
  year_month: string;
  cumulative_headcount: number;
}

/** Shape returned by `org_dashboard`. */
export interface OrgDashboard {
  date: string | null;
  total_employees: number;
  avg_hours_org: number;
  avg_login_time_org: string | null;
  /** Trailing `ORG_DASHBOARD_HISTORY_DAYS`-day history, oldest first, for sparklines/trend badges. */
  history: OrgDailyStatsPoint[];
  /** Trailing `HEADCOUNT_TREND_MONTHS`-month registered-headcount snapshots, oldest first. */
  headcount_trend: HeadcountTrendPoint[];
}

/** Shape returned by `org_insights`. */
export interface OrgInsights {
  manager_count: number;
  total_registered_employees: number;
  total_registered_employees_growth_window_start: number;
  headcount_growth_window_days: number;
  low_hours_threshold: number;
  low_hours_employee_count: number;
  recent_hires_count: number;
  recent_hires_window_days: number;
}

/** Shape returned by `org_hierarchy`. */
export interface OrgHierarchy {
  manager_chain: ManagerChainEntry[];
  direct_reports: DirectReport[];
}
