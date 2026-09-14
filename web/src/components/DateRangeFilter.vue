<script setup lang="ts">
import type { DateRangePreset } from '../composables/useDateRangeFilter'

interface Props {
  preset: DateRangePreset
  customFrom: string
  customTo: string
}

interface Emits {
  (e: 'update:preset', value: DateRangePreset): void
  (e: 'update:customFrom', value: string): void
  (e: 'update:customTo', value: string): void
}

defineProps<Props>()
const emit = defineEmits<Emits>()

function selectPreset(value: DateRangePreset): void {
  emit('update:preset', value)
}
</script>

<template>
  <div class="date-range-filter">
    <div class="date-range-filter__presets">
      <button
        type="button"
        class="preset-btn"
        :class="{ 'preset-btn--active': preset === 'this-week' }"
        @click="selectPreset('this-week')"
      >
        This Week
      </button>
      <button
        type="button"
        class="preset-btn"
        :class="{ 'preset-btn--active': preset === 'this-month' }"
        @click="selectPreset('this-month')"
      >
        This Month
      </button>
      <button
        type="button"
        class="preset-btn"
        :class="{ 'preset-btn--active': preset === 'custom' }"
        @click="selectPreset('custom')"
      >
        Custom Range
      </button>
    </div>

    <div v-if="preset === 'custom'" class="date-range-filter__custom">
      <label class="custom-input">
        <span>From</span>
        <input
          type="date"
          :value="customFrom"
          @input="emit('update:customFrom', ($event.target as HTMLInputElement).value)"
        />
      </label>
      <label class="custom-input">
        <span>To</span>
        <input
          type="date"
          :value="customTo"
          @input="emit('update:customTo', ($event.target as HTMLInputElement).value)"
        />
      </label>
    </div>
  </div>
</template>

<style scoped>
.date-range-filter {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
  font-family: 'Inter', ui-sans-serif, system-ui, sans-serif;
}

.date-range-filter__presets {
  display: flex;
  gap: 6px;
}

.preset-btn {
  padding: 6px 12px;
  font-size: 13px;
  border: 1px solid #e2e5eb;
  border-radius: 4px;
  background: #ffffff;
  color: #374151;
  cursor: pointer;
}

.preset-btn--active {
  background: #3b5bdb;
  border-color: #3b5bdb;
  color: #ffffff;
}

.date-range-filter__custom {
  display: flex;
  gap: 12px;
}

.custom-input {
  display: flex;
  flex-direction: column;
  gap: 2px;
  font-size: 12px;
  color: #6b7280;
}

.custom-input input {
  padding: 5px 8px;
  border: 1px solid #e2e5eb;
  border-radius: 4px;
  font-size: 13px;
}
</style>