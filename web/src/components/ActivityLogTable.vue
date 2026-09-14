<script setup lang="ts">
import type { ActivityLogEntry } from '../types/activityLog'
import { formatDate } from '../utils/formatDate'
import { formatDuration } from '../utils/formatDuration'

interface Props {
  logs: ActivityLogEntry[]
}

const props = defineProps<Props>()

function formatTime(time: string | null): string {
  if (!time) return '—'
  return time.slice(0, 5)
}
</script>

<template>
  <table class="log-table">
    <thead>
      <tr>
        <th>Date</th>
        <th>Login</th>
        <th>Logout</th>
        <th>Hours</th>
      </tr>
    </thead>
    <tbody>
      <tr v-if="logs.length === 0">
        <td colspan="4" class="log-table__empty">No activity logs for this range.</td>
      </tr>
      <tr v-for="entry in logs" :key="entry.date">
        <td>{{ formatDate(entry.date) }}</td>
        <td>{{ formatTime(entry.login_time) }}</td>
        <td>{{ formatTime(entry.logout_time) }}</td>
        <td>{{ formatDuration(entry.total_hours) }}</td>
      </tr>
    </tbody>
  </table>
</template>

<style scoped>
.log-table {
  width: 100%;
  border-collapse: collapse;
  font-family: 'Inter', ui-sans-serif, system-ui, sans-serif;
  font-size: 13px;
}

.log-table th {
  text-align: left;
  font-weight: 600;
  color: #6b7280;
  font-size: 12px;
  padding: 6px 10px;
  border-bottom: 1px solid #e2e5eb;
}

.log-table td {
  padding: 6px 10px;
  border-bottom: 1px solid #f0f1f4;
  font-variant-numeric: tabular-nums;
}

.log-table__empty {
  text-align: center;
  color: #6b7280;
  padding: 20px 0;
}
</style>