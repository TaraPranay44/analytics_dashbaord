# Employee Analytics Portal — Mobile Build Rules (for AI coding agents)

**Scope:** Flutter mobile app only. Companion docs: `01_MANAGERIAL_PLANNING.md`,
`02_TECHNICAL_PLANNING.md`, `03_PHASED_ROADMAP.md`, `04_BACKEND_RULES.md`,
`05_FRONTEND_WEB_RULES.md`. Consumes the same API contract defined in
`04_BACKEND_RULES.md §5` — **do not invent a different API shape client-side.**
Confirmed stack: **Flutter, Riverpod, Isar, Dio.**

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
  (e.g. `employeeSummaryProvider`, `employeeLogsPageProvider`) — not one giant
  app-wide provider
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
│   │   └── isar_client.dart          # Isar instance setup, schema registration
│   ├── constants/
│   │   ├── api_constants.dart        # endpoint paths (must match backend §5)
│   │   ├── string_constants.dart     # UI copy
│   │   └── cache_constants.dart      # Isar box/collection names, TTLs
│   └── errors/
│       └── failures.dart             # typed failure classes (NetworkFailure, NotFoundFailure, etc.)
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       ├── login_view.dart        # 3 role buttons: CEO / Manager / Employee
│   │       └── coming_soon_view.dart  # placeholder for Manager/Employee (future scope)
│   ├── dashboard/
│   │   ├── presentation/
│   │   │   ├── dashboard_view.dart
│   │   │   └── dashboard_view_model.dart   # Riverpod provider
│   │   ├── domain/
│   │   │   ├── entities/org_summary.dart
│   │   │   └── use_cases/get_org_dashboard.dart
│   │   └── data/
│   │       ├── org_repository_impl.dart
│   │       ├── org_remote_data_source.dart   # Dio calls
│   │       └── org_local_data_source.dart    # Isar cache
│   ├── employee_search/
│   │   ├── presentation/ (view + view_model)
│   │   ├── domain/ (entities/use_cases)
│   │   └── data/ (repository_impl, remote/local data sources)
│   └── employee_detail/
│       ├── presentation/ (view + view_model)
│       ├── domain/ (entities/use_cases)
│       └── data/ (repository_impl, remote/local data sources)
└── shared/
    ├── widgets/                       # shared dumb widgets (SummaryCard, DateRangeFilter, etc.)
    └── theme/
```

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
