import { computed, type Ref, unref } from "vue";
import { useQuery } from "@tanstack/vue-query";
import { fetchEmployeeMonthlyTrend } from "@/api/employeeApi";

/**
 * ViewModel for the "Lifetime" view of `EmployeeTrendChart` (`employee_monthly_trend`).
 * Takes an `enabled` ref so it only fetches once the user actually switches to
 * that view - the daily trend already covers the default 7/30-day views.
 */
export function useEmployeeMonthlyTrend(employeeId: Ref<string> | string, enabled: Ref<boolean>) {
  const idRef = computed(() => unref(employeeId));

  const query = useQuery({
    queryKey: computed(() => ["employee", idRef.value, "monthly-trend"] as const),
    queryFn: () => fetchEmployeeMonthlyTrend(idRef.value),
    enabled: computed(() => Boolean(idRef.value) && enabled.value),
  });

  return {
    months: computed(() => query.data.value ?? []),
    isLoading: query.isPending,
    isFetching: query.isFetching,
    isError: query.isError,
  };
}
