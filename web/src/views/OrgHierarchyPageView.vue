<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useOrgHierarchy } from '../composables/useOrgHierarchy'
import OrgHierarchyView from '../components/OrgHierarchyView.vue'

const route = useRoute()
const employeeId = computed(() => String(route.params.employeeId))

const { managerChain, directReports, isLoading, isError } = useOrgHierarchy(employeeId)
</script>

<template>
  <div class="org-hierarchy-page">
    <button type="button" class="back-link" @click="$router.back()">
      ← Back
    </button>

    <h2 class="org-hierarchy-page__title">Reporting structure</h2>

    <div v-if="isLoading" class="state-message">Loading hierarchy…</div>
    <div v-else-if="isError" class="state-message state-message--error">
      Couldn't load the reporting structure.
    </div>
    <OrgHierarchyView
  v-else
  :manager-chain="managerChain"
  :direct-reports="directReports"
  :loading="isLoading"
/>
  </div>
</template>

<style scoped>
.org-hierarchy-page {
  display: flex;
  flex-direction: column;
  gap: 16px;
  padding: 20px;
  font-family: 'Inter', ui-sans-serif, system-ui, sans-serif;
}

.back-link {
  align-self: flex-start;
  background: none;
  border: none;
  color: #3b5bdb;
  font-size: 13px;
  cursor: pointer;
  padding: 0;
}

.org-hierarchy-page__title {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
}

.state-message {
  padding: 24px 0;
  text-align: center;
  color: #6b7280;
  font-size: 13px;
}

.state-message--error {
  color: #c0392b;
}
</style>