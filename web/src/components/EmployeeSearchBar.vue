<script setup lang="ts">
import { ref, watch } from 'vue'
import { debounce } from '../utils/debounce'
import { UI_STRINGS } from '../constants/stringConstants'

const props = defineProps<{
  modelValue: string
}>()

const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()

const localValue = ref(props.modelValue)

const debouncedEmit = debounce((value: string) => {
  emit('update:modelValue', value)
}, 300)

watch(localValue, (newValue) => {
  debouncedEmit(newValue)
})
</script>

<template>
  <input
    type="text"
    v-model="localValue"
    :placeholder="UI_STRINGS.SEARCH_PLACEHOLDER"
    class="search-bar"
  />
</template>

<style scoped>
.search-bar {
  padding: 0.5rem 1rem;
  border-radius: 6px;
  border: 1px solid #444;
  width: 100%;
  max-width: 400px;
}
</style>