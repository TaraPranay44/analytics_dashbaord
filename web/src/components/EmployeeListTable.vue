<script setup lang="ts">
import type { EmployeeListRow as EmployeeListRowType } from '../types/employee'
import EmployeeListRow from './EmployeeListRow.vue'
import { UI_STRINGS } from '../constants/stringConstants'

defineProps<{
  employees: EmployeeListRowType[]
}>()

const emit = defineEmits<{
  rowClick: [employeeId: string]
}>()
</script>

<template>
  <table class="employee-table">
    <thead>
      <tr>
        <th>Name</th>
        <th>Employee ID</th>
        <th>Manager</th>
        <th>Avg Hours/Day</th>
        <th>Avg Login</th>
        <th>Status</th>
      </tr>
    </thead>
    <tbody>
      <EmployeeListRow
        v-for="employee in employees"
        :key="employee.employee_id"
        :employee="employee"
        @click="emit('rowClick', $event)"
      />
      <tr v-if="employees.length === 0">
        <td colspan="6" class="empty-state">{{ UI_STRINGS.NO_RESULTS }}</td>
      </tr>
    </tbody>
  </table>
</template>

<style scoped>
.employee-table {
  width: 100%;
  border-collapse: collapse;
}
th {
  text-align: left;
  padding: 0.5rem 0.75rem;
  border-bottom: 2px solid #444;
  font-size: 0.85rem;
  text-transform: uppercase;
  opacity: 0.7;
}
.empty-state {
  text-align: center;
  padding: 2rem;
  opacity: 0.6;
}
</style>