import { useQuery } from '@tanstack/vue-query'
import { fetchEmployeeDetail } from '../api/employeeApi'
import type { Ref } from 'vue'

export function useEmployeeDetail(employeeId: Ref<string>) {
  const query = useQuery({
    queryKey: ['employee', 'detail', employeeId],
    queryFn: () => fetchEmployeeDetail(employeeId.value),
    enabled: () => !!employeeId.value,
  })

  return {
    employee: query.data,
    isLoading: query.isLoading,
    isError: query.isError,
    error: query.error,
  }
}