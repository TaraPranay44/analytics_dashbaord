<script setup lang="ts">
import { computed } from "vue";
import type { DirectReport, ManagerChainEntry } from "@/types/employee";
import { employeeDetailPath } from "@/constants/routeConstants";
import { STRINGS } from "@/constants/stringConstants";
import { avatarGradientFor, initialsFor } from "@/utils/avatar";

const props = defineProps<{
  managerChain: ManagerChainEntry[];
  directReports: DirectReport[];
  loading: boolean;
}>();

const directManager = computed(() => props.managerChain[0] ?? null);
const restOfChain = computed(() => props.managerChain.slice(1));
</script>

<template>
  <div class="card org-hierarchy-card">
    <div v-if="loading" class="emp-table-status">{{ STRINGS.loadingLabel }}</div>
    <template v-else>
      <section class="hierarchy-section">
        <span class="filter-field-label">Manager</span>
        <router-link
          v-if="directManager"
          class="person-row person-row-link"
          :to="employeeDetailPath(directManager.employee_id)"
        >
          <div class="avatar-grad avatar-sm-fixed" :style="{ background: avatarGradientFor(directManager.employee_id) }">
            <span class="avatar-initials">{{ initialsFor(directManager.employee_name) }}</span>
          </div>
          <span class="person-name">{{ directManager.employee_name }}</span>
        </router-link>
        <p v-else class="muted text-xs">No manager on file — top of the chain.</p>

        <p v-if="restOfChain.length" class="hierarchy-chain-note">
          Reports up through:
          <template v-for="(manager, index) in restOfChain" :key="manager.employee_id">
            <router-link :to="employeeDetailPath(manager.employee_id)">{{ manager.employee_name }}</router-link
            ><span v-if="index < restOfChain.length - 1">, </span>
          </template>
        </p>
      </section>

      <section class="hierarchy-section">
        <span class="filter-field-label">Direct reports ({{ directReports.length }})</span>
        <div v-if="directReports.length" class="person-list">
          <router-link
            v-for="report in directReports"
            :key="report.employee_id"
            class="person-row person-row-link"
            :to="employeeDetailPath(report.employee_id)"
          >
            <div class="avatar-grad avatar-sm-fixed" :style="{ background: avatarGradientFor(report.employee_id) }">
              <span class="avatar-initials">{{ initialsFor(report.employee_name) }}</span>
            </div>
            <span class="person-name">{{ report.employee_name }}</span>
          </router-link>
        </div>
        <p v-else class="empty-state-note">No direct reports — individual contributor.</p>
      </section>
    </template>
  </div>
</template>
