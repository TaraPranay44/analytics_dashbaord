export const ROUTE_NAMES = {
  login: "login",
  dashboard: "dashboard",
  employeeDetail: "employee-detail",
  comingSoon: "coming-soon",
} as const;

export const ROUTE_PATHS = {
  login: "/login",
  dashboard: "/dashboard",
  employeeDetail: "/employees/:employeeId",
  comingSoon: "/coming-soon/:role",
} as const;

export function employeeDetailPath(employeeId: string): string {
  return `/employees/${encodeURIComponent(employeeId)}`;
}

export type ComingSoonRole = "manager" | "employee";

export function comingSoonPath(role: ComingSoonRole): string {
  return `/coming-soon/${role}`;
}
