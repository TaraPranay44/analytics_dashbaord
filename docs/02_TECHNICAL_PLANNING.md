# Employee Analytics Portal — Technical Planning

**Companion doc:** `01_MANAGERIAL_PLANNING.md` (scope, roles, functional deliverables)
**Design constraint driving every decision below:** 30,000 employees × ~365 activity-log
rows/year ≈ **11M+ rows in year one**, growing ~30K rows/day. Every choice here exists
to make that number a non-issue.

---

## 1. Top-level architecture

```
┌───────────────────────────────┐        ┌───────────────────────────────┐
│         WEB CLIENT             │        │        MOBILE CLIENT          │
│  Vue 3 SPA (Frappe UI based)   │        │  Flutter (own architecture)   │
└───────────────┬────────────────┘        └───────────────┬────────────────┘
                │  REST/JSON (whitelisted)                │  same REST/JSON API
                └───────────────┬──────────────────────────┘
                                ▼
                 ┌─────────────────────────────────┐
                 │        FRAPPE BACKEND (API)       │
                 │  - Whitelisted API layer           │
                 │  - DocType controllers/hooks       │
                 │  - Scheduler jobs (aggregation)     │
                 │  - Background workers (RQ)          │
                 └───────┬───────────────┬───────────┘
                         │               │
                 ┌───────▼─────┐   ┌─────▼──────┐
                 │  MariaDB     │   │   Redis     │
                 │ (source of   │   │ cache + job │
                 │  truth +     │   │  queue      │
                 │  aggregate   │   │  broker     │
                 │  tables)     │   └─────────────┘
                 └──────────────┘

        [Future, not built now]
        ┌─────────────────────────┐
        │  AI Chatbot service      │  → calls the same API layer, adds
        │  (RAG over aggregates)   │    an LLM + vector store on top
        └─────────────────────────┘
```

**Key principle: API-first backend.** The web app is not a Frappe Desk customization
consuming Desk internals directly — it's a client of a versioned, whitelisted REST API.
This is what lets the mobile module (§6) reuse the backend with zero duplication, and
is what makes the future chatbot (§8) a bolt-on instead of a rewrite.

---

## 2. Data model

### 2.1 `Employee` (extends/wraps Frappe's standard Employee where practical)
| Field | Type | Notes |
|---|---|---|
| employee_name | Data | |
| employee_id | Data (unique, indexed) | primary lookup key |
| manager | Link → Employee | self-referential, powers hierarchy |
| date_of_joining | Date | |
| user | Link → User | ties to login identity |

Index: composite index on `(employee_id)` and `(manager)` — the manager index matters
once hierarchy views are queried at 30K-employee scale.

### 2.2 `Employee Activity Log` — **standalone DocType, not a child table**
At 11M+ rows/year this must NOT be a child table (child tables are fine at hundreds
or low thousands of rows per parent; they are the wrong choice at this volume — every
parent save re-touches child rows and list views don't paginate child tables well).

| Field | Type | Notes |
|---|---|---|
| employee | Link → Employee | indexed |
| date | Date | indexed |
| login_time | Datetime | |
| logout_time | Datetime | |
| total_hours | Float | **computed server-side** in `before_save`, never trusted from client |

**Composite index on `(employee, date)`** — this single index is what makes "get this
employee's logs for a date range" an indexed range scan instead of a table scan across
11M rows.

### 2.3 Aggregate tables (the scale-critical addition)

This is the single biggest difference between a 3/10 and an 8/10 submission. Computing
"average time spent" or "average login time" by scanning raw logs on every dashboard
load does not survive 30K employees. Instead:

**`Employee Monthly Stats`** (one row per employee per month)
- employee, year_month, avg_hours, avg_login_time, avg_logout_time, days_present

**`Employee Overall Stats`** (one row per employee, rolling lifetime aggregate)
- employee, avg_hours_overall, avg_login_time_overall, avg_logout_time_overall, last_computed

These are populated by a scheduled job (§3.3), not computed on request. The summary
card and detail page read from these tables — O(1) lookups instead of aggregation
over the full log history every time a card renders.

**Org-wide aggregate row(s)** for the landing dashboard tiles, same principle.

---

## 3. Backend architecture (Frappe)

### 3.1 API layer
- All read endpoints are `@frappe.whitelist(methods=["GET"])` functions, versioned
  under a clear namespace (e.g. `/api/method/analytics_portal.api.v1.*`)
- Every list endpoint takes `limit`, `start`/cursor, and explicit filters — **no
  endpoint returns an unbounded result set**, given the row counts involved
- Search endpoint: backed by the indexed `employee_id`/`employee_name` columns;
  at this scale a simple `LIKE` with a leading-index-friendly pattern plus a hard
  `limit` is sufficient — no need for a separate search engine unless free-text
  search over unstructured fields is added later

### 3.2 Caching (Redis)
- Search-as-you-type results and the landing-page org tiles are cached with a short
  TTL (e.g. 60–120s) — these are read far more often than they change
- Employee summary card (from the aggregate tables) is cached per employee, invalidated
  on the next scheduled aggregation run rather than on every write, since these are
  daily-granularity stats, not real-time
- Redis doubles as the broker for the background job queue (§3.3), which is Frappe's
  built-in pattern — no separate infrastructure needed

### 3.3 Background jobs / queue
- Frappe ships with RQ-based background workers (`frappe.enqueue`) — used for:
  - Nightly job: recompute `Employee Monthly Stats` for the prior day/month bucket
  - Nightly job: refresh `Employee Overall Stats`
  - On-demand job: bulk recompute if historical data is corrected
- Jobs are queued on a dedicated low-priority queue so they never compete with
  interactive request handling
- This is what lets "average time spent" stay instant for the CEO instead of being
  computed live over a year of logs on every page view

### 3.4 Pagination
- Every list-returning endpoint (activity log table, employee search) is cursor- or
  offset-paginated with a server-enforced max page size — this is non-negotiable
  at 11M+ rows and is treated as a correctness requirement, not a nice-to-have

### 3.5 Scalability posture
- Stateless API workers (Gunicorn) behind a load balancer → horizontal scale-out
- Background workers scaled independently from web workers (different concern,
  different load profile)
- MariaDB: read replica for the analytics/reporting read path once traffic warrants
  it, keeping the primary free for writes (log ingestion)
- Data growth: at ~30K rows/day, partitioning `Employee Activity Log` by year is a
  planned future step (noted here, not needed on day one) once multi-year history
  accumulates

### 3.6 Observability
- Frappe's built-in Error Log for exceptions
- Structured logging for job runs (aggregation success/failure, row counts processed)
- Basic metrics (request latency, queue depth) exported for Prometheus/Grafana if the
  hosting environment supports it — flagged as an easy add given Frappe's hooks, not
  required to demonstrate the core assignment

### 3.7 Testing
- Frappe's standard test framework for DocType validation logic (e.g. `total_hours`
  calculation correctness)
- A basic load-test script (Locust or similar) against the search and detail-page
  endpoints, seeded with the 30K-employee / 11M-row dataset, to prove the
  aggregate-table approach actually holds up — this is the evidence that closes the
  loop on the scale requirement

---

## 4. Website (frontend) architecture

- **Framework:** Vue 3, using Frappe's own `frappe-ui` component library — this keeps
  the frontend idiomatic to the Frappe ecosystem (auth/session handling, API client
  conventions) rather than fighting the framework
- **State management:**
  - **Server state** (employee data, logs, aggregates): TanStack Query (`@tanstack/vue-query`)
    — handles caching, background refetch, and pagination state without hand-rolled
    Redux/Vuex boilerplate. This matters because most of this app's "state" is really
    server data, not client-only UI state.
  - **Client/UI state** (selected date range, active filters, search box state): Pinia,
    kept intentionally small
- **Routing:** Vue Router, two primary routes — landing/search dashboard, employee detail
- **Charts:** a lightweight charting lib (ECharts or Chart.js) for the summary card
  trends and org-wide tiles
- **Data-fetching pattern:** every table/list component is built paginated from day one
  (matching the backend's enforced pagination) — no "fetch everything and filter in
  the browser" patterns, which would fall over instantly at this data volume

---

## 5. Mobile application — separate module, separate architecture

Per the program plan, mobile is **its own architecture track**, sharing only the
backend API contract with the web app — not the frontend code or state layer.

**Confirmed stack:**
- **Framework:** Flutter (single codebase for iOS/Android)
- **State management:** Riverpod — clear separation between data layer and UI,
  testable providers, standard for enterprise Flutter apps
- **Local storage/offline cache:** **Isar** — used as a read-through cache for
  last-fetched employee summaries and activity logs, so the app stays usable on
  flaky connectivity; also the natural local store once the Employee role (future
  scope, §6) needs to queue an offline check-in/check-out before syncing
- **Networking:** **Dio** — handles the REST calls to the Frappe whitelisted API
  layer, with interceptors for auth headers, retry/backoff, and centralized error
  handling; paired with Riverpod providers so network state (loading/error/data)
  flows cleanly into the UI
- **Scope for this phase:** CEO experience only — search, summary card, detail page,
  filters — matching the web app's current scope (see §6 for Manager/Employee)
- **Why a separate module and not "responsive web":** the brief specifically asked
  for mobile to be planned as its own architecture, and a real native app gives
  offline caching (Isar) and push-notification headroom (e.g. future "your report
  hasn't logged in today" alerts) that a responsive web view can't offer as cleanly

### 5.1 Shared login screen concept (web + mobile)

Both clients present the same three-button login screen — **CEO / Manager / Employee**
— establishing the target role model visually even before Manager and Employee are
functional:
- **CEO button:** active, routes to the full dashboard (this phase's deliverable)
- **Manager button:** present but routes to a "coming soon" state — future scope
- **Employee button:** present but routes to a "coming soon" state — future scope

This costs almost nothing to build now (it's three routes and two placeholder
screens) but avoids a later rework of the auth/routing shell when Manager and
Employee are switched on.

---

## 6. Manager & Employee roles (future scope, not built now)

Recorded here so the permission/API design already accounts for them without being
built this phase:

- **Manager:** same dashboard shell as CEO, but every query is pre-filtered server-side
  to `employee.manager == current_user.employee` (direct reports) plus a recursive
  walk down the `manager` link for indirect reports. This is a filter added to
  existing whitelisted endpoints, not new endpoints — the API contract doesn't change,
  just the permission scope applied to it.
- **Employee:** a write-capable surface — mark check-in/check-out (writes into the
  existing `Employee Activity Log` DocType) and view own history (read-only filter
  `employee == current_user.employee` on the existing detail-page endpoint). On
  mobile, this is also where **Isar** earns its keep: a check-in tapped with no
  connectivity is queued locally and synced via **Dio** once back online.
- Both roles reuse the CEO's existing DocTypes, indexes, and aggregate tables —
  no new data model needed, only new permission rules and, for Employee, a new
  write path.

## 7. Future scope — AI Chatbot (placeholder only, not architected)

Noted here so it's on record, deliberately kept shallow:

- Would sit as a separate service calling the same whitelisted API layer (never
  querying MariaDB directly), likely with a small retrieval layer (RAG) over the
  aggregate tables so it can answer questions like "who worked the fewest hours last
  month" without hallucinating numbers
- Not scheduled, not scoped in detail, not part of current delivery — revisit this
  section only when the core portal (Modules 1–2) is stable in production

---

## 8. Summary: how this maps back to "3/10 → 8/10"

| Dimension | Literal brief (3/10) | This plan (8/10) |
|---|---|---|
| Data scale handling | Not addressed | Aggregate tables + scheduled jobs + indexing, sized for 11M+ rows |
| API shape | Implicit (Desk-driven) | Explicit, versioned, paginated, whitelisted REST contract |
| Caching | None | Redis cache layer for hot reads (search, summary cards) |
| Background processing | None | RQ-based scheduled aggregation, isolated queue |
| Client surfaces | Web only | Web (Vue3/Pinia/TanStack Query) + Mobile (Flutter/Riverpod), sharing one API |
| Forward compatibility | None | Permission model and API contract designed so Manager/Employee roles and AI chatbot can be added without rework |
