import { useQuery } from '@tanstack/vue-query'
import { fetchOrgDashboard } from '../api/orgApi'

export function useOrgDashboard() {
  const query = useQuery({
    queryKey: ['org', 'dashboard'],
    queryFn: fetchOrgDashboard,
  })

  return {
    orgDashboard: query.data,
    isLoading: query.isLoading,
    isError: query.isError,
    error: query.error,
  }
}