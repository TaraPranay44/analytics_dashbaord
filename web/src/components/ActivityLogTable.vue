<script setup lang="ts">
import type { ActivityLogRow } from "@/types/activityLog";
import { formatDateLabel } from "@/utils/formatDate";
import { formatClockTime, formatHours } from "@/utils/formatDuration";
import { STRINGS } from "@/constants/stringConstants";

defineProps<{
  rows: ActivityLogRow[];
  loading: boolean;
}>();

/** "In progress" (no logout yet) vs "Completed" - both directly derivable
 * from `logout_time`, no invented on-time/late judgment. */
function statusFor(row: ActivityLogRow): { label: string; dotClass: string } {
  if (!row.logout_time) return { label: "In progress", dotClass: "dot-brand" };
  return { label: "Completed", dotClass: "dot-success" };
}
</script>

<template>
  <div class="card log-card">
    <div class="log-table-head">
      <span>DATE</span>
      <span>LOGIN</span>
      <span>LOGOUT</span>
      <span>HOURS</span>
      <span>STATUS</span>
    </div>
    <div v-if="loading" class="emp-table-status">{{ STRINGS.loadingLabel }}</div>
    <template v-else-if="rows.length">
      <div class="log-row" v-for="row in rows" :key="`${row.employee}-${row.date}`">
        <div>{{ formatDateLabel(row.date) }}</div>
        <div class="hide-mobile">{{ formatClockTime(row.login_time) }}</div>
        <div class="hide-mobile">{{ formatClockTime(row.logout_time) }}</div>
        <div>{{ formatHours(row.total_hours) }}</div>
        <div class="status-cell">
          <span class="dot-status" :class="statusFor(row).dotClass"></span>{{ statusFor(row).label }}
        </div>
      </div>
    </template>
    <div v-else class="emp-table-status">{{ STRINGS.noLogs }}</div>
  </div>
</template>
