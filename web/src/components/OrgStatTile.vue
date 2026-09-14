<script setup lang="ts">
import { computed } from "vue";

const props = defineProps<{
  label: string;
  value: string;
  dotColorVar: string;
  deltaText?: string | null;
  deltaDirection?: "up" | "down" | null;
  sparkline?: number[] | null;
}>();

const sparklinePoints = computed(() => {
  const values = props.sparkline;
  if (!values || values.length < 2) return null;
  const width = 100;
  const height = 28;
  const max = Math.max(...values);
  const min = Math.min(...values);
  const range = max - min || 1;
  const stepX = width / (values.length - 1);
  return values.map((value, index) => `${index * stepX},${height - ((value - min) / range) * height}`).join(" ");
});
</script>

<template>
  <div class="card stat-tile">
    <div class="stat-tile-head">
      <span class="stat-dot" :style="{ background: dotColorVar }"></span>
      <span class="stat-label">{{ label }}</span>
    </div>
    <div class="stat-tile-value-row">
      <div class="stat-value">{{ value }}</div>
      <span
        v-if="deltaText"
        class="metric-delta"
        :class="deltaDirection === 'up' ? 'delta-up' : 'delta-down'"
        title="vs. the previous 7 days"
      >
        {{ deltaText }}
      </span>
    </div>
    <svg v-if="sparklinePoints" class="stat-sparkline" viewBox="0 0 100 28" preserveAspectRatio="none">
      <polyline
        :points="sparklinePoints"
        fill="none"
        :stroke="dotColorVar"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
      />
    </svg>
  </div>
</template>
