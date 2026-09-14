<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount, watch } from 'vue'
import {
  Chart,
  LineController,
  LineElement,
  PointElement,
  LinearScale,
  CategoryScale,
  Tooltip,
  Filler,
} from 'chart.js'
import type { EmployeeTrendPoint } from '../types/employee'

Chart.register(LineController, LineElement, PointElement, LinearScale, CategoryScale, Tooltip, Filler)

interface Props {
  trend: EmployeeTrendPoint[]
}

const props = defineProps<Props>()

const canvasRef = ref<HTMLCanvasElement | null>(null)
let chartInstance: Chart | null = null

function shortDate(dateStr: string): string {
  const date = new Date(dateStr)
  return date.toLocaleDateString('en-IN', { day: '2-digit', month: 'short' })
}

function buildChart(): void {
  if (!canvasRef.value) return

  chartInstance = new Chart(canvasRef.value, {
    type: 'line',
    data: {
      labels: props.trend.map((point) => shortDate(point.date)),
      datasets: [
        {
          label: 'Hours worked',
          data: props.trend.map((point) => point.hours),
          borderColor: '#3b5bdb',
          backgroundColor: 'rgba(59, 91, 219, 0.08)',
          fill: true,
          tension: 0.3,
          pointRadius: 2,
          pointHoverRadius: 4,
          borderWidth: 2,
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { display: false },
        tooltip: {
          callbacks: {
            // eslint-disable-next-line @typescript-eslint/no-explicit-any
            label: (context: any) => `${context.parsed.y.toFixed(1)}h`,
          },
        },
      },
      scales: {
        y: {
          beginAtZero: true,
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
          ticks: { callback: (value: any) => `${value}h` },
        },
        x: {
          ticks: { maxRotation: 0, autoSkip: true, maxTicksLimit: 8 },
        },
      },
    },
  })
}

function updateChartData(): void {
  if (!chartInstance) return
  chartInstance.data.labels = props.trend.map((point) => shortDate(point.date))
  chartInstance.data.datasets[0].data = props.trend.map((point) => point.hours)
  chartInstance.update()
}

onMounted(() => {
  buildChart()
})

onBeforeUnmount(() => {
  chartInstance?.destroy()
  chartInstance = null
})

watch(
  () => props.trend,
  () => {
    if (chartInstance) {
      updateChartData()
    } else {
      buildChart()
    }
  },
  { deep: true },
)
</script>

<template>
  <section class="trend-chart">
    <h3 class="trend-chart__title">Hours trend</h3>

    <div v-if="trend.length === 0" class="trend-chart__empty">
      No trend data available for this employee yet.
    </div>
    <div v-else class="trend-chart__canvas-wrapper">
      <canvas ref="canvasRef" role="img" aria-label="Line chart of daily hours worked over time"></canvas>
    </div>
  </section>
</template>

<style scoped>
.trend-chart {
  border: 1px solid #e2e5eb;
  border-radius: 6px;
  background: #ffffff;
  padding: 20px 24px;
  font-family: 'Inter', ui-sans-serif, system-ui, sans-serif;
  color: #1a1f2b;
}

.trend-chart__title {
  margin: 0 0 16px;
  font-size: 15px;
  font-weight: 600;
}

.trend-chart__canvas-wrapper {
  position: relative;
  height: 260px;
}

.trend-chart__empty {
  padding: 40px 0;
  text-align: center;
  font-size: 13px;
  color: #6b7280;
}
</style>