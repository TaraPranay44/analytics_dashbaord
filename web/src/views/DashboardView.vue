<script setup lang="ts">
import { storeToRefs } from 'pinia'
import { useRouter } from 'vue-router'
import { useUiFilterStore } from '../store/uiFilterStore'
import { useOrgDashboard } from '../composables/useOrgDashboard'
import { useEmployeeList } from '../composables/useEmployeeList'
import EmployeeSearchBar from '../components/EmployeeSearchBar.vue'
import FilterBar from '../components/FilterBar.vue'
import EmployeeListTable from '../components/EmployeeListTable.vue'
import Pagination from '../components/Pagination.vue'
import { ROUTE_NAMES } from '../constants/routeConstants'
import { PAGE_SIZE_DEFAULT } from '../constants/apiConstants'

const router = useRouter()
const uiFilterStore = useUiFilterStore()
const { searchQuery, managerFilter, sort, page } = storeToRefs(uiFilterStore)

const { orgDashboard } = useOrgDashboard()
const { employees, hasMore, isLoading } = useEmployeeList(
  searchQuery,
  managerFilter,
  sort,
  page
)

function goToEmployee(employeeId: string) {
  router.push({ name: ROUTE_NAMES.EMPLOYEE_DETAIL, params: { employeeId } })
}
</script>

<template>
  <div class="dashboard">
    <div class="org-tiles">
      <div class="tile">
        <h3>Total Employees</h3>
        <p>{{ orgDashboard?.total_employees ?? '—' }}</p>
      </div>
      <div class="tile">
        <h3>Avg Hours (Org)</h3>
        <p>{{ orgDashboard?.avg_hours_org ?? '—' }}</p>
      </div>
      <div class="tile">
        <h3>Avg Login Time (Org)</h3>
        <p>{{ orgDashboard?.avg_login_time_org ?? '—' }}</p>
      </div>
    </div>

    <div class="controls">
      <EmployeeSearchBar v-model="searchQuery" />
      <FilterBar v-model:manager="managerFilter" v-model:sort="sort" />
    </div>

    <p v-if="isLoading">Loading...</p>
    <EmployeeListTable
      v-else
      :employees="employees"
      @row-click="goToEmployee"
    />

    <Pagination
      v-model:page="page"
      :page-size="PAGE_SIZE_DEFAULT"
      :has-more="hasMore"
    />
  </div>
</template>

<style scoped>
.dashboard {
  padding: 1.5rem;
}
.org-tiles {
  display: flex;
  gap: 1rem;
  margin-bottom: 1.5rem;
}
.tile {
  flex: 1;
  padding: 1rem;
  border-radius: 8px;
  border: 1px solid #333;
}
.tile h3 {
  font-size: 0.85rem;
  opacity: 0.7;
  margin: 0 0 0.5rem;
}
.tile p {
  font-size: 1.5rem;
  font-weight: bold;
  margin: 0;
}
.controls {
  display: flex;
  gap: 1rem;
  margin-bottom: 1rem;
}
</style>