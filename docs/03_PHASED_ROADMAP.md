# Employee Analytics Portal — Phased Roadmap

**Companion docs:** `01_MANAGERIAL_PLANNING.md` (scope/roles), `02_TECHNICAL_PLANNING.md` (architecture)

This document sequences the whole program into four phases. **Phases 1–2 are current
scope** (being built now). **Phase 3 is optimization scope** (hardening what's built
for the 30,000-employee / 11M+ row reality). **Phase 4 is future scope** (not started,
recorded so nothing is a surprise later).

---

## Phase 1 — Foundation: Backend + Web (CEO role) — **Current scope**

The core deliverable from the original brief, built correctly for scale from the start.

- DocTypes: `Employee`, `Employee Activity Log` (standalone, indexed on `(employee, date)`)
- Aggregate DocTypes: `Employee Monthly Stats`, `Employee Overall Stats`
- Seed data: 30,000 Employee records, ~365 Employee Activity Log rows each (1 year)
- Whitelisted, versioned, paginated REST API layer (no unbounded queries anywhere)
- Nightly scheduled job (Frappe RQ) to populate/refresh the aggregate tables
- Web app (Vue 3 + `frappe-ui`, Pinia + TanStack Query):
  - Login screen with **CEO / Manager / Employee** buttons — only CEO active,
    Manager/Employee route to a "coming soon" placeholder
  - CEO landing dashboard: org-wide tiles + auto-completing employee search + filters
  - **Paginated, filterable employee list** (compact rows — no inline charts; a
    common-name search can return hundreds of matches, so this must page, not
    single-card) — corrected from an earlier "employee summary card" version of
    this doc, which assumed a search returns one match
  - Employee Detail Page: summary metrics, **trend chart(s)**, paginated activity
    log table, date-range filter — all the rich per-employee analytics live here,
    reached by clicking a row in the list
  - Simple line-management/hierarchy view

**Exit criteria:** CEO can search any of 30,000 employees in ~1s, and open a full
year of paginated logs without the page choking.

---

## Phase 2 — Mobile (CEO role) — **Current scope**

Same functional surface as web, built as its own architecture track, sharing only
the backend API contract.

- Flutter app, Riverpod for state management
- Dio for networking against the Phase 1 API layer (no new backend endpoints needed)
- Isar for local caching of last-fetched summaries/logs (offline-friendly reads)
- Same three-button login screen (CEO active, Manager/Employee "coming soon")
- CEO experience: search + filters, paginated employee list, detail page (with
  trend chart + activity log) — parity with web, not a subset

**Exit criteria:** CEO can do everything on mobile that they can on web, against the
exact same API — no parallel backend logic written for mobile.

---

## Phase 3 — Optimization — **Optimization scope**

This phase exists specifically because of the 30,000-employee / 11M+ row constraint.
Nothing new is added functionally here — the goal is to prove Phases 1–2 hold up
under real load and to close any gaps found.

- **Load testing:** Locust (or similar) run against search and detail-page endpoints
  seeded with the full 30K/11M dataset — this is the evidence the aggregate-table
  approach actually works, not just an assumption
- **Caching pass:** confirm Redis TTLs on search/summary reads are tuned correctly;
  add cache invalidation hooks where the load test reveals stale-data risk
- **Query/index audit:** `EXPLAIN` on every list/filter query against the real dataset
  size; add any missing composite indexes surfaced by the audit
- **Pagination audit:** verify every list-returning endpoint enforces a server-side
  max page size (not just a client-side default)
- **Read replica evaluation:** decide, based on load-test numbers, whether a MariaDB
  read replica is needed now or can wait
- **Observability pass:** structured logs on the nightly aggregation job (rows
  processed, duration, failures), basic latency metrics on the API layer
- **Data growth plan:** confirm the year-based partitioning plan for
  `Employee Activity Log` (from the technical doc) with an actual row-count projection

**Exit criteria:** load test results documented, showing dashboard/search/detail-page
latency stays acceptable at full 30K/11M scale; any gaps found are fixed, not just noted.

---

## Phase 4 — Future scope (not started)

Recorded for continuity; the permission model and data model from Phases 1–3 are
deliberately designed so none of this requires a rebuild.

- **Manager role:** dashboard reuses CEO's endpoints with a server-side filter to
  direct + indirect reports (via the existing `manager` link field) — limited
  analytics, not org-wide
- **Employee role:** self-service — mark check-in/check-out (new write path into the
  existing `Employee Activity Log` DocType) and view own activity history (existing
  detail-page endpoint, filtered to self); mobile check-in queues offline via Isar
  and syncs via Dio when connectivity returns
- **Login screen buttons for Manager/Employee** go from "coming soon" to fully wired,
  on both web and mobile
- **AI Chatbot:** natural-language querying over the aggregate tables (e.g. "who
  worked the fewest hours last month"), sitting behind the same API layer — see
  the technical planning doc §7 for the one-paragraph placeholder; not scoped in
  detail until this phase is actually picked up

**This phase is not scheduled.** It's here so that when it is picked up, the team
isn't starting from zero on the data model or permission design.

---

## Phase summary

| Phase | Focus | Status |
|---|---|---|
| 1 | Backend + Web, CEO role | Current scope |
| 2 | Mobile, CEO role | Current scope |
| 3 | Load testing, caching/index/pagination audit, observability | Optimization scope |
| 4 | Manager role, Employee role, AI Chatbot | Future scope |
