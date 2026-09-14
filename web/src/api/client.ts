import { call } from "frappe-ui";

/**
 * Thin wrapper around frappe-ui's `call` - Frappe's session/CSRF handling
 * stays inside frappe-ui (docs/05_FRONTEND_WEB_RULES.md §3: "use its
 * session/auth handling, don't hand-roll a parallel auth client"). Every
 * `api/*Api.ts` function goes through this - no `.vue` file calls `call`
 * directly.
 */
export function apiCall<T>(method: string, params: Record<string, unknown> = {}): Promise<T> {
  return call(method, params) as Promise<T>;
}
