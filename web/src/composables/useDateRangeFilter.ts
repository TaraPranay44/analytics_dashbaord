import { ref, computed } from 'vue'

export type DateRangePreset = 'this-week' | 'this-month' | 'custom'

export function useDateRangeFilter() {
  const preset = ref<DateRangePreset>('this-month')
  const customFrom = ref('')
  const customTo = ref('')

  const fromDate = computed(() => {
    const now = new Date()
    if (preset.value === 'this-week') {
      const day = now.getDay()
      const start = new Date(now)
      start.setDate(now.getDate() - day)
      return start.toISOString().slice(0, 10)
    }
    if (preset.value === 'this-month') {
      return new Date(now.getFullYear(), now.getMonth(), 1)
        .toISOString()
        .slice(0, 10)
    }
    return customFrom.value
  })

  const toDate = computed(() => {
    if (preset.value === 'custom') {
      return customTo.value
    }
    return new Date().toISOString().slice(0, 10)
  })

  return {
    preset,
    customFrom,
    customTo,
    fromDate,
    toDate,
  }
}