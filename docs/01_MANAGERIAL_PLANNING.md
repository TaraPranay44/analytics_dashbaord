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

> **⚠️ Correction note (post-review):** §6.1 originally described a "search →
> employee summary card" flow, as if a search returns exactly one match. It doesn't:
> at 30,000 employees, searching a common name like "Priya" can return **hundreds of
> matches**. A single large card with inline charts per result does not scale — it
> was replaced below with a paginated, filterable **employee list**. All rich
> per-employee content (charts, averages, trend data) now lives **only** on the
> Employee Detail Page (§6.2), reached by clicking a row. This also means the
> per-employee visual "dashboard" — charts and trends, not just a plain table — is
> explicitly part of §6.2, not a separate thing.

### 6.1 Executive Landing Page — Employee Directory
- Org-wide summary tiles at the top: headcount, average hours worked (org-wide,
  this month), attendance consistency indicator
- Search bar (auto-completing by name or ID, must stay responsive at 30K employees)
  plus lightweight filters (e.g. filter by manager, sort by name/hours) — filters and
  search operate on the same underlying list
- **Employee list, not a single result card:** a dense, paginated table/list of
  matching employees. Each row is compact — no charts, no multi-line summary — just
  the facts needed to identify and pick the right person:
  - Avatar + Name + Employee ID
  - Manager name
  - Avg. hours/day (a single number, not a chart)
  - Avg. login time
  - Status (e.g. Active / On leave)
- **Pagination is mandatory here, not optional** — with 30,000 employees, an
  unfiltered or common-name search can return hundreds to thousands of rows. The
  list always shows a page (e.g. 20–50 rows) with a "Showing X–Y of Z matches"
  footer and Prev/Next controls, never an unbounded scroll of every match.
- Clicking any row navigates to the Employee Detail Page (§6.2) — that page, not
  the list, is where the depth lives.

### 6.2 Employee Detail Page — the per-employee dashboard
This is where all the rich, per-employee analytics live — charts, averages, and
history — once the executive has picked a specific person from the list in §6.1.
- **Summary metrics:** avg. time spent/day, avg. login time, avg. logout time,
  date of joining, manager
- **Trend chart(s):** a visual view of the employee's hours/attendance over time
  (not just numbers) — this is the "dashboard" feel for that one employee
- **Daily activity log:** paginated, chronological, sortable table/list of
  individual day-by-day check-in/check-out records
- **Date-range filter:** This Week / This Month / Custom Range, applying to both
  the trend chart and the activity log
- **Line-management context:** manager chain shown (who this employee reports up to)

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
| Phase 2 | Web portal: search + filters, paginated employee list, detail page (with trend chart + activity log) |
| Phase 3 | Aggregation/caching layer hardened for scale; pagination everywhere |
| Phase 4 | Mobile app (own repo/architecture) against the same APIs |
| Phase 5 (future) | AI chatbot — revisit this document, not started now |
