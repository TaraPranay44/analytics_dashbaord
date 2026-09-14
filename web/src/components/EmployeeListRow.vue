<script setup lang="ts">
import type { EmployeeListRow } from '../types/employee'
import { formatDuration } from '../utils/formatDuration'

defineProps<{
  employee: EmployeeListRow
}>()

const emit = defineEmits<{
  click: [employeeId: string]
}>()
</script>

<template>
  <tr class="employee-row" @click="emit('click', employee.employee_id)">
    <td>{{ employee.employee_name }}</td>
    <td>{{ employee.employee_id }}</td>
    <td>{{ employee.manager ?? '—' }}</td>
    <td>{{ formatDuration(employee.avg_hours_per_day) }}</td>
    <td>{{ employee.avg_login_time ?? '—' }}</td>
    <td>{{ employee.status }}</td>
  </tr>
</template>

<style scoped>
.employee-row {
  cursor: pointer;
}
.employee-row:hover {
  background: rgba(255, 255, 255, 0.05);
}
td {
  padding: 0.5rem 0.75rem;
  border-bottom: 1px solid #333;
}
</style>