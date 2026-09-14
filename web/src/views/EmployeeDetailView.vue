<script setup lang="ts">
import { computed, ref, watch } from "vue";
import { useRoute, useRouter } from "vue-router";
import { useEmployeeDetail } from "@/composables/useEmployeeDetail";
import { useEmployeeLogs } from "@/composables/useEmployeeLogs";
import { useOrgHierarchy } from "@/composables/useOrgHierarchy";
import { useDateRangeFilter } from "@/composables/useDateRangeFilter";
import EmployeeSummaryPanel from "@/components/EmployeeSummaryPanel.vue";
import EmployeeTrendChart from "@/components/EmployeeTrendChart.vue";
import ActivityLogTable from "@/components/ActivityLogTable.vue";
import DateRangeFilter from "@/components/DateRangeFilter.vue";
import OrgHierarchyView from "@/components/OrgHierarchyView.vue";
import Pagination from "@/components/Pagination.vue";
import { PAGE_SIZE_DEFAULT } from "@/constants/apiConstants";
import { ROUTE_PATHS } from "@/constants/routeConstants";
import { STRINGS } from "@/constants/stringConstants";
import { avatarGradientFor, initialsFor } from "@/utils/avatar";

const route = useRoute();
const router = useRouter();
const employeeId = computed(() => String(route.params.employeeId ?? ""));

const { detail, isLoading: detailLoading, isError: detailError } = useEmployeeDetail(employeeId);
const { managerChain, directReports, isLoading: hierarchyLoading } = useOrgHierarchy(employeeId);
const { fromDate, toDate, applyLastNDays, clear } = useDateRangeFilter();

const logsStart = ref(0);
const logsLimit = ref(PAGE_SIZE_DEFAULT);
watch(employeeId, () => {
  logsStart.value = 0;
});
watch([fromDate, toDate], () => {
  logsStart.value = 0;
});

const {
  rows: logRows,
  hasMore: logsHasMore,
  isLoading: logsLoading,
  isFetching: logsFetching,
} = useEmployeeLogs({
  employeeId,
  fromDate,
  toDate,
  start: logsStart,
  limit: logsLimit,
});

function goBack(): void {
  router.push(ROUTE_PATHS.dashboard);
}
function nextLogsPage(): void {
  if (logsHasMore.value) logsStart.value += logsLimit.value;
}
function prevLogsPage(): void {
  logsStart.value = Math.max(0, logsStart.value - logsLimit.value);
}
</script>

<template>
  <div class="app-shell">
    <nav class="sidebar">
      <div class="sidebar-logo"><div class="logo-mark"></div><span>Analytics</span></div>
      <button class="nav-item"><span class="dot"></span>Dashboard</button>
    </nav>

    <main class="main">
      <div class="topbar">
        <span class="breadcrumb">Executive Dashboard</span>
      </div>

      <div class="body-content">
        <div class="detail-header">
          <button class="back-chip" type="button" @click="goBack">←</button>
          <div v-if="detail" class="detail-avatar" :style="{ background: avatarGradientFor(detail.employee_id) }">
            <span class="avatar-initials">{{ initialsFor(detail.employee_name) }}</span>
          </div>
          <div v-if="detail">
            <div class="detail-title-row">
              <h1>{{ detail.employee_name }}</h1>
              <span class="id-tag">{{ detail.employee_id }}</span>
            </div>
            <p v-if="detail.date_of_joining" class="detail-sub">Joined {{ detail.date_of_joining }}</p>
          </div>
          <div v-else-if="detailLoading">
            <h1>{{ STRINGS.loadingLabel }}</h1>
          </div>
        </div>

        <div v-if="detailError" class="card emp-table-status">{{ STRINGS.employeeNotFound }}</div>

        <template v-else>
          <div class="detail-grid">
            <div class="flex-col gap-md">
              <div v-if="detail" class="card profile-id-card">
                <div class="detail-list">
                  <div class="row"><span class="k">Employee ID</span><span class="v">{{ detail.employee_id }}</span></div>
                  <div v-if="detail.date_of_joining" class="row">
                    <span class="k">Joined</span><span class="v">{{ detail.date_of_joining }}</span>
                  </div>
                </div>
              </div>
              <OrgHierarchyView
                :manager-chain="managerChain"
                :direct-reports="directReports"
                :loading="hierarchyLoading"
              />
            </div>

            <div class="flex-col gap-lg" v-if="detail">
              <EmployeeSummaryPanel :detail="detail" />
              <EmployeeTrendChart :trend="detail.trend" :employee-id="detail.employee_id" />
            </div>
            <div v-else class="card emp-table-status">{{ STRINGS.loadingLabel }}</div>
          </div>

          <div v-if="detail" class="flex-col gap-md">
            <DateRangeFilter
              :from-date="fromDate"
              :to-date="toDate"
              @apply-last-n-days="applyLastNDays"
              @clear="clear"
            />
            <ActivityLogTable :rows="logRows" :loading="logsLoading" />
            <Pagination
              :start="logsStart"
              :limit="logsLimit"
              :row-count="logRows.length"
              :has-more="logsHasMore"
              :loading="logsFetching"
              @prev="prevLogsPage"
              @next="nextLogsPage"
            />
          </div>
        </template>
      </div>
    </main>
  </div>
</template>
