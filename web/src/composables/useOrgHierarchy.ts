import { useQuery } from '@tanstack/vue-query'
import { fetchOrgHierarchy } from '../api/orgApi'
import type { Ref } from 'vue'

export function useOrgHierarchy(employeeId: Ref<string>) {
  const query = useQuery({
    queryKey: ['org', 'hierarchy', employeeId],
    queryFn: () => fetchOrgHierarchy(employeeId.value),
    enabled: () => !!employeeId.value,
  })

  return {
    hierarchy: query.data,
    isLoading: query.isLoading,
    isError: query.isError,
    error: query.error,
  }
}