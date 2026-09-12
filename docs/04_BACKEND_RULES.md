# Employee Analytics Portal — Backend Build Rules (for AI coding agents)

**Scope:** Frappe backend only. Companion docs: `01_MANAGERIAL_PLANNING.md`,
`02_TECHNICAL_PLANNING.md`, `03_PHASED_ROADMAP.md`, `05_FRONTEND_WEB_RULES.md`,
`06_MOBILE_RULES.md`.

---

## 0. How an AI agent must use this document

This is not a style suggestion — it is a **constraint file**. Any agent (or human)
implementing backend code for this project must follow it exactly.

1. **Do not invent anything not defined here.** Not a field, not an endpoint, not a
   DocType, not a constant name. If something is needed that isn't defined below,
   **stop and surface a question** — do not guess a reasonable-sounding name or shape.
2. **Do not hallucinate Frappe APIs.** If unsure whether a Frappe method/hook/decorator
   exists or what its signature is, say so explicitly rather than producing plausible
   but wrong code. A wrong guess that compiles is worse than an admitted gap.
3. **This document is the single source of truth for names.** Field names, endpoint
   paths, cache key formats, constant names — copy them exactly as written here. Do
   not rename "for clarity" or "for consistency with X convention."
4. **Every new API, field, or constant an agent adds must be appended to this
   document in the same change**, so the doc never drifts from the code.
5. **When two rules in this doc conflict, the more restrictive one wins** (e.g. if
   unsure whether an endpoint needs pagination, add it — §7 makes pagination
   mandatory, not optional).

---

## 1. Architecture chart

```
┌────────────────────────────────────────────────────────────────────┐
│                         CLIENTS (out of scope here)                 │
│                  Web (Vue3)            Mobile (Flutter)              │
└───────────────────────────────┬──────────────────────────────────────┘
                                 │ HTTPS / JSON
                                 ▼
┌────────────────────────────────────────────────────────────────────┐
│  API LAYER  —  analytics_portal/api/v1/*.py                          │
│  - thin, whitelisted functions only                                  │
│  - parse + validate request params                                   │
│  - call into service layer, never touch DB directly                  │
│  - shape the JSON response                                            │
└───────────────────────────────┬──────────────────────────────────────┘
                                 ▼
┌────────────────────────────────────────────────────────────────────┐
│  SERVICE LAYER  —  analytics_portal/services/*.py                     │
│  - business logic (e.g. "get employee summary" = read aggregate       │
│    table + fall back rules)                                           │
│  - orchestrates caching (checks cache, calls repository on miss)      │
│  - no frappe.whitelist here — services are plain Python, testable     │
└───────────────────────────────┬──────────────────────────────────────┘
                                 ▼
┌────────────────────────────────────────────────────────────────────┐
│  REPOSITORY / QUERY LAYER  —  analytics_portal/repositories/*.py      │
│  - all frappe.qb / frappe.db.sql / frappe.get_all calls live ONLY here│
│  - one repository per DocType-family (EmployeeRepo, ActivityLogRepo,   │
│    StatsRepo)                                                          │
└───────┬──────────────────────────────┬───────────────────────────────┘
        ▼                              ▼
┌───────────────┐              ┌───────────────────┐
│   MariaDB       │              │      Redis          │
│  (DocTypes,     │              │  (cache + RQ queue) │
│   aggregate     │              └───────────────────┘
│   tables)       │
└───────────────┘
        ▲
        │ populated by
┌────────────────────────────────────────────────────────────────────┐
│  SCHEDULED JOBS  —  analytics_portal/jobs/*.py                        │
│  - nightly aggregation into Employee Monthly Stats / Overall Stats     │
│  - enqueued via frappe.enqueue on a dedicated low-priority queue       │
└────────────────────────────────────────────────────────────────────┘
```

**Rule:** an agent must never let the API layer call `frappe.db.sql` or `frappe.qb`
directly. API → Service → Repository → DB, always in that order, no skipping layers.

---

## 2. Apps to include

| App | Role | Notes for the agent |
|---|---|---|
| `frappe` | Core framework | Provides ORM, whitelisting, permissions, scheduler, RQ integration. Do not fork/modify core. |
| `analytics_portal` | **The custom app we are building** | All DocTypes, APIs, services, repositories, jobs, constants live here. |
| Redis (`redis` service, not a Frappe app) | Cache + job broker | Already wired by Frappe's `bench` setup (`redis_cache`, `redis_queue`). Do not introduce a second cache technology. |
| MariaDB | Primary datastore | Already wired by `bench`. Do not introduce a second database engine. |

**Explicitly excluded: Frappe HR (`hrms`) / ERPNext.** `Employee` is not a core Frappe
framework DocType — it belongs to ERPNext/HRMS. This project deliberately does
**not** install either. Reasons, for any agent tempted to "helpfully" add it later:
- `Employee` in our app is our own custom DocType (§4.1) — lighter, and shaped
  exactly for this use case, not HRMS's much heavier HR-suite version
- HRMS brings Recruitment, Leave, Payroll, Performance, Expense Claims, etc. — none
  of which this project uses; it's schema and permission bloat with no functional gain
- The actual hard part of this project — `Employee Monthly Stats`,
  `Employee Overall Stats`, `Org Daily Stats`, and the nightly aggregation jobs — does
  not exist in HRMS at all and would have to be built regardless, on top of a schema
  we don't control if HRMS were installed
- If leave/payroll/shift management ever becomes real scope (see
  `03_PHASED_ROADMAP.md` Phase 4+), evaluate HRMS **then** as a deliberate decision —
  not as a default dependency now

**Rule:** do not add a new app, service, or library (e.g. Celery, a different cache,
a different DB, `hrms`/ERPNext) without flagging it as a deviation from this doc first.

---

## 3. Coding style

- **Language:** Python 3.11+, PEP 8, 4-space indentation
- **Type hints required** on every function signature (params + return type)
- **Docstrings required** on every public function/method — one-line summary +
  `Args:`/`Returns:` when non-trivial
- **Function length:** if a function exceeds ~40 lines, it's doing too much — split it
- **No business logic in `api/` files** — they parse input, call a service, return
  output. Nothing else.
- **No magic strings/numbers** — every literal that means something (a page size, a
  cache TTL, an error message) comes from `constants/` (§10), not hardcoded inline
- **Naming:** `snake_case` for functions/variables, `PascalCase` for classes,
  `UPPER_SNAKE_CASE` for constants
- **Imports:** standard lib → third-party → local, each group alphabetized, no
  wildcard imports
- **No bare `except:`** — always catch a specific exception or log-and-reraise

---

## 4. DocTypes (exact fields — do not add/rename without updating this table)

### 4.1 `Employee`
| Field | Type | Notes |
|---|---|---|
| employee_name | Data | |
| employee_id | Data | unique, indexed |
| manager | Link → Employee | self-referential |
| date_of_joining | Date | |
| user | Link → User | |

### 4.2 `Employee Activity Log` (standalone DocType, not a child table)
| Field | Type | Notes |
|---|---|---|
| employee | Link → Employee | indexed, part of composite index |
| date | Date | indexed, part of composite index |
| login_time | Datetime | |
| logout_time | Datetime | |
| total_hours | Float | **computed in `before_save`**, never accepted from client input |

**Composite DB index required:** `(employee, date)`.

### 4.3 `Employee Monthly Stats`
| Field | Type | Notes |
|---|---|---|
| employee | Link → Employee | indexed |
| year_month | Data | format `YYYY-MM`, indexed with employee (composite) |
| avg_hours | Float | |
| avg_login_time | Time | |
| avg_logout_time | Time | |
| days_present | Int | |

### 4.4 `Employee Overall Stats`
| Field | Type | Notes |
|---|---|---|
| employee | Link → Employee | unique, indexed |
| avg_hours_overall | Float | |
| avg_login_time_overall | Time | |
| avg_logout_time_overall | Time | |
| last_computed | Datetime | |

### 4.5 `Org Daily Stats` (for landing dashboard tiles)
| Field | Type | Notes |
|---|---|---|
| date | Date | unique, indexed |
| total_employees | Int | |
| avg_hours_org | Float | |
| avg_login_time_org | Time | |

**Rule:** an agent must not add a field to any DocType without adding it to this
table in the same change.

---

## 5. APIs (exact routes — do not add/rename without updating this table)

> **⚠️ Correction note (post-review):** this table originally had a separate
> `employee_search` (autocomplete, `q` required) and `employee_summary` (single-card
> data) endpoint, implying a search always resolves to one employee. It doesn't — a
> common name can match hundreds of the 30,000 employees. `employee_search` is
> renamed to **`employee_list`** with `q` now **optional** (empty `q` = browse all,
> paginated) so it can power the landing page's employee list directly.
> `employee_summary` is **removed as a separate endpoint** — its fields are folded
> into `employee_detail`, since the rich per-employee data (summary metrics + trend
> series) only ever gets fetched once a specific employee is opened, never for a
> whole page of search results.

Namespace: `analytics_portal.api.v1.*`. All are `GET`, all whitelisted, all paginated
where they return a list.

| Endpoint (method name) | Purpose | Required params | Optional params |
|---|---|---|---|
| `employee_list` | Paginated, filterable employee directory — powers the landing page. Returns **compact rows only** (name, ID, manager, avg hours/day, avg login, status) — no charts, no multi-metric detail. | — | `q` (name/ID search, empty = browse all), `manager` (filter), `sort`, `start`, `limit` (default `PAGE_SIZE_DEFAULT`, max `PAGE_SIZE_MAX`) |
| `employee_detail` | Full detail for ONE employee: identity, manager chain, DOJ, summary metrics (avg/day, avg login, avg logout, attendance %), and a trend series (e.g. daily hours for the last 30 days) for the detail-page chart | `employee_id` | — |
| `employee_logs` | Paginated day-by-day activity log for one employee | `employee_id` | `from_date`, `to_date`, `start`, `limit` |
| `org_dashboard` | Org-wide tiles for landing page header | — | — |
| `org_hierarchy` | Manager chain / direct reports | `employee_id` | — |

**Response shape rule:** every list-returning endpoint returns
`{"data": [...], "start": int, "limit": int, "has_more": bool}` — no exceptions.
`employee_list` is a list-returning endpoint and **must** follow this shape even
when `q` is empty (browsing all 30,000 employees) — the "no unbounded result set"
rule in §7 applies to it exactly as it does to any other list endpoint.

**Rule:** every endpoint must validate `employee_id` exists before querying further
and must raise `frappe.DoesNotExistError` (not a silent empty response) if not found.

---

## 6. Caching

| Cache key pattern | TTL | Invalidated by |
|---|---|---|
| `cache:employee_list:{query_hash}` | 90s | time-based only (list/search results tolerate slight staleness); `query_hash` includes `q`, `manager`, `sort`, `start`, `limit` so different pages/filters cache separately |
| `cache:employee_detail:{employee_id}` | until next aggregation run | nightly job explicitly deletes/resets on recompute |
| `cache:org_dashboard` | until next aggregation run | nightly job explicitly deletes/resets on recompute |

- Use Frappe's built-in `frappe.cache()` (Redis-backed) — do not introduce a separate
  cache client.
- Cache key construction lives in `repositories/` or `services/`, using constants
  from `constants/cache_keys.py` (§10) — never a raw string built inline.
- **Rule:** any cache read must have a defined, deliberate invalidation path (event-based
  or TTL). "Cache and hope it expires eventually" is not acceptable — state which one
  applies, per the table above.

---

## 7. DB query rules

- **Never** build SQL via string formatting/concatenation with user input — always
  use `frappe.qb` (Query Builder) or parameterized `frappe.db.sql(query, values)`.
- **Never** call `frappe.get_all`/`get_list` without an explicit `fields=[...]` list —
  no implicit `select *`.
- **Every list query must be paginated** — `limit_start`/`limit_page_length` (or
  Query Builder `.limit()/.offset()`) on every call that can return more than one
  page. No endpoint may return an unbounded result set. This is non-negotiable given
  the 11M+ row `Employee Activity Log` table.
- **Reads from aggregate tables, not raw logs, for anything "average"** —
  `employee_list` (its avg hours/day column), `employee_detail`, `org_dashboard`,
  and similar must never compute an average by scanning `Employee Activity Log`
  directly. That's what `Employee Monthly Stats` / `Employee Overall Stats` /
  `Org Daily Stats` exist for. This applies with extra force to `employee_list`
  specifically — it can render up to a page-size of rows per request, each with its
  own avg-hours column, so per-row raw aggregation would multiply the cost by the
  page size.
- **All repository functions must be named for what they return**, e.g.
  `get_employee_logs_page(employee_id, from_date, to_date, start, limit)`, not
  generic names like `fetch_data`.

---

## 8. Scheduled jobs

Location: `analytics_portal/jobs/`.

| Job | Schedule | Does |
|---|---|---|
| `recompute_monthly_stats` | nightly (`cron`, e.g. 01:00) | recomputes prior day's contribution into the current month's row in `Employee Monthly Stats` |
| `recompute_overall_stats` | nightly, after monthly job | refreshes `Employee Overall Stats` from the monthly table (not raw logs) |
| `recompute_org_daily_stats` | nightly | refreshes `Org Daily Stats` for the prior day |

- Jobs are enqueued with `frappe.enqueue(..., queue="long")` on a dedicated queue —
  never on the default queue that interactive requests might share.
- Every job must log start, row-count processed, duration, and outcome
  (success/failure) — no silent jobs.

---

## 9. Helper / utility modules

Location: `analytics_portal/utils/`.

| Module | Responsibility |
|---|---|
| `pagination.py` | shared `paginate(query, start, limit)` helper enforcing `PAGE_SIZE_MAX` |
| `date_utils.py` | date-range resolution (e.g. "this week"/"this month" → concrete `from_date`/`to_date`) |
| `cache_utils.py` | `get_or_set(key, ttl, compute_fn)` wrapper around `frappe.cache()` |
| `validators.py` | shared input validation (e.g. `assert_employee_exists(employee_id)`) |

**Rule:** if the same 3+ lines of logic would otherwise appear in two files, it
belongs in one of these modules instead — no copy-pasted logic across API files.

---

## 10. Constants files

Location: `analytics_portal/constants/`.

| File | Contains |
|---|---|
| `api_constants.py` | `PAGE_SIZE_DEFAULT`, `PAGE_SIZE_MAX`, endpoint name strings if referenced elsewhere |
| `cache_keys.py` | key-format functions, e.g. `def employee_list_key(q, manager, sort, start, limit) -> str`, `def employee_detail_key(employee_id: str) -> str` |
| `string_constants.py` | user-facing labels/messages (error text, etc.) |
| `error_codes.py` | named error codes/messages raised by services (e.g. `EMPLOYEE_NOT_FOUND`) |

**Rule:** no literal page size, TTL number, or error message string may appear
inline in `api/`, `services/`, or `repositories/` code — it must be imported from one
of these files.

---

## 11. File / folder structure (exact — do not deviate)

```
analytics_portal/
├── analytics_portal/
│   ├── doctype/
│   │   ├── employee/
│   │   ├── employee_activity_log/
│   │   ├── employee_monthly_stats/
│   │   ├── employee_overall_stats/
│   │   └── org_daily_stats/
│   ├── api/
│   │   └── v1/
│   │       ├── employee.py        # employee_list, employee_detail
│   │       ├── logs.py            # employee_logs
│   │       └── org.py             # org_dashboard, org_hierarchy
│   ├── services/
│   │   ├── employee_service.py
│   │   ├── logs_service.py
│   │   └── org_service.py
│   ├── repositories/
│   │   ├── employee_repo.py
│   │   ├── activity_log_repo.py
│   │   └── stats_repo.py
│   ├── jobs/
│   │   ├── recompute_monthly_stats.py
│   │   ├── recompute_overall_stats.py
│   │   └── recompute_org_daily_stats.py
│   ├── utils/
│   │   ├── pagination.py
│   │   ├── date_utils.py
│   │   ├── cache_utils.py
│   │   └── validators.py
│   └── constants/
│       ├── api_constants.py
│       ├── cache_keys.py
│       ├── string_constants.py
│       └── error_codes.py
└── hooks.py
```

---

## 12. Good practices

- Thin API layer, all logic in services/repositories — testable without HTTP
- Aggregate tables read for anything "average" — never raw log scans
- Every list endpoint paginated, every cache key from `cache_keys.py`
- Type hints + docstrings on every function
- One repository per DocType-family, one service per feature area
- Jobs log row counts and duration, not just "done"

## Bad practices (explicitly forbidden)

- ❌ Computing averages by looping over `Employee Activity Log` rows in Python at
  request time
- ❌ `frappe.get_all(..., fields=["*"])` or no `fields` argument at all
- ❌ String-formatted SQL with user input (`f"... WHERE id = {employee_id}"`)
- ❌ Business logic inside a `frappe.whitelist()` function directly
- ❌ Hardcoded page sizes, TTLs, or error strings inline in logic files
- ❌ A new DocType field, endpoint, or constant added to code but not to this document
- ❌ Silent scheduled jobs with no logging
- ❌ Introducing a new cache/queue/DB technology not listed in §2 without flagging it
- ❌ **Designing any endpoint around the assumption that a name/ID search returns
  exactly one employee.** At 30,000 employees, common names return many matches —
  `employee_list` must always be treated as a paginated list endpoint, never
  special-cased to "return the single best match." (This was an earlier mistake in
  this project — see the correction note at the top of §5.)

---

## 13. Strict rules for AI agents (repeated for emphasis)

1. If a requirement is ambiguous, **ask** — do not fill the gap with a plausible guess.
2. If a Frappe API's exact signature is uncertain, **say so** — do not fabricate
   parameters that look right.
3. Never rename or restructure what's defined in §4/§5/§10 "for cleanliness" — propose
   the change and update this document first.
4. Treat this document as always in sync with the code. If code changes something
   here, the same change must update this file.
