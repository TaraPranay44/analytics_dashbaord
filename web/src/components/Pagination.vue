<script setup lang="ts">
defineProps<{
  page: number
  pageSize: number
  hasMore: boolean
}>()

const emit = defineEmits<{
  'update:page': [value: number]
}>()

function goPrev(page: number) {
  if (page > 1) {
    emit('update:page', page - 1)
  }
}

function goNext(page: number, hasMore: boolean) {
  if (hasMore) {
    emit('update:page', page + 1)
  }
}
</script>

<template>
  <div class="pagination">
    <span>
      Showing {{ (page - 1) * pageSize + 1 }}–{{ (page - 1) * pageSize + pageSize }}
    </span>
    <div class="pagination-controls">
      <button :disabled="page <= 1" @click="goPrev(page)">Prev</button>
      <button :disabled="!hasMore" @click="goNext(page, hasMore)">Next</button>
    </div>
  </div>
</template>

<style scoped>
.pagination {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem 0;
  font-size: 0.9rem;
}
.pagination-controls {
  display: flex;
  gap: 0.5rem;
}
button {
  padding: 0.4rem 0.9rem;
  border-radius: 6px;
  border: 1px solid #444;
  cursor: pointer;
}
button:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}
</style>