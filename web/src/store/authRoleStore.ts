import { defineStore } from "pinia";

/**
 * Which login role card was selected. Per docs/05_FRONTEND_WEB_RULES.md §6/§8,
 * this is a demo/hardcoded sign-in - CEO is the only role with a real
 * dashboard today, Manager/Employee route to `ComingSoonView`. This is
 * client-only UI state, not real authentication (the actual API calls still
 * run under the browser's existing Frappe session).
 */
export type PortalRole = "ceo" | "manager" | "employee";

const STORAGE_KEY = "analytics-portal:selected-role";

function isPortalRole(value: string | null): value is PortalRole {
  return value === "ceo" || value === "manager" || value === "employee";
}

function readStoredRole(): PortalRole | null {
  try {
    const stored = window.localStorage.getItem(STORAGE_KEY);
    return isPortalRole(stored) ? stored : null;
  } catch {
    return null;
  }
}

export const useAuthRoleStore = defineStore("authRole", {
  state: () => ({
    role: readStoredRole(),
  }),
  actions: {
    selectRole(role: PortalRole) {
      this.role = role;
      try {
        window.localStorage.setItem(STORAGE_KEY, role);
      } catch {
        // localStorage may be unavailable (private browsing) - role still
        // works for the current tab, just won't survive a refresh.
      }
    },
    signOut() {
      this.role = null;
      try {
        window.localStorage.removeItem(STORAGE_KEY);
      } catch {
        // see selectRole
      }
    },
  },
});
