# Employee Analytics Portal — Managerial & Functional Planning

**Document owner:** Product/Program Planning
**Status:** Draft v1
**Companion doc:** `02_TECHNICAL_PLANNING.md` (architecture, stack, data flow)

---

## 1. Purpose of this document

This document defines **what** we are building and **why**, independent of technology
choices. It is the reference for scope sign-off, stakeholder alignment, and phased
delivery. The technical planning document defines **how** it will be built.

---

## 2. Problem statement

Executives (CEO and leadership) currently have no consolidated, real-time view of:
- Who reports to whom (org/line-management hierarchy)
- How consistently employees are logging in/out
- How many hours are actually being worked, per employee, per team, over time

They need a single dashboard to search any employee and drill into their attendance
and work-duration history, without depending on HR pulling manual reports.

---

## 3. Scope assessment — where the original brief sits, and where we're taking it

The original assignment, taken literally, is a **3/10 scope**: one role, one dataset,
one UI surface (a search box + a detail page), no stated scale, no stated
non-functional requirements. It would pass as a CRUD-with-a-dashboard exercise.

Given the real constraint that surfaced afterward — **30,000 employees, each with
~365 days of daily activity logs (≈11M+ log rows just for year one, growing daily)**
— treating this as a simple CRUD app is actually the wrong answer. At this scale,
naive "compute the average on page load" logic will not work. That single fact is
what pushes this from a tutorial-scope exercise to an enterprise-scope one.

We are deliberately expanding scope along three axes to bring this to an **8/10**:

1. **Depth on the core deliverable** — precomputed analytics, real filtering,
   real pagination, real caching — so the CEO dashboard stays fast at 30K+ employees.
2. **Breadth of surface** — not just a web view, but a mobile-ready experience,
   planned as its own architecture track from day one (not bolted on later).
3. **Forward path, clearly fenced off** — an AI chatbot layer is named, scoped at a
   paragraph level, and explicitly marked **future scope**, so it doesn't dilute
   effort on the current deliverable but also isn't a surprise later.

What we are **not** doing (explicitly out of scope for this phase):
- Real authentication/SSO work (hardcoded login, per instructions)
- The AI chatbot itself (planning only, see §7)
- Payroll, leave management, or any HR workflow beyond attendance/activity analytics

---

## 4. Modules (program structure)

| # | Module | What it is | Status |
|---|--------|-----------|--------|
| 1 | **Backend + Web Portal** | Frappe backend (DocTypes, APIs, jobs) and the executive-facing web dashboard. Planned together because the web app is the backend's first consumer and shapes the API contract. | **In scope, this phase** |
| 2 | **Mobile Application** | A separate client consuming the same backend APIs. Different architecture, different state-management model, different release cadence. | **In scope, this phase — planned as an independent track** |
| 3 | **AI Chatbot** | Natural-language querying over the analytics data ("How many hours did X work last month?"). | **Future scope — documented only, not architected in depth** |

Modules 1 and 2 share one backend and one API contract. Module 3 is a placeholder
so future engineering doesn't have to re-litigate scope.

---

## 5. Roles & access

The login screen (web and mobile) presents **three role buttons — CEO, Manager,
Employee** — so the role model is visible and real from day one, even though only one
role is functional right now.

| Role | Access | Status |
|---|---|---|
| **CEO / Executive** | Full read visibility: all employees, all activity logs, all dashboards, org-wide aggregates | **Built now** |
| **Manager** | Limited analytics — visibility restricted to employees under them (direct + indirect reports) only, not org-wide | **Future scope — button present, not functional yet** |
| **Employee** | Self-service — mark own attendance (check-in/check-out) and view own activity history | **Future scope — button present, not functional yet** |

Only the CEO role is being built this phase, matching the current priority. The
permission model underneath (Frappe's role-based permission engine) is designed now
so Manager and Employee can be switched on later without a data-model rewrite:
- Manager's "limited analytics" is a natural filter on the existing `manager` link
  field already in the Employee DocType — no schema change needed later
- Employee's "mark attendance" is a natural write-path into the existing
  `Employee Activity Log` DocType — no schema change needed later

This is why the login screen shows all three buttons now: it signals the target
shape of the product without requiring Manager/Employee logic to be built before
the CEO experience is solid.

---

## 6. Functional deliverables (this phase)

### 6.1 Executive Search & Landing Dashboard
- Auto-completing search by employee name or ID (must stay responsive at 30K employees)
- Org-wide summary tiles: headcount, average hours worked (org-wide, this month),
  attendance consistency indicator
- Employee summary card on search/select:
  - Name, ID, Manager, Date of Joining
  - Average time spent (overall + monthly)
  - Average daily login time
  - "View full history" action → Employee Detail Page

### 6.2 Employee Detail Page
- Summary metrics card: avg. time spent/day, avg. login time, avg. logout time,
  date of joining, manager
- Daily activity log table: paginated, chronological, sortable
- Date-range filter: This Week / This Month / Custom Range
- Line-management context: manager chain shown (who this employee reports up to)

### 6.3 Org / Line-management view (scope addition)
- Simple hierarchy view so an executive can see a manager and their reporting line
  without leaving the portal — a natural companion to "who manages whom," which the
  data model already supports via the Manager link field.

### 6.4 Data volume the design must hold up under
- 30,000 Employee records
- ~365 Employee Activity Log records per employee per year → **~10.95M rows in year one**,
  growing by ~30,000 rows/day thereafter
- This number is the design constraint referenced throughout the technical plan.

---

## 7. Future scope — AI Chatbot (not built this phase)

A conversational layer where an executive can ask questions in plain language
("Who on my team logged the least hours last month?") and get an answer sourced from
the same analytics data. This is named here so it's on record as a planned direction,
but deliberately **not architected** in the technical document beyond a short
placeholder section — building it now would pull effort away from making the core
portal actually enterprise-solid at 30K-employee scale, which is the higher-value bar
to clear first.

---

## 8. Success criteria for this phase

- CEO can find any employee out of 30,000 in under ~1 second via search
- Employee Detail Page loads and paginates smoothly over a full year of logs
- Dashboard aggregates (averages) do not recompute over raw rows on every page load
- Mobile app consumes the exact same backend APIs as web — no parallel backend logic
- Codebase and data model are structured so Manager/Employee self-service roles and
  the future chatbot can be added without re-architecting

---

## 9. Phased delivery view

| Phase | Deliverable |
|---|---|
| Phase 1 | DocTypes, seed data at scale (30K employees, 1 year of logs), core APIs |
| Phase 2 | Web portal: search, summary card, detail page, filters |
| Phase 3 | Aggregation/caching layer hardened for scale; pagination everywhere |
| Phase 4 | Mobile app (own repo/architecture) against the same APIs |
| Phase 5 (future) | AI chatbot — revisit this document, not started now |
