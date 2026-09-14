import { computed } from "vue";
import { useQuery } from "@tanstack/vue-query";
import { fetchOrgDashboard } from "@/api/orgApi";

/** ViewModel for the org-wide dashboard tiles (`org_dashboard`). */
export function useOrgDashboard() {
  const query = useQuery({
    queryKey: ["org", "dashboard"] as const,
    queryFn: fetchOrgDashboard,
  });

  return {
    dashboard: computed(() => query.data.value ?? null),
    isLoading: query.isPending,
    isError: query.isError,
    error: query.error,
  };
}
