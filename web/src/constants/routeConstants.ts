export const ROUTE_NAMES = {
  LOGIN: 'login',
  DASHBOARD: 'dashboard',
  EMPLOYEE_DETAIL: 'employee-detail',
  COMING_SOON: 'coming-soon',
  ORG_HIERARCHY: 'org-hierarchy',
} as const

export const ROUTE_PATHS = {
  LOGIN: '/',
  DASHBOARD: '/dashboard',
  EMPLOYEE_DETAIL: '/employee/:employeeId',
  COMING_SOON: '/coming-soon',
  ORG_HIERARCHY: '/org-hierarchy/:employeeId',
} as const