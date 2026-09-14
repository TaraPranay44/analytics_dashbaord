<script setup lang="ts">
import type { OrgHierarchyNode } from '../types/org'

interface Props {
  node: OrgHierarchyNode
}

defineProps<Props>()
</script>

<template>
  <ul class="org-node">
    <li>
      <div class="org-node__person">
        <span class="org-node__name">{{ node.employee_name }}</span>
        <span class="org-node__id">{{ node.employee_id }}</span>
      </div>

      <OrgHierarchyView
        v-for="report in node.direct_reports"
        :key="report.employee_id"
        :node="report"
      />
    </li>
  </ul>
</template>

<style scoped>
.org-node {
  list-style: none;
  margin: 0;
  padding-left: 20px;
  font-family: 'Inter', ui-sans-serif, system-ui, sans-serif;
  font-size: 13px;
}

.org-node > li {
  border-left: 1px solid #e2e5eb;
  padding-left: 12px;
  padding-bottom: 6px;
}

.org-node__person {
  display: flex;
  align-items: baseline;
  gap: 8px;
  padding: 4px 0;
}

.org-node__name {
  font-weight: 500;
}

.org-node__id {
  font-size: 11px;
  color: #6b7280;
}
</style>