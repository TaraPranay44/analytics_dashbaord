<script setup lang="ts">
import { computed } from 'vue'
import type { EmployeeDetail } from '../types/employee'
import { formatDate } from '../utils/formatDate'
import { formatDuration } from '../utils/formatDuration'

interface Props {
  employee: EmployeeDetail
}

const props = defineProps<Props>()

function formatTime(time: string | null): string {
  if (!time) return '—'
  return time.slice(0, 5)
}

const formattedJoinDate = computed(() => formatDate(props.employee.date_of_joining))
const formattedAvgHours = computed(() => formatDuration(props.employee.avg_hours_per_day))
const formattedAvgLogin = computed(() => formatTime(props.employee.avg_login_time))
const formattedAvgLogout = computed(() => formatTime(props.employee.avg_logout_time))
const formattedAttendance = computed(() => `${props.employee.attendance_percentage}%`)
</script>

<template>
  <section class="summary-panel">
    <header class="summary-panel__header">
      <div class="summary-panel__identity">
        <h2 class="summary-panel__name">{{ employee.employee_name }}</h2>
        <span class="summary-panel__id">{{ employee.employee_id }}</span>
      </div>
      <dl class="summary-panel__meta">
        <div class="summary-panel__meta-item">
          <dt>Manager</dt>
          <dd>{{ employee.manager ?? 'No manager assigned' }}</dd>
        </div>
        <div class="summary-panel__meta-item">
          <dt>Date of joining</dt>
          <dd>{{ formattedJoinDate }}</dd>
        </div>
      </dl>
    </header>

    <dl class="summary-panel__stats">
      <div class="stat">
        <dt class="stat__label">Avg. hours / day</dt>
        <dd class="stat__value">{{ formattedAvgHours }}</dd>
      </div>
      <div class="stat">
        <dt class="stat__label">Avg. login time</dt>
        <dd class="stat__value">{{ formattedAvgLogin }}</dd>
      </div>
      <div class="stat">
        <dt class="stat__label">Avg. logout time</dt>
        <dd class="stat__value">{{ formattedAvgLogout }}</dd>
      </div>
      <div class="stat">
        <dt class="stat__label">Attendance</dt>
        <dd class="stat__value">{{ formattedAttendance }}</dd>
      </div>
    </dl>
  </section>
</template>

<style scoped>
.summary-panel {
  border: 1px solid #e2e5eb;
  border-radius: 6px;
  background: #ffffff;
  padding: 20px 24px;
  font-family: 'Inter', ui-sans-serif, system-ui, sans-serif;
  color: #1a1f2b;
}

.summary-panel__header {
  display: flex;
  flex-wrap: wrap;
  align-items: baseline;
  justify-content: space-between;
  gap: 12px 24px;
  padding-bottom: 16px;
  border-bottom: 1px solid #e2e5eb;
}

.summary-panel__identity {
  display: flex;
  align-items: baseline;
  gap: 8px;
}

.summary-panel__name {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  letter-spacing: -0.01em;
}

.summary-panel__id {
  font-size: 13px;
  color: #6b7280;
  font-variant-numeric: tabular-nums;
}

.summary-panel__meta {
  display: flex;
  gap: 24px;
  margin: 0;
}

.summary-panel__meta-item dt {
  font-size: 12px;
  color: #6b7280;
  margin-bottom: 2px;
}

.summary-panel__meta-item dd {
  margin: 0;
  font-size: 13px;
  font-weight: 500;
}

.summary-panel__stats {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  margin: 16px 0 0;
}

.stat {
  border-left: 2px solid #e2e5eb;
  padding-left: 12px;
}

.stat__label {
  font-size: 12px;
  color: #6b7280;
  margin-bottom: 4px;
}

.stat__value {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
  font-variant-numeric: tabular-nums;
  letter-spacing: -0.01em;
}

@media (max-width: 640px) {
  .summary-panel__stats {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>