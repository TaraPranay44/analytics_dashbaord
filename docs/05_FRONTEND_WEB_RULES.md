# Employee Analytics Portal — Frontend (Web) Build Rules (for AI coding agents)

**Scope:** Vue 3 web app only. Companion docs: `01_MANAGERIAL_PLANNING.md`,
`02_TECHNICAL_PLANNING.md`, `03_PHASED_ROADMAP.md`, `04_BACKEND_RULES.md`,
`06_MOBILE_RULES.md`. Consumes the API contract defined in `04_BACKEND_RULES.md §5`
— **do not invent a different API shape client-side.**

---

## 0. How an AI agent must use this document

1. **Do not invent anything not defined here** — component names, folder locations,
   store names, endpoint calls. If something is needed that isn't defined below,
   **stop and surface a question**.
2. **Do not hallucinate library APIs.** If unsure of a `frappe-ui`, Vue Router,
   Pinia, or TanStack Query method signature, say so — don't produce plausible but
   wrong code.
3. **The API contract in `04_BACKEND_RULES.md §5` is fixed.** This app calls exactly
   those endpoints, with exactly those params and response shape. No client-side
   endpoint invention.
4. **Every new component, composable, or store an agent adds must be appended to
   this document's file tree (§6) in the same change.**
5. When two rules conflict, the more restrictive one wins (e.g. unsure if a list
   needs pagination handling — §5 makes it mandatory).

---

## 1. Architecture pattern: **MVVM**

This app follows **MVVM**, mapped onto Vue 3 idioms:

| MVVM role | Vue 3 equivalent | Rule |
|---|---|---|
| **View** | `.vue` Single File Components in `views/` and `components/` | Template + minimal script — **no direct API calls, no business logic**. Only bindings to a ViewModel's exposed reactive state/methods. |
| **ViewModel** | Composables in `composables/`, named `useXxx.ts` | Owns state orchestration for a screen/feature — calls the Model layer, exposes `ref`/`computed` state and action functions to the View. This is where "loading/error/data" and derived state (e.g. formatted averages) live. |
| **Model** | `api/` service functions + TanStack Query hooks + `types/` | Pure data-fetching and shape definitions. No UI concerns at all. |

**Rule:** if a `.vue` file contains an `axios`/`fetch` call, a `TanStack Query` hook
directly, or non-trivial branching logic, that logic is misplaced — move it into a
composable (ViewModel).

---

## 2. Architecture chart

```
┌─────────────────────────────────────────────────────────────┐
│  VIEW  (views/*.vue, components/*.vue)                        │
│  - template + light script setup                              │
│  - binds to composable's exposed refs/computed/methods         │
└───────────────────────────┬───────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  VIEWMODEL  (composables/useXxx.ts)                            │
│  - orchestrates: calls Model, manages UI-facing state           │
│  - reads/writes Pinia store for cross-screen UI state only      │
└───────────┬─────────────────────────────┬─────────────────────┘
            ▼                             ▼
┌───────────────────────┐       ┌───────────────────────────┐
│  MODEL — api/           │       │  STORE — store/ (Pinia)      │
│  - endpoint functions   │       │  - client-only UI state:      │
│  - TanStack Query hooks │       │    selected filters, active    │
│  - types/ (response      │       │    date range, search text     │
│    shapes)               │       │  - NOT server data (that's     │
└───────────┬─────────────┘       │    TanStack Query's job)       │
            ▼                     └───────────────────────────┘
┌───────────────────────┐
│  Backend API (v1)       │  ← see 04_BACKEND_RULES.md §5
└───────────────────────┘
```

**Rule:** server data (employee logs, summaries) lives in TanStack Query's cache, not
duplicated into a Pinia store. Pinia is for UI-only state (what filter is selected,
what's in the search box) — this avoids two sources of truth for the same data.

---

## 3. Apps/libraries to include

| Library | Role | Notes |
|---|---|---|
| Vue 3 (Composition API) | Core framework | `<script setup>` syntax throughout |
| `frappe-ui` | Component library, API client conventions | Use its session/auth handling — don't hand-roll a parallel auth client |
| Pinia | UI-only state (§2) | Small stores, one per feature area, never a server-data cache |
| `@tanstack/vue-query` | Server state (fetching, caching, pagination, refetch) | All employee/log/dashboard data goes through this |
| Vue Router | Routing | Two-ish route groups: auth/login, dashboard area |
| A chart library (ECharts or Chart.js — pick one and stay consistent) | Summary/trend visuals | Do not mix two charting libraries in the same app |

**Rule:** do not add a new state library, HTTP client, or charting library beyond
what's listed here without flagging it as a deviation.

---

## 4. Coding style

- **Language:** TypeScript everywhere (no plain `.js` files for app logic)
- **Components:** `<script setup lang="ts">`, PascalCase filenames (`EmployeeCard.vue`)
- **Composables:** camelCase filenames prefixed `use` (`useEmployeeList.ts`),
  always return a plain object of refs/computed/functions — never return a raw
  reactive object where callers can mutate internals directly
- **No inline literals** for route paths, endpoint paths, or labels — pull from
  `constants/` (§7)
- **Props/emits:** always typed with `defineProps<T>()` / `defineEmits<T>()`, never
  the untyped runtime declaration style
- **No business logic in templates** — no multi-condition inline `v-if` chains;
  compute a named `computed` in the ViewModel instead
- **File length:** a `.vue` file over ~150 lines of `<script>` is a sign a composable
  should be extracted

---

## 5. Data-fetching & pagination rules

- Every list-returning screen (search results, activity log table) uses
  `useInfiniteQuery`/paginated `useQuery` from `@tanstack/vue-query` — **never**
  fetch-all-then-slice-in-the-browser. This matches the backend's enforced
  pagination (`04_BACKEND_RULES.md §5/§7`) and is required given the log table's
  scale.
- Search input is **debounced** (≥300ms) before triggering a query — no
  query-per-keystroke.
- Every query key follows the pattern `["employee", employeeId, "logs", { from, to, page }]`
  — consistent, so cache invalidation and refetch behavior stay predictable.

---

## 6. File / folder structure (exact — do not deviate)

> **⚠️ Correction note (post-review):** the landing `DashboardView` was originally
> paired with a single `EmployeeSummaryCard` component, as if a search always
> resolves to one employee. It doesn't — a common name can match hundreds of the
> 30,000 employees. `EmployeeSummaryCard` (with its inline charts) is **removed
> from the landing page entirely** and now only appears inside `EmployeeDetailView`.
> The landing page instead uses a new `EmployeeListTable` + `EmployeeListRow` +
> `Pagination` + `FilterBar` set of components, backed by `useEmployeeList` (renamed
> from `useEmployeeSearch`). `useEmployeeSummary` is removed as a separate
> composable — its data is now part of `useEmployeeDetail`, matching the backend's
> merged `employee_detail` endpoint (`04_BACKEND_RULES.md §5`).

```
src/
├── views/                       # Views (screens/pages)
│   ├── LoginView.vue             # 3 role buttons: CEO / Manager / Employee
│   ├── DashboardView.vue         # CEO landing page: org tiles + search/filters + employee list
│   ├── EmployeeDetailView.vue     # per-employee dashboard: summary, trend chart, activity log
│   └── ComingSoonView.vue        # placeholder for Manager/Employee (future scope)
├── components/                  # Reusable dumb UI components (Views, per MVVM)
│   ├── EmployeeSearchBar.vue
│   ├── FilterBar.vue              # manager filter, sort control — sits alongside the search bar
│   ├── EmployeeListTable.vue       # paginated, compact rows — NO charts, NO multi-metric summary
│   ├── EmployeeListRow.vue         # single row: avatar, name/ID, manager, avg hrs/day, avg login, status
│   ├── Pagination.vue              # "Showing X–Y of Z" + Prev/Next, used by EmployeeListTable
│   ├── EmployeeSummaryPanel.vue    # rich metrics block — EmployeeDetailView ONLY, never the landing list
│   ├── EmployeeTrendChart.vue      # the per-employee chart — EmployeeDetailView ONLY
│   ├── ActivityLogTable.vue
│   ├── DateRangeFilter.vue
│   └── OrgHierarchyView.vue
├── composables/                 # ViewModels
│   ├── useEmployeeList.ts         # paginated list/search — renamed from useEmployeeSearch
│   ├── useEmployeeDetail.ts       # full detail incl. summary metrics + trend series (was useEmployeeSummary)
│   ├── useEmployeeLogs.ts
│   ├── useOrgDashboard.ts
│   └── useDateRangeFilter.ts
├── api/                         # Model — data layer
│   ├── client.ts                 # frappe-ui-based HTTP client setup
│   ├── employeeApi.ts            # calls employee_list / employee_detail
│   ├── logsApi.ts                # calls employee_logs
│   └── orgApi.ts                 # calls org_dashboard / org_hierarchy
├── types/
│   ├── employee.ts                # includes a distinct EmployeeListRow type vs. EmployeeDetail type —
│   │                               # the list row is intentionally a narrower shape, not a slice of detail
│   ├── activityLog.ts
│   └── apiResponse.ts             # shared { data, start, limit, has_more } shape
├── store/                        # Pinia — UI-only state
│   ├── uiFilterStore.ts           # current q, manager filter, sort, page — landing list UI state
│   └── authRoleStore.ts           # which role button was selected (CEO active only)
├── router/
│   └── index.ts
├── constants/
│   ├── apiConstants.ts            # endpoint path strings
│   ├── routeConstants.ts          # route name/path strings
│   └── stringConstants.ts         # UI labels, messages
└── utils/
    ├── formatDate.ts
    ├── debounce.ts
    └── formatDuration.ts
```

---

## 7. Constants files

| File | Contains |
|---|---|
| `constants/apiConstants.ts` | endpoint path strings (must match `04_BACKEND_RULES.md §5` exactly), default/max page sizes |
| `constants/routeConstants.ts` | route names/paths used by `router/index.ts` and navigation calls |
| `constants/stringConstants.ts` | UI copy — button labels, empty-state text, error messages |

**Rule:** no literal endpoint path, route path, or user-facing string may appear
inline in a component or composable — import from these files.

---

## 8. Good practices

- Strict MVVM separation — Views never call APIs directly
- Server data only ever lives in TanStack Query's cache, not duplicated into Pinia
- All lists paginated/infinite-scrolled, search debounced
- Fully typed API responses matching the backend contract exactly
- Login screen ships all three role buttons now (CEO active, Manager/Employee →
  `ComingSoonView.vue`) so the routing shell doesn't need rework later

## Bad practices (explicitly forbidden)

- ❌ `fetch`/`axios` calls inside a `.vue` file's `<script setup>`
- ❌ Storing server data (employee logs, summaries) in a Pinia store instead of
  TanStack Query's cache
- ❌ Fetching a full list and paginating/filtering client-side in JavaScript
- ❌ Un-debounced search-as-you-type queries
- ❌ Hardcoded endpoint paths or labels inline instead of via `constants/`
- ❌ Building the Manager/Employee login buttons as non-functional dead links with
  no route at all (they must route to `ComingSoonView.vue`, not 404)
- ❌ Adding a second charting or state-management library alongside the ones in §3
- ❌ **Rendering a single "summary card" (with avatar, metrics, and a chart) as the
  result of a search or as a row in a list.** A list is a list — one compact row
  per employee, no inline chart, no multi-line metric block. Charts and rich
  summaries belong only in `EmployeeDetailView`, never in `EmployeeListRow`.
- ❌ Sparse layouts with large unused margins/whitespace on data-dense screens
  (the landing list, the activity log). These are executive tools reviewed
  frequently — favor information density (compact row height, tight but legible
  spacing) over decorative empty space. Reserve generous whitespace for the
  hero/login screen, not for list or table views.

---

## 9. Strict rules for AI agents (repeated for emphasis)

1. If unsure whether an endpoint/param exists, check `04_BACKEND_RULES.md §5` —
   never invent one.
2. If a `frappe-ui`, Pinia, or TanStack Query API signature is uncertain, say so
   rather than guessing.
3. Never restructure §6's file tree without proposing the change and updating this
   document first.
4. Keep this document and the code in sync — any new file/component gets added here
   in the same change.
