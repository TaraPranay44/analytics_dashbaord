import { createRouter, createWebHistory } from "vue-router";
import { useAuthRoleStore, type PortalRole } from "@/store/authRoleStore";
import { ROUTE_NAMES, ROUTE_PATHS, comingSoonPath } from "@/constants/routeConstants";

// Maps the real Frappe role from boot data (window.portal_role, set by
// `www/analytics_portal.py`) to this app's own role keys. A real CEO/Manager/
// Employee login already proves who they are - the manual role-picker on
// `LoginView` only exists as a fallback for accounts with none of these
// roles (e.g. testing as Administrator).
function resolveRealRole(): PortalRole | null {
  switch (window.portal_role) {
    case "CEO":
      return "ceo";
    case "Manager":
      return "manager";
    case "Employee":
      return "employee";
    default:
      return null;
  }
}

function destinationForRole(role: PortalRole): string {
  return role === "ceo" ? ROUTE_PATHS.dashboard : comingSoonPath(role);
}

const router = createRouter({
  history: createWebHistory("/analytics-portal"),
  routes: [
    { path: "/", redirect: ROUTE_PATHS.login },
    {
      path: ROUTE_PATHS.login,
      name: ROUTE_NAMES.login,
      component: () => import("@/views/LoginView.vue"),
    },
    {
      path: ROUTE_PATHS.dashboard,
      name: ROUTE_NAMES.dashboard,
      component: () => import("@/views/DashboardView.vue"),
      meta: { requiresRole: "ceo" },
    },
    {
      path: ROUTE_PATHS.employeeDetail,
      name: ROUTE_NAMES.employeeDetail,
      component: () => import("@/views/EmployeeDetailView.vue"),
      meta: { requiresRole: "ceo" },
    },
    {
      path: ROUTE_PATHS.comingSoon,
      name: ROUTE_NAMES.comingSoon,
      component: () => import("@/views/ComingSoonView.vue"),
    },
  ],
});

// Client-only role gate (docs/05_FRONTEND_WEB_RULES.md §6/§8) - CEO is the
// only role with a real dashboard today; anything requiring a role the user
// hasn't picked bounces back to the login/role-select screen.
router.beforeEach((to) => {
  const authRole = useAuthRoleStore();

  // A real CEO/Manager/Employee login already tells us the role - adopt it
  // and skip straight past the manual picker, including on plain "/".
  const realRole = resolveRealRole();
  if (realRole) {
    if (authRole.role !== realRole) authRole.selectRole(realRole);
    if (to.name === ROUTE_NAMES.login) {
      return { path: destinationForRole(realRole) };
    }
  }

  const requiredRole = to.meta.requiresRole as string | undefined;
  if (!requiredRole) return true;

  if (authRole.role !== requiredRole) {
    return { path: ROUTE_PATHS.login };
  }
  return true;
});

export default router;
