export interface ActivityLogEntry {
  date: string
  login_time: string | null
  logout_time: string | null
  total_hours: number
}