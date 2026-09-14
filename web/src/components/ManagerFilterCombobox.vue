<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref, watch } from "vue";
import { useEmployeeList } from "@/composables/useEmployeeList";
import { debounce } from "@/utils/debounce";
import { SEARCH_DEBOUNCE_MS } from "@/constants/apiConstants";
import type { EmployeeListRow } from "@/types/employee";

const MANAGER_RESULT_LIMIT = 8;

const props = defineProps<{ manager: string | null }>();
const emit = defineEmits<{ "update:manager": [value: string | null] }>();

const rootRef = ref<HTMLDivElement | null>(null);
const inputRef = ref<HTMLInputElement | null>(null);
const inputText = ref("");
const debouncedQuery = ref("");
const selectedName = ref<string | null>(null);
const isOpen = ref(false);

const debouncedSetQuery = debounce((value: string) => {
  debouncedQuery.value = value;
}, SEARCH_DEBOUNCE_MS);

const displayValue = computed(() => selectedName.value ?? inputText.value);

const noManagerFilter = ref<string | null>(null);
const noSort = ref<string | null>(null);
const resultStart = ref(0);
const resultLimit = ref(MANAGER_RESULT_LIMIT);

const { rows, isFetching } = useEmployeeList({
  q: debouncedQuery,
  manager: noManagerFilter,
  sort: noSort,
  start: resultStart,
  limit: resultLimit,
  enabled: isOpen,
});

function openDropdown(): void {
  isOpen.value = true;
}
function closeDropdown(): void {
  isOpen.value = false;
}

function onInput(event: Event): void {
  const value = (event.target as HTMLInputElement).value;
  inputText.value = value;
  isOpen.value = true;

  // Typing again after a selection starts a fresh search - the previous
  // pick no longer applies until another one is made.
  if (selectedName.value) {
    selectedName.value = null;
    emit("update:manager", null);
  }
  debouncedSetQuery(value);
}

function selectManager(row: EmployeeListRow): void {
  selectedName.value = `${row.employee_name} (${row.employee_id})`;
  inputText.value = "";
  debouncedQuery.value = "";
  emit("update:manager", row.employee_id);
  closeDropdown();
}

function clearManager(): void {
  selectedName.value = null;
  inputText.value = "";
  debouncedQuery.value = "";
  emit("update:manager", null);
  inputRef.value?.focus();
  openDropdown();
}

function onClickOutside(event: MouseEvent): void {
  if (rootRef.value && !rootRef.value.contains(event.target as Node)) {
    closeDropdown();
  }
}

onMounted(() => document.addEventListener("mousedown", onClickOutside));
onBeforeUnmount(() => document.removeEventListener("mousedown", onClickOutside));

// Prop can be cleared from outside (e.g. "Clear filters") - drop our own label too.
watch(
  () => props.manager,
  (value) => {
    if (!value) selectedName.value = null;
  },
);
</script>

<template>
  <div class="combobox" ref="rootRef">
    <span class="combobox-icon"></span>
    <input
      ref="inputRef"
      type="text"
      class="combobox-input"
      placeholder="Search managers by name or ID…"
      :value="displayValue"
      @focus="openDropdown"
      @input="onInput"
      @keydown.escape="closeDropdown"
    />
    <button
      v-if="displayValue"
      class="combobox-clear"
      type="button"
      aria-label="Clear manager filter"
      @mousedown.prevent="clearManager"
    >
      ×
    </button>

    <div v-if="isOpen" class="combobox-panel">
      <div v-if="isFetching" class="combobox-status">Searching…</div>
      <template v-else-if="rows.length">
        <button
          v-for="row in rows"
          :key="row.employee_id"
          type="button"
          class="combobox-option"
          @mousedown.prevent="selectManager(row)"
        >
          <strong>{{ row.employee_name }}</strong>
          <span>{{ row.employee_id }}</span>
        </button>
        <div v-if="rows.length >= MANAGER_RESULT_LIMIT" class="combobox-hint">
          Showing the first {{ MANAGER_RESULT_LIMIT }} matches — keep typing to narrow down.
        </div>
      </template>
      <div v-else class="combobox-status">
        {{ inputText ? `No employees match "${inputText}".` : "No employees found." }}
      </div>
    </div>
  </div>
</template>
