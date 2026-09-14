import type { HeadcountTrendPoint, OrgDailyStatsPoint } from "@/types/employee";

export interface OrgTrendInsights {
  /** % change in `avg_hours_org`, last 7 days vs. the 7 before that - null if there aren't 14 days yet. */
  avgHoursChangePercent: number | null;
  /** Minutes later (positive) or earlier (negative) `avg_login_time_org` shifted, last 7 vs. prior 7 days. */
  avgLoginMinutesDelta: number | null;
}

function timeToMinutes(time: string): number {
  const [hoursPart, minutesPart] = time.split(":");
  return Number(hoursPart) * 60 + Number(minutesPart ?? 0);
}

function average(values: number[]): number {
  return values.reduce((sum, value) => sum + value, 0) / values.length;
}

/**
 * Derives real "recent momentum" indicators from `org_dashboard`'s embedded
 * `history` (see docs/04_BACKEND_RULES.md §5) - small client-side reductions
 * over an already-fetched, bounded (`ORG_DASHBOARD_HISTORY_DAYS`-row) array,
 * the same pattern as `trendInsights.ts` for the employee detail page.
 */
export function computeOrgTrendInsights(history: OrgDailyStatsPoint[]): OrgTrendInsights {
  const last7 = history.slice(-7);
  const prev7 = history.slice(-14, -7);
  if (last7.length !== 7 || prev7.length !== 7) {
    return { avgHoursChangePercent: null, avgLoginMinutesDelta: null };
  }

  const prevAvgHours = average(prev7.map((point) => point.avg_hours_org));
  const avgHoursChangePercent = prevAvgHours > 0 ? ((average(last7.map((p) => p.avg_hours_org)) - prevAvgHours) / prevAvgHours) * 100 : null;

  const loginPoints = (points: OrgDailyStatsPoint[]) =>
    points.map((point) => point.avg_login_time_org).filter((time): time is string => Boolean(time));
  const last7Login = loginPoints(last7);
  const prev7Login = loginPoints(prev7);
  const avgLoginMinutesDelta =
    last7Login.length && prev7Login.length
      ? average(last7Login.map(timeToMinutes)) - average(prev7Login.map(timeToMinutes))
      : null;

  return { avgHoursChangePercent, avgLoginMinutesDelta };
}

/** `history`'s `avg_login_time_org` per day, as minutes-since-midnight - for the login-time sparkline. */
export function loginTimeSparkline(history: OrgDailyStatsPoint[]): number[] {
  return history
    .map((point) => point.avg_login_time_org)
    .filter((time): time is string => Boolean(time))
    .map(timeToMinutes);
}

/** `headcount_trend`'s `cumulative_headcount` per month - for the "employees tracked" sparkline. */
export function headcountSparkline(trend: HeadcountTrendPoint[]): number[] {
  return trend.map((point) => point.cumulative_headcount);
}
