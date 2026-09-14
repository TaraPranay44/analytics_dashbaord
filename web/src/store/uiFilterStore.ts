import { defineStore } from 'pinia'

export const useUiFilterStore = defineStore('uiFilter', {
  state: () => ({
    searchQuery: '',
    managerFilter: '',
    sort: '',
    page: 1,
  }),
  actions: {
    setSearchQuery(value: string) {
      this.searchQuery = value
      this.page = 1
    },
    setManagerFilter(value: string) {
      this.managerFilter = value
      this.page = 1
    },
    setSort(value: string) {
      this.sort = value
      this.page = 1
    },
    setPage(value: number) {
      this.page = value
    },
  },
})