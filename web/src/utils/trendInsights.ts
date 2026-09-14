import type { TrendPoint } from "@/types/employee";

export interface TrendInsights {
  /** % change in average daily hours, last 7 days vs. the 7 before that - null if there aren't 14 days yet. */
  hoursChangePercent: number | null;
}

function average(points: TrendPoint[]): number {
  return points.reduce((sum, point) => sum + point.total_hours, 0) / points.length;
}

/**
 * Derives a real, honest "recent momentum" indicator from the `employee_detail`
 * trend series (daily `total_hours` - see docs/04_BACKEND_RULES.md §5) - no
 * fabricated fields, just a small client-side reduction over the already-fetched,
 * bounded (≤`EMPLOYEE_DETAIL_TREND_DAYS`-row) array. No attendance-rate field
 * here - see docs/05_FRONTEND_WEB_RULES.md §9a: `EmployeeSummaryPanel` is
 * deliberately 3 tiles, not 4, since there's no backend field for it.
 */
export function computeTrendInsights(trend: TrendPoint[]): TrendInsights {
  const last7 = trend.slice(-7);
  const prev7 = trend.slice(-14, -7);
  const hasComparisonWindow = last7.length === 7 && prev7.length === 7;

  let hoursChangePercent: number | null = null;

  if (hasComparisonWindow) {
    const prevAvgHours = average(prev7);
    hoursChangePercent = prevAvgHours > 0 ? ((average(last7) - prevAvgHours) / prevAvgHours) * 100 : null;
  }

  return { hoursChangePercent };
}
