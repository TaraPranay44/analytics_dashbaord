<script setup lang="ts">
import type { EmployeeListRow } from "@/types/employee";
import EmployeeListRowItem from "@/components/EmployeeListRow.vue";
import { STRINGS } from "@/constants/stringConstants";

defineProps<{
  rows: EmployeeListRow[];
  loading: boolean;
  lowHoursThreshold: number | null;
}>();
</script>

<template>
  <div class="card emp-table">
    <div class="emp-table-head">
      <span>EMPLOYEE</span>
      <span>MANAGER</span>
      <span>AVG HRS/DAY</span>
      <span>AVG LOGIN</span>
      <span>ACTIONS</span>
    </div>
    <div v-if="loading" class="emp-table-status">{{ STRINGS.loadingLabel }}</div>
    <template v-else-if="rows.length">
      <EmployeeListRowItem
        v-for="row in rows"
        :key="row.employee_id"
        :employee="row"
        :low-hours-threshold="lowHoursThreshold"
      />
    </template>
    <div v-else class="emp-table-status">{{ STRINGS.noResults }}</div>
  </div>
</template>
