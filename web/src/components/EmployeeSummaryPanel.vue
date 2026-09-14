<script setup lang="ts">
import { computed } from "vue";
import type { EmployeeDetail } from "@/types/employee";
import { formatHours, formatTimeOfDay } from "@/utils/formatDuration";
import { computeTrendInsights } from "@/utils/trendInsights";

const props = defineProps<{ detail: EmployeeDetail }>();

const insights = computed(() => computeTrendInsights(props.detail.trend));

function formatDelta(value: number, unit: "%" | "pts"): string {
  const rounded = Math.round(Math.abs(value));
  const arrow = value >= 0 ? "↑" : "↓";
  return unit === "%" ? `${arrow} ${rounded}%` : `${arrow} ${rounded} pts`;
}

const attendanceTrendWord = computed(() => {
  const change = insights.value.attendanceChangePoints;
  if (change === null || Math.abs(change) < 3) return "steady";
  return change > 0 ? "improving" : "slipping";
});

const insightSentence = computed(() => {
  const hoursClause = `Averaging ${formatHours(props.detail.avg_hours_overall)}/day`;
  const trendClause =
    insights.value.hoursChangePercent !== null
      ? `, ${insights.value.hoursChangePercent >= 0 ? "up" : "down"} ${Math.round(
          Math.abs(insights.value.hoursChangePercent),
        )}% over the last 7 days`
      : "";
  const attendanceClause =
    insights.value.attendanceRatePercent !== null
      ? ` — attendance is ${attendanceTrendWord.value} at ${Math.round(insights.value.attendanceRatePercent)}%`
      : "";
  return `${hoursClause}${trendClause}${attendanceClause}.`;
});
</script>

<template>
  <div class="card perf-card">
    <div class="perf-head">
      <h3>Performance summary</h3>
    </div>
    <div class="metric-strip">
      <div class="metric-tile">
        <div class="metric-bar" style="background: var(--violet-500)"></div>
        <div class="metric-tile-top">
          <div class="metric-value">{{ formatHours(detail.avg_hours_overall) }}</div>
          <span
            v-if="insights.hoursChangePercent !== null"
            class="metric-delta"
            :class="insights.hoursChangePercent >= 0 ? 'delta-up' : 'delta-down'"
            title="vs. the previous 7 days"
          >
            {{ formatDelta(insights.hoursChangePercent, "%") }}
          </span>
        </div>
        <div class="metric-label">Avg. time spent / day</div>
      </div>

      <div class="metric-tile">
        <div class="metric-bar" style="background: var(--amber-500)"></div>
        <div class="metric-value">{{ formatTimeOfDay(detail.avg_login_time_overall) }}</div>
        <div class="metric-label">Avg. login time</div>
      </div>

      <div class="metric-tile">
        <div class="metric-bar" style="background: var(--ink-900)"></div>
        <div class="metric-value">{{ formatTimeOfDay(detail.avg_logout_time_overall) }}</div>
        <div class="metric-label">Avg. logout time</div>
      </div>

      <div v-if="insights.attendanceRatePercent !== null" class="metric-tile">
        <div class="metric-bar" style="background: var(--teal-500)"></div>
        <div class="metric-tile-top">
          <div class="metric-value">{{ Math.round(insights.attendanceRatePercent) }}%</div>
          <span
            v-if="insights.attendanceChangePoints !== null"
            class="metric-delta"
            :class="insights.attendanceChangePoints >= 0 ? 'delta-up' : 'delta-down'"
            title="vs. the previous 7 days"
          >
            {{ formatDelta(insights.attendanceChangePoints, "pts") }}
          </span>
        </div>
        <div class="metric-label">Attendance ({{ insights.attendanceWindowDays }}d)</div>
      </div>
    </div>

    <p class="insight-banner">{{ insightSentence }}</p>
  </div>
</template>
