<script setup lang="ts">
defineProps<{
  fromDate: string | null;
  toDate: string | null;
}>();

const emit = defineEmits<{
  "apply-last-n-days": [days: number];
  clear: [];
}>();
</script>

<template>
  <div class="filter-row">
    <button class="filter-chip" type="button" @click="emit('apply-last-n-days', 7)">Last 7 days</button>
    <button class="filter-chip" type="button" @click="emit('apply-last-n-days', 30)">Last 30 days</button>
    <button class="filter-chip" type="button" @click="emit('clear')">All time</button>
    <span v-if="fromDate && toDate" class="date-range-label">{{ fromDate }} → {{ toDate }}</span>
  </div>
</template>
