# Employee Analytics Portal — Desk UI Role & Access Plan

**Companion docs:** `01_MANAGERIAL_PLANNING.md` (roles), `04_BACKEND_RULES.md` (DocTypes/APIs).
**Scope:** Frappe's native back-office (`/app`, shown as `/desk` in your screenshot) —
**not** the custom portal (`web-login.html` etc.). This doc exists because it's easy to
conflate the two; they serve different people.

---

## 1. Two different interfaces — don't conflate them

| | Frappe Desk (`/app`) | Custom Analytics Portal |
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
| **Data Admin** (internal ops — a new role, not CEO/Manager/Employee) | Yes | A single scoped workspace: Employee, Employee Activity Log, Employee Monthly/Overall/Org Stats, Scheduled Job Log, Error Log. Nothing else. |
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
  Users never see `/app` at all, only the portal. (Current phase uses hardcoded
  login per the original brief, so this is a Phase-3/4 hardening item, not
  something to build today — noted here so it's not forgotten.)
- **`hooks.py` → `role_home_page` / `get_website_user_home_page`.** Even for a
  System User, you can override the default post-login redirect per role, so
  logging in sends someone straight to the portal's dashboard route instead of
  `/app`.
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

The empty "Framework" workspace is Frappe's out-of-the-box default — it hasn't
been replaced with anything belonging to this app yet. See the step-by-step
walkthrough for the concrete fix (create a proper "Employee Analytics" workspace,
hide the defaults, restrict by role). At a glance, the fix is:

1. Create one new Workspace named "Employee Analytics" with a proper icon/color
   and shortcut cards to the DocTypes that matter (Employee, Employee Activity
   Log, the Stats doctypes).
2. Set it as the default workspace so it's what appears immediately after login.
3. Restrict it to the **Data Admin** role via the workspace's `Roles` table.
4. Hide or unpin Frappe's default workspaces (Home, Build, Website, Users,
   Settings) for every role except System Manager.
5. Once business-role login exists for real (Phase 3/4), point CEO/Manager/
   Employee at the portal via the home-page override in §3, so they never see
   `/app` in the first place.

---

## 5. Why this matters for the phased roadmap

This doc is a **Phase 3 (optimization/hardening) concern**, not something that
blocks Phase 1/2 delivery — but it's documented now so the Employee/Manager/Data
Admin role split doesn't get bolted on awkwardly later. See
`03_PHASED_ROADMAP.md` for where this fits.
