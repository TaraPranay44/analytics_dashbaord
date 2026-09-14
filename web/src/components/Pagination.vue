<script setup lang="ts">
defineProps<{
  start: number;
  limit: number;
  rowCount: number;
  hasMore: boolean;
  loading?: boolean;
}>();

const emit = defineEmits<{
  prev: [];
  next: [];
}>();
</script>

<template>
  <div class="pager-row">
    <span v-if="rowCount > 0">
      Showing {{ start + 1 }}–{{ start + rowCount }}{{ hasMore ? " · more available" : "" }}
    </span>
    <span v-else>No rows to show</span>
    <div class="pager-controls">
      <button class="page-btn page-btn-arrow" type="button" :disabled="start <= 0 || loading" @click="emit('prev')">
        <span class="page-btn-arrow-icon">←</span> Prev
      </button>
      <button class="page-btn page-btn-arrow" type="button" :disabled="!hasMore || loading" @click="emit('next')">
        Next <span class="page-btn-arrow-icon">→</span>
      </button>
    </div>
  </div>
</template>
