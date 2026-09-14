import { computed, type Ref, unref } from "vue";
import { useQuery } from "@tanstack/vue-query";
import { fetchOrgHierarchy } from "@/api/orgApi";

/**
 * ViewModel for `OrgHierarchyView` - manager chain and direct reports
 * (`org_hierarchy`). Added alongside `OrgHierarchyView.vue` in this change;
 * see docs/05_FRONTEND_WEB_RULES.md §6 for the corresponding file-tree entry.
 */
export function useOrgHierarchy(employeeId: Ref<string> | string) {
  const idRef = computed(() => unref(employeeId));

  const query = useQuery({
    queryKey: computed(() => ["employee", idRef.value, "org-hierarchy"] as const),
    queryFn: () => fetchOrgHierarchy(idRef.value),
    enabled: computed(() => Boolean(idRef.value)),
  });

  return {
    managerChain: computed(() => query.data.value?.manager_chain ?? []),
    directReports: computed(() => query.data.value?.direct_reports ?? []),
    isLoading: query.isPending,
    isError: query.isError,
  };
}
