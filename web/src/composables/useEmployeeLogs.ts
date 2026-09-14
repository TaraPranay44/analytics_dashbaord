import { computed, type Ref } from 'vue'
import { useQuery } from '@tanstack/vue-query'
import { fetchEmployeeLogs } from '../api/logsApi'
import { PAGE_SIZE_DEFAULT } from '../constants/apiConstants'

export function useEmployeeLogs(
  employeeId: Ref<string>,
  fromDate: Ref<string>,
  toDate: Ref<string>,
  page: Ref<number>
) {
  const start = computed(() => (page.value - 1) * PAGE_SIZE_DEFAULT)

  const query = useQuery({
    queryKey: ['employee', employeeId, 'logs', { fromDate, toDate, start }],
    queryFn: () =>
      fetchEmployeeLogs({
        employee_id: employeeId.value,
        from_date: fromDate.value || undefined,
        to_date: toDate.value || undefined,
        start: start.value,
        limit: PAGE_SIZE_DEFAULT,
      }),
    enabled: () => !!employeeId.value,
  })

  return {
    logs: computed(() => query.data.value?.data ?? []),
    hasMore: computed(() => query.data.value?.has_more ?? false),
    isLoading: query.isLoading,
    isError: query.isError,
    error: query.error,
  }
}
