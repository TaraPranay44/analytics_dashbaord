<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref, watch } from "vue";
import { Chart, type ChartConfiguration } from "chart.js/auto";
import type { TrendPoint } from "@/types/employee";
import { formatMonthLabel, formatShortDate } from "@/utils/formatDate";
import { useEmployeeMonthlyTrend } from "@/composables/useEmployeeMonthlyTrend";

const props = defineProps<{ trend: TrendPoint[]; employeeId: string }>();

type ChartWindow = "7d" | "30d" | "lifetime";
const chartWindow = ref<ChartWindow>("30d");
const isLifetime = computed(() => chartWindow.value === "lifetime");

// "Lifetime" is a separate endpoint (`employee_monthly_trend`, monthly
// averages from `Employee Monthly Stats`) - the daily `trend` prop only ever
// covers `EMPLOYEE_DETAIL_TREND_DAYS`, so it can't honestly answer "lifetime".
// Fetched lazily, only once this view is actually selected.
const { months, isFetching: monthsFetching } = useEmployeeMonthlyTrend(
  computed(() => props.employeeId),
  isLifetime,
);

const chartLabels = computed(() => {
  if (chartWindow.value === "7d") return props.trend.slice(-7).map((p) => formatShortDate(p.date));
  if (chartWindow.value === "30d") return props.trend.map((p) => formatShortDate(p.date));
  return months.value.map((p) => formatMonthLabel(p.year_month));
});

const chartValues = computed(() => {
  if (chartWindow.value === "7d") return props.trend.slice(-7).map((p) => p.total_hours);
  if (chartWindow.value === "30d") return props.trend.map((p) => p.total_hours);
  return months.value.map((p) => p.avg_hours);
});

// A single point draws no line at all - fall back to a visible dot so sparse
// data (e.g. an employee with only one month of Employee Monthly Stats
// computed so far) doesn't just look like a blank chart.
const pointRadius = computed(() => (chartValues.value.length < 5 ? 4 : 0));

const canvasRef = ref<HTMLCanvasElement | null>(null);
let chart: Chart<"line"> | null = null;

function buildOrUpdateChart(): void {
  if (!canvasRef.value) return;
  const labels = chartLabels.value;
  const values = chartValues.value;

  if (chart) {
    chart.data.labels = labels;
    chart.data.datasets[0].data = values;
    chart.data.datasets[0].pointRadius = pointRadius.value;
    chart.update();
    return;
  }

  const config: ChartConfiguration<"line"> = {
    type: "line",
    data: {
      labels,
      datasets: [
        {
          label: "Hours",
          data: values,
          borderColor: "#8A6BFF",
          backgroundColor: "rgba(138, 107, 255, 0.18)",
          pointBackgroundColor: "#8A6BFF",
          tension: 0.35,
          fill: true,
          pointRadius: pointRadius.value,
          pointHoverRadius: 5,
          borderWidth: 2.5,
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: { legend: { display: false } },
      scales: {
        y: { beginAtZero: true, grid: { color: "rgba(21,20,43,0.05)" } },
        x: { grid: { display: false } },
      },
    },
  };
  chart = new Chart(canvasRef.value, config);
}

onMounted(buildOrUpdateChart);
watch([chartLabels, chartValues], buildOrUpdateChart);
onBeforeUnmount(() => chart?.destroy());
</script>

<template>
  <div class="card trend-card">
    <div class="trend-card-head">
      <h3>Time spent / day</h3>
      <div class="window-toggle">
        <button class="window-toggle-btn" type="button" :class="{ active: chartWindow === '7d' }" @click="chartWindow = '7d'">
          Last 7 days
        </button>
        <button class="window-toggle-btn" type="button" :class="{ active: chartWindow === '30d' }" @click="chartWindow = '30d'">
          Last {{ trend.length }} days
        </button>
        <button
          class="window-toggle-btn"
          type="button"
          :class="{ active: chartWindow === 'lifetime' }"
          @click="chartWindow = 'lifetime'"
        >
          Lifetime
        </button>
      </div>
    </div>
    <p v-if="isLifetime && monthsFetching" class="trend-chart-note">Loading lifetime trend…</p>
    <p v-else-if="isLifetime && !months.length" class="trend-chart-note">
      No monthly stats computed yet for this employee.
    </p>
    <p v-else-if="isLifetime && months.length < 2" class="trend-chart-note">
      Only {{ months.length }} month of history computed so far — the dot below is it. More months will
      appear here as the nightly aggregation job accumulates them.
    </p>
    <div class="trend-chart-canvas-wrap trend-chart-canvas-wrap-lg">
      <canvas ref="canvasRef"></canvas>
    </div>
  </div>
</template>
