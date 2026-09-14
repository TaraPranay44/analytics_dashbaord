import { apiCall } from "./client";
import { API_METHODS } from "@/constants/apiConstants";
import type { OrgDashboard, OrgHierarchy, OrgInsights } from "@/types/employee";

/** Calls `org_dashboard` - org-wide tiles + history for the landing dashboard header. */
export function fetchOrgDashboard(): Promise<OrgDashboard> {
  return apiCall<OrgDashboard>(API_METHODS.orgDashboard);
}

/** Calls `org_insights` - supplementary real-data callouts for the dashboard's insight chips. */
export function fetchOrgInsights(): Promise<OrgInsights> {
  return apiCall<OrgInsights>(API_METHODS.orgInsights);
}

/** Calls `org_hierarchy` - manager chain and direct reports for one employee. */
export function fetchOrgHierarchy(employeeId: string): Promise<OrgHierarchy> {
  return apiCall<OrgHierarchy>(API_METHODS.orgHierarchy, { employee_id: employeeId });
}
