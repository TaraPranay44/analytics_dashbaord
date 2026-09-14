import { computed, type Ref } from "vue";
import { useQuery } from "@tanstack/vue-query";
import { fetchEmployeeList } from "@/api/employeeApi";

export interface UseEmployeeListParams {
  q: Ref<string>;
  manager: Ref<string | null>;
  sort: Ref<string | null>;
  start: Ref<number>;
  limit: Ref<number>;
  /** Defaults to always-on. Pass a ref for callers that should only fetch
   * once active (e.g. a combobox that shouldn't query before it's opened). */
  enabled?: Ref<boolean>;
}

/**
 * ViewModel for the landing employee directory (`employee_list`). Also
 * reused by `ManagerFilterCombobox` to search/browse employees for the
 * manager filter - same endpoint, same pagination/search semantics, just a
 * smaller `limit` and its own `enabled` gate.
 */
export function useEmployeeList(params: UseEmployeeListParams) {
  const queryKey = computed(
    () =>
      [
        "employee",
        "list",
        {
          q: params.q.value,
          manager: params.manager.value,
          sort: params.sort.value,
          start: params.start.value,
          limit: params.limit.value,
        },
      ] as const,
  );

  const query = useQuery({
    queryKey,
    queryFn: () =>
      fetchEmployeeList({
        q: params.q.value,
        manager: params.manager.value,
        sort: params.sort.value,
        start: params.start.value,
        limit: params.limit.value,
      }),
    enabled: params.enabled ?? true,
    placeholderData: (previousData) => previousData,
  });

  return {
    rows: computed(() => query.data.value?.data ?? []),
    hasMore: computed(() => query.data.value?.has_more ?? false),
    isLoading: query.isPending,
    isFetching: query.isFetching,
    isError: query.isError,
    error: query.error,
    refetch: query.refetch,
  };
}
