<script setup lang="ts">
defineProps<{
  manager: string
  sort: string
}>()

const emit = defineEmits<{
  'update:manager': [value: string]
  'update:sort': [value: string]
}>()
</script>

<template>
  <div class="filter-bar">
    <input
      type="text"
      :value="manager"
      @input="emit('update:manager', ($event.target as HTMLInputElement).value)"
      placeholder="Filter by manager"
    />
    <select
      :value="sort"
      @change="emit('update:sort', ($event.target as HTMLSelectElement).value)"
    >
      <option value="">Default sort</option>
      <option value="name">Name</option>
      <option value="hours">Avg hours/day</option>
    </select>
  </div>
</template>

<style scoped>
.filter-bar {
  display: flex;
  gap: 0.75rem;
}
.filter-bar input,
.filter-bar select {
  padding: 0.5rem;
  border-radius: 6px;
  border: 1px solid #444;
}
</style>