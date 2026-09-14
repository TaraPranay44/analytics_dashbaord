import type { TrendPoint } from "@/types/employee";

export interface TrendInsights {
  /** % of days in the available trend window with any logged hours, or null if the window is empty. */
  attendanceRatePercent: number | null;
  /** How many days the trend window actually covers (mirrors `EMPLOYEE_DETAIL_TREND_DAYS`, or fewer for a new hire). */
  attendanceWindowDays: number;
  /** Percentage-point change in attendance rate, last 7 days vs. the 7 before that - null if there aren't 14 days yet. */
  attendanceChangePoints: number | null;
  /** % change in average daily hours, last 7 days vs. the 7 before that - null if there aren't 14 days yet. */
  hoursChangePercent: number | null;
}

function average(points: TrendPoint[]): number {
  return points.reduce((sum, point) => sum + point.total_hours, 0) / points.length;
}

function attendanceRate(points: TrendPoint[]): number {
  return (points.filter((point) => point.total_hours > 0).length / points.length) * 100;
}

/**
 * Derives real, honest "recent momentum" indicators from the `employee_detail`
 * trend series (daily `total_hours` - see docs/04_BACKEND_RULES.md §5) - no
 * fabricated fields, just small client-side reductions over the already-fetched,
 * bounded (≤`EMPLOYEE_DETAIL_TREND_DAYS`-row) array.
 */
export function computeTrendInsights(trend: TrendPoint[]): TrendInsights {
  const attendanceWindowDays = trend.length;
  const attendanceRatePercent = attendanceWindowDays > 0 ? attendanceRate(trend) : null;

  const last7 = trend.slice(-7);
  const prev7 = trend.slice(-14, -7);
  const hasComparisonWindow = last7.length === 7 && prev7.length === 7;

  let hoursChangePercent: number | null = null;
  let attendanceChangePoints: number | null = null;

  if (hasComparisonWindow) {
    const prevAvgHours = average(prev7);
    hoursChangePercent = prevAvgHours > 0 ? ((average(last7) - prevAvgHours) / prevAvgHours) * 100 : null;
    attendanceChangePoints = attendanceRate(last7) - attendanceRate(prev7);
  }

  return { attendanceRatePercent, attendanceWindowDays, attendanceChangePoints, hoursChangePercent };
}
