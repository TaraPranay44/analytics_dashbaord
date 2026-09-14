export interface EmployeeListRow {
  employee_id: string
  employee_name: string
  manager: string | null
  avg_hours_per_day: number
  avg_login_time: string | null
  status: string
}

export interface EmployeeTrendPoint {
  date: string
  hours: number
}

export interface EmployeeDetail {
  employee_id: string
  employee_name: string
  manager: string | null
  date_of_joining: string
  avg_hours_per_day: number
  avg_login_time: string | null
  avg_logout_time: string | null
  attendance_percentage: number
  trend: EmployeeTrendPoint[]
}