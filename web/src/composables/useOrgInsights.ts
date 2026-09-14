import { computed } from "vue";
import { useQuery } from "@tanstack/vue-query";
import { fetchOrgInsights } from "@/api/orgApi";

/** ViewModel for the dashboard's insight chips (`org_insights`). */
export function useOrgInsights() {
  const query = useQuery({
    queryKey: ["org", "insights"] as const,
    queryFn: fetchOrgInsights,
  });

  return {
    insights: computed(() => query.data.value ?? null),
    isLoading: query.isPending,
    isError: query.isError,
  };
}
