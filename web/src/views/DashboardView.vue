<script setup lang="ts">
import { computed } from "vue";
import { storeToRefs } from "pinia";
import { useUiFilterStore } from "@/store/uiFilterStore";
import { useEmployeeList } from "@/composables/useEmployeeList";
import { useOrgDashboard } from "@/composables/useOrgDashboard";
import { useOrgInsights } from "@/composables/useOrgInsights";
import EmployeeSearchBar from "@/components/EmployeeSearchBar.vue";
import FilterBar from "@/components/FilterBar.vue";
import EmployeeListTable from "@/components/EmployeeListTable.vue";
import OrgStatTile from "@/components/OrgStatTile.vue";
import Pagination from "@/components/Pagination.vue";
import { formatHours, formatTimeOfDay } from "@/utils/formatDuration";
import { formatDateLabel } from "@/utils/formatDate";
import { computeOrgTrendInsights, headcountSparkline, loginTimeSparkline } from "@/utils/orgTrend";

const uiFilter = useUiFilterStore();
const { q, manager, sort, start, limit } = storeToRefs(uiFilter);

const { dashboard, isLoading: dashboardLoading } = useOrgDashboard();
const { insights } = useOrgInsights();
const {
  rows,
  hasMore,
  isLoading: listLoading,
  isFetching: listFetching,
} = useEmployeeList({ q, manager, sort, start, limit });

interface Delta {
  text: string;
  direction: "up" | "down";
}

function buildDelta(change: number, unit: "%" | "min"): Delta {
  const direction: "up" | "down" = change >= 0 ? "up" : "down";
  const magnitude = unit === "%" ? Math.abs(change).toFixed(1) : Math.round(Math.abs(change)).toString();
  return { text: `${direction === "up" ? "▲" : "▼"} ${magnitude}${unit === "%" ? "%" : " min"}`, direction };
}

const orgTrend = computed(() => computeOrgTrendInsights(dashboard.value?.history ?? []));

const headcountDeltaText = computed<Delta | null>(() => {
  const data = insights.value;
  if (!data || !data.total_registered_employees_growth_window_start) return null;
  const change =
    ((data.total_registered_employees - data.total_registered_employees_growth_window_start) /
      data.total_registered_employees_growth_window_start) *
    100;
  return buildDelta(change, "%");
});

const avgHoursDeltaText = computed<Delta | null>(() => {
  const change = orgTrend.value.avgHoursChangePercent;
  return change === null ? null : buildDelta(change, "%");
});

const avgLoginDeltaText = computed<Delta | null>(() => {
  const change = orgTrend.value.avgLoginMinutesDelta;
  return change === null ? null : buildDelta(change, "min");
});

const avgHoursSparkline = computed(() => (dashboard.value?.history ?? []).map((point) => point.avg_hours_org));
const avgLoginSparkline = computed(() => loginTimeSparkline(dashboard.value?.history ?? []));
const headcountTrendSparkline = computed(() => headcountSparkline(dashboard.value?.headcount_trend ?? []));

function onSearchInput(value: string): void {
  uiFilter.setQuery(value);
}
function onManagerChange(value: string | null): void {
  uiFilter.setManager(value);
}
function onSortChange(value: string | null): void {
  uiFilter.setSort(value);
}
function onClearFilters(): void {
  uiFilter.reset();
}
function onNextPage(): void {
  uiFilter.nextPage(hasMore.value);
}
function onPrevPage(): void {
  uiFilter.prevPage();
}
</script>

<template>
  <div class="app-shell">
    <nav class="sidebar">
      <div class="sidebar-logo"><div class="logo-mark"></div><span>Analytics</span></div>
      <button class="nav-item active"><span class="dot"></span>Dashboard</button>
      <div class="sidebar-spacer"></div>
    </nav>

    <main class="main">
      <div class="topbar">
        <span class="breadcrumb">Executive Dashboard</span>
        <span v-if="dashboard?.date" class="as-of-label">as of {{ formatDateLabel(dashboard.date) }}</span>
      </div>

      <div class="body-content">
        <div class="stat-grid">
          <OrgStatTile
            label="Total employees tracked"
            :value="dashboardLoading ? '—' : (insights?.total_registered_employees ?? 0).toLocaleString()"
            dot-color-var="var(--violet-500)"
            :delta-text="headcountDeltaText?.text"
            :delta-direction="headcountDeltaText?.direction"
            :sparkline="headcountTrendSparkline"
          />
          <OrgStatTile
            label="Org-wide avg hours/day"
            :value="dashboardLoading ? '—' : formatHours(dashboard?.avg_hours_org)"
            dot-color-var="var(--teal-500)"
            :delta-text="avgHoursDeltaText?.text"
            :delta-direction="avgHoursDeltaText?.direction"
            :sparkline="avgHoursSparkline"
          />
          <OrgStatTile
            label="Org-wide avg login time"
            :value="dashboardLoading ? '—' : formatTimeOfDay(dashboard?.avg_login_time_org)"
            dot-color-var="var(--amber-500)"
            :delta-text="avgLoginDeltaText?.text"
            :delta-direction="avgLoginDeltaText?.direction"
            :sparkline="avgLoginSparkline"
          />
        </div>

        <div v-if="insights" class="insight-chips-row">
          <span class="insight-chip">{{ insights.manager_count.toLocaleString() }} people-managers across the org</span>
          <span class="insight-chip">
            {{ insights.low_hours_employee_count.toLocaleString() }} employees averaging under
            {{ insights.low_hours_threshold }} hrs/day
          </span>
          <span class="insight-chip">
            {{ insights.recent_hires_count.toLocaleString() }} employees joined in the last
            {{ insights.recent_hires_window_days }} days
          </span>
        </div>

        <div class="search-row">
          <EmployeeSearchBar :model-value="q" @update:model-value="onSearchInput" />
        </div>

        <FilterBar
          :manager="manager"
          :sort="sort"
          @update:manager="onManagerChange"
          @update:sort="onSortChange"
          @clear="onClearFilters"
        />

        <EmployeeListTable :rows="rows" :loading="listLoading" :low-hours-threshold="insights?.low_hours_threshold ?? null" />
        <Pagination
          :start="start"
          :limit="limit"
          :row-count="rows.length"
          :has-more="hasMore"
          :loading="listFetching"
          @prev="onPrevPage"
          @next="onNextPage"
        />
      </div>
    </main>
  </div>
</template>
