import { computed, type Ref } from "vue";
import { useQuery } from "@tanstack/vue-query";
import { fetchEmployeeLogs } from "@/api/logsApi";

export interface UseEmployeeLogsParams {
  employeeId: Ref<string>;
  fromDate: Ref<string | null>;
  toDate: Ref<string | null>;
  start: Ref<number>;
  limit: Ref<number>;
}

/** ViewModel for the activity-log table (`employee_logs`). */
export function useEmployeeLogs(params: UseEmployeeLogsParams) {
  const queryKey = computed(
    () =>
      [
        "employee",
        params.employeeId.value,
        "logs",
        {
          from: params.fromDate.value,
          to: params.toDate.value,
          start: params.start.value,
          limit: params.limit.value,
        },
      ] as const,
  );

  const query = useQuery({
    queryKey,
    queryFn: () =>
      fetchEmployeeLogs({
        employeeId: params.employeeId.value,
        fromDate: params.fromDate.value,
        toDate: params.toDate.value,
        start: params.start.value,
        limit: params.limit.value,
      }),
    enabled: computed(() => Boolean(params.employeeId.value)),
    placeholderData: (previousData) => previousData,
  });

  return {
    rows: computed(() => query.data.value?.data ?? []),
    hasMore: computed(() => query.data.value?.has_more ?? false),
    isLoading: query.isPending,
    isFetching: query.isFetching,
    isError: query.isError,
    error: query.error,
  };
}
