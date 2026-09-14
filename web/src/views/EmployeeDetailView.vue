<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRoute } from 'vue-router'
import { useEmployeeDetail } from '../composables/useEmployeeDetail'
import { useEmployeeLogs } from '../composables/useEmployeeLogs'
import { useDateRangeFilter } from '../composables/useDateRangeFilter'
import { PAGE_SIZE_DEFAULT } from '../constants/apiConstants'
import EmployeeSummaryPanel from '../components/EmployeeSummaryPanel.vue'
import EmployeeTrendChart from '../components/EmployeeTrendChart.vue'
import ActivityLogTable from '../components/ActivityLogTable.vue'
import DateRangeFilter from '../components/DateRangeFilter.vue'
import Pagination from '../components/Pagination.vue'

const route = useRoute()

const employeeId = computed(() => String(route.params.employeeId))

const dateRange = useDateRangeFilter()

const { employee, isLoading: isDetailLoading, isError: isDetailError } =
  useEmployeeDetail(employeeId)

const logsPage = ref(1)

const {
  logs,
  hasMore,
  isLoading: isLogsLoading,
} = useEmployeeLogs(employeeId, dateRange.fromDate, dateRange.toDate, logsPage)
</script>

<template>
  <div class="employee-detail-view">
    <button type="button" class="back-link" @click="$router.back()">
      ← Back to employees
    </button>

    <div v-if="isDetailLoading" class="state-message">Loading employee…</div>
    <div v-else-if="isDetailError" class="state-message state-message--error">
      Couldn't load this employee.
    </div>

    <template v-else-if="employee">
      <EmployeeSummaryPanel :employee="employee" />

      <EmployeeTrendChart :trend="employee.trend" />

      <section class="logs-section">
        <div class="logs-section__header">
          <h3>Activity log</h3>
          <DateRangeFilter
            :preset="dateRange.preset.value"
            :custom-from="dateRange.customFrom.value"
            :custom-to="dateRange.customTo.value"
            @update:preset="dateRange.preset.value = $event"
            @update:custom-from="dateRange.customFrom.value = $event"
            @update:custom-to="dateRange.customTo.value = $event"
          />
        </div>

        <div v-if="isLogsLoading" class="state-message">Loading logs…</div>
        <ActivityLogTable v-else :logs="logs" />

        <Pagination
          :page="logsPage"
          :page-size="PAGE_SIZE_DEFAULT"
          :has-more="hasMore"
          @update:page="logsPage = $event"
        />
      </section>
    </template>
  </div>
</template>

<style scoped>
.employee-detail-view {
  display: flex;
  flex-direction: column;
  gap: 20px;
  padding: 20px;
  font-family: 'Inter', ui-sans-serif, system-ui, sans-serif;
}

.back-link {
  align-self: flex-start;
  background: none;
  border: none;
  color: #3b5bdb;
  font-size: 13px;
  cursor: pointer;
  padding: 0;
}

.state-message {
  padding: 24px 0;
  text-align: center;
  color: #6b7280;
  font-size: 13px;
}

.state-message--error {
  color: #c0392b;
}

.logs-section {
  border: 1px solid #e2e5eb;
  border-radius: 6px;
  background: #ffffff;
  padding: 20px 24px;
}

.logs-section__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 12px;
  margin-bottom: 16px;
}

.logs-section__header h3 {
  margin: 0;
  font-size: 15px;
  font-weight: 600;
}
</style>