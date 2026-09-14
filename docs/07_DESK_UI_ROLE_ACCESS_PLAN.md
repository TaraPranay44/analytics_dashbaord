# Employee Analytics Portal — Desk UI Role & Access Plan

**Companion docs:** `01_MANAGERIAL_PLANNING.md` (roles), `04_BACKEND_RULES.md` (DocTypes/APIs).
**Scope:** Frappe's native back-office (`/desk` — confirmed 2026-09-14 against the
actual Frappe 16 source in this bench: there is no `frappe/www/app.py`, only
`frappe/www/desk.py`, and `get_url_to_workspace()` builds `/desk/<slug>`. Earlier
drafts of this doc said `/app`; that was wrong for this Frappe version and caused a
real bug — see §4) — **not** the custom portal (`web-login.html` etc.). This doc
exists because it's easy to conflate the two; they serve different people.

---

## 1. Two different interfaces — don't conflate them

| | Frappe Desk (`/desk`) | Custom Analytics Portal |
|---|---|---|
| What it is | The framework's built-in back-office: raw list views, forms, report builder, doctype CRUD | The polished, role-specific experience you've been designing (mesh-gradient login, employee list, per-employee dashboard) |
| Built for | Whoever maintains data and configures the system | CEO / Manager / Employee — the actual business users |
| Guardrails | None by default — full record edit/delete access to anything a role can see | Fully controlled UX — search, filters, pagination, read-only where appropriate |

**Recommendation: CEO / Manager / Employee should never need to see Desk in normal
use.** They log in and land straight on the custom portal. Desk is reserved for a
small internal **"Data Admin"** role (not one of the three business roles) — the
person who fixes a bad activity-log entry, re-runs a stuck scheduled job, or bulk-
imports new employees. Handing an executive raw Desk access means handing them
unrestricted record editing with no confirmation dialogs, no audit-friendly UI, and
every unrelated Frappe module (Website, Build, Settings, Users) cluttering their
view — which is exactly what your screenshot shows happening by default.

---

## 2. Role → Desk visibility matrix

| Role | Desk access at all? | What they'd see if they did log in |
|---|---|---|
| **Data Admin** (internal ops — a new role, not CEO/Manager/Employee) | Yes | The scoped "Employee Analytics Portal" workspace as their landing page (Employee, Employee Activity Log, Employee Monthly/Overall/Org Stats, Scheduled Job Log, RQ Job, Error Log), plus the Website module (Web Page, Web Form, Website Settings) via the `Website Manager` role — see §4.5. |
| **CEO / Executive** | No — bypassed entirely | N/A — redirected straight to the portal's dashboard on login |
| **Manager** (future scope) | No | N/A — redirected to the portal |
| **Employee** (future scope) | No | N/A — redirected to the portal |

This is a deliberate correction to the current default: right now, anyone who logs
in lands on `/desk` and sees whatever Frappe ships out of the box (the empty
"Framework" workspace, plus every default module once permissions are opened up).
None of the three business roles should ever be in that position.

---

## 3. How to actually implement this (Frappe mechanisms)

- **User Type — Website User vs. System User.** Business roles (CEO/Manager/
  Employee) should ultimately be **Website Users**, not System Users — Website
  Users never see `/desk` at all, only the portal. (Current phase uses hardcoded
  login per the original brief, so this is a Phase-3/4 hardening item, not
  something to build today — noted here so it's not forgotten.)
- **`hooks.py` → `role_home_page` / `get_website_user_home_page`.** Even for a
  System User, you can override the default post-login redirect per role, so
  logging in sends someone straight to the portal's dashboard route instead of
  `/desk`. Value must be a bare path with no leading slash, e.g.
  `"desk/<workspace-slug>"` for a public workspace — `frappe.website.utils.get_home_page()`
  strips slashes and resolves it relative to site root.
- **Workspace-level role restriction.** The `Workspace` doctype has a `Roles`
  child table — a workspace can be scoped so only specific roles ever see it in
  the sidebar. Use this to (a) give **Data Admin** a single relevant workspace,
  and (b) hide Frappe's default workspaces (Build, Website, Users, Settings, the
  empty "Framework" one) from every role that isn't Data Admin/System Manager.
- **Role Permission Manager.** Belt-and-braces underneath the workspace hiding —
  even if someone reaches Desk, DocType-level read/write permissions determine
  what they can actually see or touch.

---

## 4. Immediate fix for what's in your screenshot

**Status: implemented 2026-09-14.** The empty "Framework" workspace the
screenshot showed wasn't a missing workspace — the `Employee Analytics Portal`
workspace already existed and was synced. The real cause was that **every
DocPerm in this app was granted to `System Manager` only** — `Data Admin` had
zero read access to `Employee`, `Employee Activity Log`, the three Stats
doctypes, or the core `Scheduled Job Log` / `RQ Job` / `Error Log` doctypes
the workspace's "Jobs & Logs" card links to — so every shortcut in the
workspace rendered empty and search returned nothing. Fix applied:

1. ~~Create one new Workspace...~~ Already existed
   (`analytics_portal/workspace/employee_analytics_portal/`) — no change needed.
2. `role_home_page = {"Data Admin": "desk/employee-analytics-portal"}` added in
   `hooks.py` so Data Admin lands directly on it after login. **First attempt
   used `"app/employee-analytics-portal"`** (copying the `/app` terminology
   from earlier drafts of this doc) **and silently failed** — Desk rendered
   with an empty sidebar and no workspace content, because `/app` isn't a real
   route in this Frappe 16 install (see the corrected scope note at the top of
   this doc). Fixed to the `/desk` prefix.
3. Workspace `roles` table now restricts it to **Data Admin** and
   **System Manager** (`analytics_portal/workspace/employee_analytics_portal/employee_analytics_portal.json`).
4. **Granted, not hidden:** `Data Admin` was added to the `permissions` array
   of all 5 app-owned DocTypes (full CRUD on `Employee` and
   `Employee Activity Log`; read/report/export-only on the 3 Stats doctypes,
   preserving the "only the nightly jobs write these" rule from
   `04_BACKEND_RULES.md`). Read/report/export on `Scheduled Job Log`,
   `RQ Job`, `Error Log` is granted via `Custom DocPerm` fixtures (those are
   core doctypes, not owned by this app) — registered in `hooks.py`
   `fixtures` so the grant is reproducible on a fresh site, not a manual
   Desk click.
5. **The actual reason the sidebar stayed blank even after steps 1-4:**
   `analytics_portal/modules.txt` (the real source of the Module Def) says
   `EMPLOYEE ANALYTICS PORTAL`, but every doctype JSON and the workspace JSON
   had `"module": "Employee Analytics Portal"` (title case). Frappe's
   `Workspace.__init__` in `frappe/desk/desktop.py` checks
   `self.doc.module not in self.allowed_modules` with a plain, case-sensitive
   Python `in` — so the workspace's module never matched the user's allowed
   modules and it raised `frappe.PermissionError` on every load, silently
   swallowed by `get_workspaces()`'s try/except. DocPerm grants were
   irrelevant to this failure; the workspace itself was invisible regardless
   of them. Fixed by changing the `module` field to `EMPLOYEE ANALYTICS PORTAL`
   in all 5 doctype JSONs and the workspace JSON, then `bench migrate`.
   Verified server-side (impersonating `dataadmin@analyticsportal.test` in
   `bench console`) that `get_workspaces()` now lists "Employee Analytics
   Portal" and `frappe.get_list` succeeds on all 6 target doctypes.
6. **Revised 2026-09-14 — Website access, by explicit request:** unlike the
   original recommendation in §1 to keep Website/Build/Users out of Data
   Admin's view, product now wants Data Admin able to manage the Website
   module (Web Page, Web Form, Website Settings) from Desk directly. Rather
   than hand-rolling `Custom DocPerm`s for doctypes this app doesn't own,
   the `dataadmin@analyticsportal.test` user was granted Frappe's existing
   **`Website Manager`** role (verified in `tabDocPerm`: it already carries
   read/write/create on `Web Page`, `Web Form`, `Website Settings`) —
   composing a second standard role rather than duplicating its permissions
   onto `Data Admin`. The `Website` workspace itself was already `public=1`
   with no role restriction, so it was already visible to any System User;
   only doctype-level permission was missing. Hiding Frappe's other default
   workspaces (Build, Users, the empty "Framework" one) for non-System-Manager
   roles is still open and low priority.
6. Once business-role login exists for real (Phase 3/4), point CEO/Manager/
   Employee at the portal via the home-page override in §3, so they never see
   `/desk` in the first place.

---

## 5. Why this matters for the phased roadmap

This doc is a **Phase 3 (optimization/hardening) concern**, not something that
blocks Phase 1/2 delivery — but it's documented now so the Employee/Manager/Data
Admin role split doesn't get bolted on awkwardly later. See
`03_PHASED_ROADMAP.md` for where this fits.
