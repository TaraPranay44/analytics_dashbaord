/**
 * One `Employee Activity Log` row, as returned by `employee_logs`
 * (analytics_portal/api/v1/logs.py). `login_time`/`logout_time` are Frappe
 * Datetime strings ("YYYY-MM-DD HH:MM:SS"); `total_hours` is server-computed,
 * never derived client-side.
 */
export interface ActivityLogRow {
  employee: string;
  date: string;
  login_time: string | null;
  logout_time: string | null;
  total_hours: number | null;
}
