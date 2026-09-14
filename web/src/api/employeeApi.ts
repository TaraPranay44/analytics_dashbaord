import { callApi } from './client'
import { API_METHODS } from '../constants/apiConstants'
import type { PaginatedResponse } from '../types/apiResponse'
import type { EmployeeListRow, EmployeeDetail } from '../types/employee'

export async function fetchEmployeeList(params: {
  q?: string
  manager?: string
  sort?: string
  start?: number
  limit?: number
}): Promise<PaginatedResponse<EmployeeListRow>> {
  return callApi<PaginatedResponse<EmployeeListRow>>(
    API_METHODS.EMPLOYEE_LIST,
    params
  )
}

export async function fetchEmployeeDetail(
  employeeId: string
): Promise<EmployeeDetail> {
  return callApi<EmployeeDetail>(API_METHODS.EMPLOYEE_DETAIL, {
    employee_id: employeeId,
  })
}