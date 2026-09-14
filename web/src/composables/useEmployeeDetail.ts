import { computed, type Ref, unref } from "vue";
import { useQuery } from "@tanstack/vue-query";
import { fetchEmployeeDetail } from "@/api/employeeApi";

/** ViewModel for `EmployeeDetailView` - identity, manager chain, summary metrics, trend. */
export function useEmployeeDetail(employeeId: Ref<string> | string) {
  const idRef = computed(() => unref(employeeId));

  const query = useQuery({
    queryKey: computed(() => ["employee", idRef.value, "detail"] as const),
    queryFn: () => fetchEmployeeDetail(idRef.value),
    enabled: computed(() => Boolean(idRef.value)),
  });

  return {
    detail: computed(() => query.data.value ?? null),
    isLoading: query.isPending,
    isError: query.isError,
    error: query.error,
    refetch: query.refetch,
  };
}
