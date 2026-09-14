import { apiCall } from "./client";
import { API_METHODS, PAGE_SIZE_DEFAULT } from "@/constants/apiConstants";
import type { PaginatedResponse } from "@/types/apiResponse";
import type { ActivityLogRow } from "@/types/activityLog";

export interface EmployeeLogsParams {
  employeeId: string;
  fromDate?: string | null;
  toDate?: string | null;
  start?: number;
  limit?: number;
}

/** Calls `employee_logs` - one paginated page of an employee's activity log. */
export function fetchEmployeeLogs(
  params: EmployeeLogsParams,
): Promise<PaginatedResponse<ActivityLogRow>> {
  return apiCall<PaginatedResponse<ActivityLogRow>>(API_METHODS.employeeLogs, {
    employee_id: params.employeeId,
    from_date: params.fromDate ?? undefined,
    to_date: params.toDate ?? undefined,
    start: params.start ?? 0,
    limit: params.limit ?? PAGE_SIZE_DEFAULT,
  });
}
