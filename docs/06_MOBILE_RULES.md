# Employee Analytics Portal — Mobile Build Rules (for AI coding agents)

**Scope:** Flutter mobile app only. Companion docs: `01_MANAGERIAL_PLANNING.md`,
`02_TECHNICAL_PLANNING.md`, `03_PHASED_ROADMAP.md`, `04_BACKEND_RULES.md`,
`05_FRONTEND_WEB_RULES.md`. Consumes the same API contract defined in
`04_BACKEND_RULES.md §5` — **do not invent a different API shape client-side.**
Confirmed stack: **Flutter, Riverpod, Isar, Dio.**

> **🔐 Auth resolution (updated after live-testing against a real bench):**
> `04_BACKEND_RULES.md §5` documents only the `analytics_portal.api.v1.*`
> endpoints — there is no documented authentication endpoint for a native
> client (the web app instead rides the browser's existing Frappe session,
> see `05_FRONTEND_WEB_RULES.md`/`authRoleStore.ts`). Initially `login_view.dart`
> shipped as a pure demo (any non-empty input signs in), matching the web
> app's role-picker pattern, since no backend was available to test against.
> Once this project's own `bench` (site `employee-analytics.in`) was actually
> run against the mobile app in an emulator, that demo behavior meant the
> dashboard could never show real data (every `analytics_portal.api.v1.*`
> call came back `PermissionError: ... not whitelisted` - Frappe's
> `frappe.whitelist()` rejects unauthenticated/Guest requests by default).
> `login_view.dart` now calls `DioClient.login()` for real (standard
> Frappe-core `/api/method/login` session-cookie auth, not an invented
> `analytics_portal` endpoint) and only navigates to the dashboard on a real
> successful sign-in; Manager/Employee stay pure client-side role picks (no
> backend call - those dashboards don't exist yet regardless of credentials).
> This is still a minimal/session-cookie-only auth flow (no token refresh, no
> persisted session across app restarts) - harden it if mobile auth becomes
> real Phase 2+ scope, but it is no longer a stubbed-out gap.

---

## 0. How an AI agent must use this document

1. **Do not invent anything not defined here** — layer names, folder locations,
   provider names, endpoint calls. If something is needed that isn't defined below,
   **stop and surface a question**.
2. **Do not hallucinate package APIs.** If unsure of a Riverpod, Isar, or Dio method
   signature or annotation, say so — don't produce plausible but wrong code.
3. **The API contract in `04_BACKEND_RULES.md §5` is fixed.** No client-side
   endpoint invention.
4. **Every new provider, repository, or screen an agent adds must be appended to
   this document's file tree (§6) in the same change.**
5. When two rules conflict, the more restrictive one wins.

---

## 1. Architecture pattern: **Clean Architecture, with MVVM inside the presentation layer**

Three layers, strict one-direction dependency (presentation → domain → data, never
the reverse):

| Layer | Contains | Rule |
|---|---|---|
| **Presentation** | Views (Widgets) + ViewModels (Riverpod `Notifier`/`AsyncNotifier` providers) | Widgets bind to a provider's state — **no direct Dio/Isar calls in a widget**. The ViewModel (provider) exposes state + actions; the Widget (View) is dumb. |
| **Domain** | Entities (plain Dart classes, no JSON/DB annotations) + Use Cases (single-purpose classes, e.g. `GetEmployeeSummary`) + Repository **interfaces** | No dependency on Dio or Isar directly — depends only on the repository interface, which data-layer classes implement. This is what keeps business rules testable without a real network/DB. |
| **Data** | Repository **implementations**, remote data source (Dio-based API client), local data source (Isar-based cache), DTOs + mappers (DTO ↔ Entity) | The only layer allowed to import `dio` or `isar` packages directly. |

**Mapping to MVVM:** within Presentation, the Widget = **View**, the Riverpod
provider = **ViewModel**. The Domain layer's entities/use-cases are the **Model**
that the ViewModel calls into (via the repository interface).

---

## 2. Architecture chart

```
┌───────────────────────────────────────────────────────────────┐
│  PRESENTATION                                                    │
│  View (Widget) ──binds to──▶ ViewModel (Riverpod provider)        │
│  - no Dio/Isar imports here                                        │
└───────────────────────────┬───────────────────────────────────────┘
                            ▼ calls
┌───────────────────────────────────────────────────────────────┐
│  DOMAIN                                                           │
│  Use Cases (e.g. GetEmployeeSummary, GetEmployeeLogsPage)          │
│  Entities (Employee, ActivityLog, EmployeeSummary — plain Dart)     │
│  Repository INTERFACES (e.g. abstract class EmployeeRepository)     │
└───────────────────────────┬───────────────────────────────────────┘
                            ▼ implemented by
┌───────────────────────────────────────────────────────────────┐
│  DATA                                                             │
│  Repository IMPLEMENTATIONS                                        │
│    ├── Remote data source — Dio client → backend API v1             │
│    └── Local data source  — Isar cache (read-through + offline)      │
│  DTOs + mappers (JSON ↔ Entity)                                     │
└───────────────────────────┬───────────────────────────────────────┘
                            ▼
                 ┌─────────────────────┐
                 │  Backend API (v1)     │  ← 04_BACKEND_RULES.md §5
                 └─────────────────────┘
```

**Read pattern (repository implementation):** check Isar cache first → if fresh
enough, return it and refresh in background; if stale/missing, call Dio, map DTO →
Entity, write through to Isar, return Entity. This single pattern is used by every
repository — don't invent a different caching strategy per feature.

---

## 3. Packages to include

| Package | Role | Notes |
|---|---|---|
| `flutter_riverpod` | State management (ViewModel layer) | Use `Notifier`/`AsyncNotifier` for anything async (API calls) — not plain `StateProvider` for server data |
| `isar` | Local cache / offline store | Schema defined per entity that needs caching (§4); also the future queue for offline Employee check-ins (Phase 4) |
| `dio` | HTTP client | Single configured instance in `core/network/dio_client.dart`, with interceptors for auth header + logging + retry |
| `freezed` + `json_serializable` (recommended, not mandatory) | Immutable entities/DTOs + JSON codegen | If used, keep DTOs and Entities as separate classes (§1) even though both may use `freezed` |

**Rule:** do not add a new state-management, local-storage, or HTTP package beyond
what's listed here without flagging it as a deviation.

---

## 4. Coding style

- **Language:** Dart, null-safety on, `flutter_lints` ruleset enabled and respected
- **File naming:** `snake_case.dart`, one public class per file where practical
- **Widgets:** prefer small, composed widgets over large `build()` methods; a
  `build()` over ~80 lines should be broken into sub-widgets
- **Providers:** named `xxxProvider`, one provider per ViewModel responsibility
  (e.g. `employeeListPageProvider`, `employeeDetailProvider`, `employeeLogsPageProvider`)
  — not one giant app-wide provider
- **No Dio or Isar imports outside `data/`** — enforced by the layer boundary in §1
- **No literals** for endpoint paths, cache-box names, or page sizes — pull from
  `core/constants/` (§7)
- **Every repository method typed against the domain entity, never the raw DTO** —
  DTOs never leak past the data layer

---

## 5. Data-fetching, caching & pagination rules

- Activity log lists use **paginated fetch** matching the backend's `start`/`limit`
  contract (`04_BACKEND_RULES.md §5`) — infinite-scroll pattern in the View, driven
  by an `AsyncNotifier` that appends pages, never "fetch everything then paginate
  client-side."
- Isar is used as a **read-through cache**: last-fetched summary/logs are cached
  locally so the app shows something on poor connectivity, then refreshes once the
  network call succeeds.
- Search input is **debounced** (≥300ms) before calling the search endpoint.
- Dio client has a single retry/backoff interceptor — no per-call ad hoc retry logic.

---

## 6. File / folder structure (exact — do not deviate)

```
lib/
├── core/
│   ├── network/
│   │   └── dio_client.dart          # single configured Dio instance + interceptors
│   ├── cache/
│   │   ├── isar_client.dart          # Isar instance setup, schema registration, read-through helpers
│   │   └── cached_json_entry.dart    # the single @collection backing every feature's cache (§2 addition)
│   ├── constants/
│   │   ├── api_constants.dart        # endpoint paths (must match backend §5)
│   │   ├── string_constants.dart     # UI copy
│   │   └── cache_constants.dart      # Isar collection name, cache keys, TTLs
│   ├── errors/
│   │   └── failures.dart             # typed failure classes (NetworkFailure, NotFoundFailure, etc.)
│   └── providers/
│       └── core_providers.dart       # app-wide Riverpod singletons (DioClient, IsarClient) — addition,
│                                      # not a feature so it doesn't fit under features/
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       ├── auth_role_provider.dart # PortalRole StateProvider — no persistence, demo-only (§8)
│   │       ├── login_view.dart        # see the visual-design note below
│   │       └── coming_soon_view.dart  # placeholder for Manager/Employee (future scope)
│   ├── dashboard/
│   │   ├── presentation/
│   │   │   ├── dashboard_view.dart
│   │   │   └── dashboard_view_model.dart   # org_dashboard + org_insights providers
│   │   ├── domain/
│   │   │   ├── entities/org_summary.dart
│   │   │   ├── entities/org_insights.dart          # addition — org_insights response shape
│   │   │   ├── repositories/org_repository.dart     # addition — the Domain-layer interface §1 requires
│   │   │   └── use_cases/
│   │   │       ├── get_org_dashboard.dart
│   │   │       ├── get_org_insights.dart             # addition
│   │   │       └── compute_org_trend_insights.dart   # addition — pure momentum calc, mirrors web's orgTrend.ts
│   │   └── data/
│   │       ├── org_repository_impl.dart
│   │       ├── org_remote_data_source.dart   # Dio calls + JSON→Entity mapping
│   │       └── org_local_data_source.dart    # Isar cache
│   ├── employee_list/                 # renamed from employee_search — see correction note below
│   │   ├── presentation/
│   │   │   ├── employee_list_view.dart      # search+filters+paginated rows+pager — embedded inside
│   │   │   │                                 # dashboard_view.dart, same screen as the mockup
│   │   │   ├── employee_list_item.dart      # single compact row widget — NO inline charts, NO per-row summary
│   │   │   ├── manager_filter_field.dart    # addition — mobile modal-sheet adaptation of web's
│   │   │   │                                 # inline ManagerFilterCombobox, same endpoint/semantics
│   │   │   └── employee_list_view_model.dart # filter state + employeeListProvider + manager-search providers
│   │   ├── domain/
│   │   │   ├── entities/employee_list_item.dart   # intentionally narrower than EmployeeDetail, not a slice of it
│   │   │   ├── entities/employee_sort_option.dart # addition — the only 2 sorts the backend actually supports
│   │   │   ├── repositories/employee_list_repository.dart  # addition
│   │   │   └── use_cases/get_employee_list.dart
│   │   └── data/ (employee_list_repository_impl.dart, remote/local data sources)
│   └── employee_detail/
│       ├── presentation/
│       │   ├── employee_detail_view.dart    # header + hierarchy + profile + summary + chart + log
│       │   ├── employee_trend_chart.dart    # the per-employee chart — lives ONLY here
│       │   ├── employee_summary_panel.dart  # addition — performance-metrics card
│       │   ├── org_hierarchy_card.dart      # addition — manager chain + direct reports card
│       │   ├── activity_log_list.dart       # addition — date-range filter + paginated log rows
│       │   └── employee_detail_view_model.dart # detail/hierarchy/logs/monthly-trend providers, .family per employeeId
│       ├── domain/
│       │   ├── entities/ (employee_detail.dart, org_hierarchy.dart, monthly_trend_point.dart, activity_log_row.dart)
│       │   ├── repositories/employee_detail_repository.dart  # addition
│       │   └── use_cases/
│       │       ├── get_employee_detail.dart
│       │       ├── get_org_hierarchy.dart            # addition — org_hierarchy powers the manager/reports card
│       │       ├── get_employee_logs_page.dart       # addition — employee_logs, embedded in this screen
│       │       ├── get_employee_monthly_trend.dart   # addition — the "Lifetime" chart view
│       │       └── compute_trend_insights.dart       # addition — pure momentum calc, mirrors web's trendInsights.ts
│       └── data/ (employee_detail_repository_impl.dart, remote/local data sources)
└── shared/
    ├── widgets/         # dumb widgets: AvatarBadge, PaginationBar, StatTile, DeltaBadge,
    │                     # SparklineChart, AreaTrendChart (hand-rolled CustomPainter charts —
    │                     # no charting package added, see §3 addition note), AsyncValueView
    ├── theme/            # app_colors.dart, app_theme.dart
    ├── utils/            # addition — formatters.dart, avatar_utils.dart, debouncer.dart (pure,
    │                     # cross-feature helpers; mirrors web/src/utils/)
    └── models/           # addition — paginated_result.dart, the shared `{data,start,limit,has_more}`
                          # envelope every list endpoint returns (§5), used by employee_list and
                          # employee_detail's logs page alike
```

> **⚠️ Correction note (post-review):** this feature was originally `employee_search`,
> paired with a single-result summary widget — as if a name search always resolves
> to one employee. It doesn't; a common name can match hundreds of the 30,000
> employees. It's renamed to **`employee_list`**, is always paginated
> (`PaginationBar` in `shared/widgets/`), and its rows never carry charts or
> multi-metric summaries — that content exists only in `employee_detail`.

> **📱 Login screen visual-design note:** §6 previously described `login_view.dart`
> as "3 role buttons: CEO / Manager / Employee." The attached mobile mockup
> (`mobile-login (1).html`) instead draws a gradient-hero email/password
> sign-in form. The shipped `login_view.dart` follows the mockup's visual
> design for the CEO sign-in path (now wired to a real `DioClient.login()`
> call, see the auth-resolution note at the top of this doc), and adds two
> secondary "Manager"/"Employee" buttons below the form (routing to
> `coming_soon_view.dart`) so §8's "all three role buttons ship now"
> requirement still holds. Flagged here rather than silently reconciled — ask
> if a different resolution is wanted.

> **ℹ️ No charting package added:** `employee_trend_chart.dart`'s "Time spent /
> day" chart and the dashboard's stat-tile sparklines are hand-rolled with
> Flutter's `CustomPainter` (`shared/widgets/area_trend_chart.dart`,
> `sparkline_chart.dart`), not a third-party charting library — keeps the
> package list in §3 exactly as fixed, and mirrors how the reference mockups
> themselves draw their charts (inline SVG, no chart.js-equivalent on mobile).

**Rule:** every feature folder repeats the same three sub-layers
(`presentation/domain/data`) — no feature skips a layer, even if a layer is thin.

---

## 7. Constants files

| File | Contains |
|---|---|
| `core/constants/api_constants.dart` | endpoint path strings (must match `04_BACKEND_RULES.md §5` exactly), default/max page sizes |
| `core/constants/string_constants.dart` | UI copy — button labels, empty-state text, error messages |
| `core/constants/cache_constants.dart` | Isar collection names, local cache TTLs |

**Rule:** no literal endpoint path, Isar collection name, or user-facing string may
appear inline in a widget/provider/repository — import from these files.

---

## 8. Good practices

- Strict Clean Architecture layering — data-layer packages (`dio`, `isar`) never
  imported outside `data/`
- One `AsyncNotifier` per screen-level concern, not one giant app state provider
- Read-through Isar cache on every repository, consistent pattern across features
- All lists paginated matching the backend contract exactly
- Login screen ships all three role buttons now (CEO active, Manager/Employee →
  `coming_soon_view.dart`) so routing doesn't need rework later

## Bad practices (explicitly forbidden)

- ❌ A widget calling `Dio` or `Isar` directly instead of going through a provider →
  use case → repository
- ❌ Fetching a full list and paginating client-side instead of using the backend's
  `start`/`limit` contract
- ❌ Un-debounced search-as-you-type calls
- ❌ DTOs (JSON-shaped classes) used directly in the presentation layer instead of
  being mapped to domain entities first
- ❌ Hardcoded endpoint paths, Isar box names, or labels inline instead of via
  `core/constants/`
- ❌ Building Manager/Employee login buttons as dead ends instead of routing to
  `coming_soon_view.dart`
- ❌ Adding a second state-management or local-storage package alongside Riverpod/Isar
- ❌ **Rendering a single rich "summary" widget (avatar + metrics + chart) as a
  search result or list row.** A common name can match hundreds of the 30,000
  employees — `employee_list_item.dart` is one compact row, full stop. Charts and
  multi-metric summaries belong only in `employee_detail_view.dart`.
- ❌ Loose, over-padded list/table screens. `employee_list_view.dart` and the
  activity-log view are dense, frequently-scanned executive tools — keep row
  height and spacing tight and legible; save generous whitespace for the
  hero/login screen, not for list screens.

---

## 9. Strict rules for AI agents (repeated for emphasis)

1. If unsure whether an endpoint/param exists, check `04_BACKEND_RULES.md §5` —
   never invent one.
2. If a Riverpod, Isar, or Dio API signature is uncertain, say so rather than
   guessing at a plausible method name.
3. Never restructure §6's file tree without proposing the change and updating this
   document first.
4. Keep this document and the code in sync — any new feature/provider/repository
   gets added here in the same change.
