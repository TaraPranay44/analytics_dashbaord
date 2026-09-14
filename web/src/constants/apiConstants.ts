export const API_NAMESPACE = 'analytics_portal.api.v1'

export const API_METHODS = {
  EMPLOYEE_LIST: `${API_NAMESPACE}.employee.employee_list`,
  EMPLOYEE_DETAIL: `${API_NAMESPACE}.employee.employee_detail`,
  EMPLOYEE_LOGS: `${API_NAMESPACE}.logs.employee_logs`,
  ORG_DASHBOARD: `${API_NAMESPACE}.org.org_dashboard`,
  ORG_HIERARCHY: `${API_NAMESPACE}.org.org_hierarchy`,
} as const

export const PAGE_SIZE_DEFAULT = 20
export const PAGE_SIZE_MAX = 100
