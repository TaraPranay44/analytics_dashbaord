import { callApi } from './client'
import { API_METHODS } from '../constants/apiConstants'
import type { OrgDashboard, OrgHierarchyNode } from '../types/org'

export async function fetchOrgDashboard(): Promise<OrgDashboard> {
  return callApi<OrgDashboard>(API_METHODS.ORG_DASHBOARD)
}

export async function fetchOrgHierarchy(employeeId: string): Promise<OrgHierarchyNode> {
  return callApi<OrgHierarchyNode>(API_METHODS.ORG_HIERARCHY, {
    employee_id: employeeId,
  })
}