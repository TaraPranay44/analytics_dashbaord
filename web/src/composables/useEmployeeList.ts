import { computed, type Ref } from 'vue'
import { useQuery } from '@tanstack/vue-query'
import { fetchEmployeeList } from '../api/employeeApi'
import { PAGE_SIZE_DEFAULT } from '../constants/apiConstants'

export function useEmployeeList(
  q: Ref<string>,
  manager: Ref<string>,
  sort: Ref<string>,
  page: Ref<number>
) {
  const start = computed(() => (page.value - 1) * PAGE_SIZE_DEFAULT)

  const query = useQuery({
    queryKey: ['employee', 'list', { q, manager, sort, start }],
    queryFn: () =>
      fetchEmployeeList({
        q: q.value || undefined,
        manager: manager.value || undefined,
        sort: sort.value || undefined,
        start: start.value,
        limit: PAGE_SIZE_DEFAULT,
      }),
  })

  return {
    employees: computed(() => query.data.value?.data ?? []),
    hasMore: computed(() => query.data.value?.has_more ?? false),
    isLoading: query.isLoading,
    isError: query.isError,
    error: query.error,
  }
}