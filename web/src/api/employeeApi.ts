import { apiCall } from "./client";
import { API_METHODS, PAGE_SIZE_DEFAULT } from "@/constants/apiConstants";
import type { PaginatedResponse } from "@/types/apiResponse";
import type { EmployeeDetail, EmployeeListRow, MonthlyTrendPoint } from "@/types/employee";

export interface EmployeeListParams {
  q?: string;
  manager?: string | null;
  sort?: string | null;
  start?: number;
  limit?: number;
}

/** Calls `employee_list` - the paginated, filterable employee directory. */
export function fetchEmployeeList(
  params: EmployeeListParams,
): Promise<PaginatedResponse<EmployeeListRow>> {
  return apiCall<PaginatedResponse<EmployeeListRow>>(API_METHODS.employeeList, {
    q: params.q ?? "",
    manager: params.manager ?? undefined,
    sort: params.sort ?? undefined,
    start: params.start ?? 0,
    limit: params.limit ?? PAGE_SIZE_DEFAULT,
  });
}

/** Calls `employee_detail` - full identity + manager chain + summary + trend for one employee. */
export function fetchEmployeeDetail(employeeId: string): Promise<EmployeeDetail> {
  return apiCall<EmployeeDetail>(API_METHODS.employeeDetail, { employee_id: employeeId });
}

/** Calls `employee_monthly_trend` - lifetime monthly avg-hours series (not paginated - see docs/04_BACKEND_RULES.md §5). */
export function fetchEmployeeMonthlyTrend(employeeId: string): Promise<MonthlyTrendPoint[]> {
  return apiCall<MonthlyTrendPoint[]>(API_METHODS.employeeMonthlyTrend, { employee_id: employeeId });
}
