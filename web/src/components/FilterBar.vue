<script setup lang="ts">
import ManagerFilterCombobox from "@/components/ManagerFilterCombobox.vue";

defineProps<{
  manager: string | null;
  sort: string | null;
}>();

const emit = defineEmits<{
  "update:manager": [value: string | null];
  "update:sort": [value: string | null];
  clear: [];
}>();

function onSortChange(event: Event): void {
  const value = (event.target as HTMLSelectElement).value;
  emit("update:sort", value ? value : null);
}
</script>

<template>
  <div class="filters-bar">
    <div class="filter-field filter-field-manager">
      <span class="filter-field-label">Manager</span>
      <ManagerFilterCombobox :manager="manager" @update:manager="(v) => emit('update:manager', v)" />
    </div>

    <div class="filter-field filter-field-sort">
      <span class="filter-field-label">Sort by</span>
      <div class="select-wrap">
        <select class="select-control" :value="sort ?? ''" @change="onSortChange">
          <option value="">Name A–Z</option>
          <option value="hours">Avg hrs/day (high–low)</option>
        </select>
        <svg class="select-chevron" viewBox="0 0 20 20" fill="none">
          <path d="M5 7.5l5 5 5-5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" />
        </svg>
      </div>
    </div>

    <button class="clear-filters-btn" type="button" @click="emit('clear')">Clear filters</button>
  </div>
</template>
