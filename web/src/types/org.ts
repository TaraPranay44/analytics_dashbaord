export interface OrgDashboard {
  date: string | null
  total_employees: number
  avg_hours_org: number
  avg_login_time_org: string | null
}

export interface OrgHierarchyNode {
  employee_id: string
  employee_name: string
  manager: string | null
  direct_reports: OrgHierarchyNode[]
}