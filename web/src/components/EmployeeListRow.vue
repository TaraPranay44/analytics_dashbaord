<script setup lang="ts">
import { computed } from "vue";
import type { EmployeeListRow } from "@/types/employee";
import { formatHours, formatTimeOfDay } from "@/utils/formatDuration";
import { employeeDetailPath } from "@/constants/routeConstants";
import { avatarGradientFor, initialsFor } from "@/utils/avatar";

const props = defineProps<{ employee: EmployeeListRow; lowHoursThreshold: number | null }>();

const initials = computed(() => initialsFor(props.employee.employee_name));
const avatarGradient = computed(() => avatarGradientFor(props.employee.employee_id));

// Real, derived from `org_insights.low_hours_threshold` (avg_hours_org minus
// a fixed margin) - not a fabricated status field. See docs/05 §6.
const isLowHours = computed(
  () =>
    props.lowHoursThreshold !== null &&
    props.employee.avg_hours_overall !== null &&
    props.employee.avg_hours_overall < props.lowHoursThreshold,
);
</script>

<template>
  <div class="emp-row" :class="{ 'emp-row-flagged': isLowHours }">
    <div class="emp-cell-name">
      <div class="avatar-grad" :style="{ background: avatarGradient }">
        <span class="avatar-initials">{{ initials }}</span>
      </div>
      <div class="txt">
        <div class="txt-name-row">
          <strong>{{ employee.employee_name }}</strong>
          <span v-if="isLowHours" class="badge-low-hours">Low hrs</span>
        </div>
        <span>{{ employee.employee_id }}</span>
      </div>
    </div>
    <div class="hide-mobile">{{ employee.manager_name ?? "—" }}</div>
    <div>{{ formatHours(employee.avg_hours_overall) }}</div>
    <div class="hide-mobile">{{ formatTimeOfDay(employee.avg_login_time_overall) }}</div>
    <div>
      <router-link class="btn btn-ghost btn-sm" :to="employeeDetailPath(employee.employee_id)">
        View
      </router-link>
    </div>
  </div>
</template>
