<script setup lang="ts">
import { ref, watch } from "vue";
import { STRINGS } from "@/constants/stringConstants";
import { debounce } from "@/utils/debounce";
import { SEARCH_DEBOUNCE_MS } from "@/constants/apiConstants";

const props = defineProps<{ modelValue: string }>();
const emit = defineEmits<{ "update:modelValue": [value: string] }>();

// Local echo so the input feels instant while the debounced emit catches up -
// query-per-keystroke is forbidden (docs/05_FRONTEND_WEB_RULES.md §5/§8).
const localValue = ref(props.modelValue);
watch(
  () => props.modelValue,
  (value) => {
    if (value !== localValue.value) localValue.value = value;
  },
);

const emitDebounced = debounce((value: string) => emit("update:modelValue", value), SEARCH_DEBOUNCE_MS);

function onInput(event: Event): void {
  const value = (event.target as HTMLInputElement).value;
  localValue.value = value;
  emitDebounced(value);
}
</script>

<template>
  <div class="search-bar">
    <span class="search-icon"></span>
    <input
      type="text"
      :value="localValue"
      :placeholder="STRINGS.searchPlaceholder"
      @input="onInput"
    />
  </div>
</template>
