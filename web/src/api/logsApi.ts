import { callApi } from './client'
import { API_METHODS } from '../constants/apiConstants'
import type { PaginatedResponse } from '../types/apiResponse'
import type { ActivityLogEntry } from '../types/activityLog'

export async function fetchEmployeeLogs(params: {
  employee_id: string
  from_date?: string
  to_date?: string
  start?: number
  limit?: number
}): Promise<PaginatedResponse<ActivityLogEntry>> {
  return callApi<PaginatedResponse<ActivityLogEntry>>(
    API_METHODS.EMPLOYEE_LOGS,
    params
  )
}