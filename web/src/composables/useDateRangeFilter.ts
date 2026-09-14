import { ref } from "vue";

function isoDateDaysAgo(days: number): string {
  const target = new Date();
  target.setDate(target.getDate() - days);
  return target.toISOString().slice(0, 10);
}

function isoToday(): string {
  return new Date().toISOString().slice(0, 10);
}

/**
 * ViewModel for the activity-log date-range quick filter. Leaving both bounds
 * `null` (the default) means "all time" - the backend applies its own
 * trailing-30-day default only when both are omitted (docs/04_BACKEND_RULES.md
 * §9 `date_utils.resolve_date_range`); an explicit "All time" clears back to
 * that same null/null state rather than a hardcoded wide range.
 */
export function useDateRangeFilter() {
  const fromDate = ref<string | null>(null);
  const toDate = ref<string | null>(null);

  function applyLastNDays(days: number): void {
    fromDate.value = isoDateDaysAgo(days);
    toDate.value = isoToday();
  }

  function clear(): void {
    fromDate.value = null;
    toDate.value = null;
  }

  return { fromDate, toDate, applyLastNDays, clear };
}
