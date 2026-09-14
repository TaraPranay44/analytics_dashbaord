# CLAUDE.md — Employee Analytics Portal (analytics_portal)

This file is auto-loaded by Claude Code at session start. It is an **index and
routing table**, not a copy of the docs. Full detail lives in `docs/` — **do not
read every file in `docs/` for every task.** Read only what the task-type table in
§2 says to read.

---

## 1. Non-negotiables (true for every task, no need to open a doc to confirm these)

- No hallucinated fields, endpoints, folder names, or library APIs. If unsure, say so
  or ask — do not guess a plausible-looking name.
- No Frappe HR (`hrms`) / ERPNext / payments / india_compliance in this app. This
  bench has exactly two apps: `frappe` and `analytics_portal`. `Employee` is our own
  custom DocType, not ERPNext's.
- Every list-returning query/endpoint must be paginated. No unbounded result sets —
  this app is designed against 30,000 employees × ~365 activity-log rows/year
  (11M+ rows).
- Averages ("avg time spent," "avg login/logout time") are read from precomputed
  aggregate tables (`Employee Monthly Stats`, `Employee Overall Stats`,
  `Org Daily Stats`) — never computed by scanning raw `Employee Activity Log` rows
  at request time.
- If a change adds/renames a DocType field, API endpoint, constant, folder, or
  component, **update the matching doc in `docs/` in the same change.** The docs and
  code must never drift apart.

---

## 2. Task → doc routing table

Identify the task type below, then read **only** the listed file(s) — not the whole
`docs/` folder.

| If the task is about... | Read this file |
|---|---|
| Overall product scope, roles (CEO/Manager/Employee), what's in/out of scope | `docs/01_MANAGERIAL_PLANNING.md` |
| High-level architecture, why a decision was made, data model rationale, scale strategy | `docs/02_TECHNICAL_PLANNING.md` |
| "What phase are we in / is this in current scope?" | `docs/03_PHASED_ROADMAP.md` |
| Anything in the Frappe backend: DocTypes, APIs (`analytics_portal/api/`), services, repositories, scheduled jobs, caching, constants, folder structure | `docs/04_BACKEND_RULES.md` |
| Anything in the Vue3 web app: components, composables, Pinia stores, TanStack Query, routing, constants | `docs/05_FRONTEND_WEB_RULES.md` |
| Anything in the Flutter mobile app: widgets, Riverpod providers, Isar, Dio, Clean Architecture layers | `docs/06_MOBILE_RULES.md` |

**Cross-cutting tasks** (e.g. "add a new field that needs backend + both clients"):
read only the specific docs for the layers actually touched — e.g. backend + web
rules, skip mobile rules if mobile isn't part of this task.

**Do not open `01`/`02`/`03`** for routine implementation tasks (adding an endpoint,
fixing a widget, writing a repository method) — those three are for scope/architecture
*decisions*, not day-to-day coding. Go straight to `04`/`05`/`06`.

---

## 3. Where things live

```
apps/analytics_portal/
├── analytics_portal/        # backend app code — see docs/04_BACKEND_RULES.md §11 for exact tree
├── docs/                    # the planning/rule docs referenced above
├── web/                     # Vue3 app — see docs/05_FRONTEND_WEB_RULES.md §6 for exact tree
└── mobile/                  # Flutter app — see docs/06_MOBILE_RULES.md §6 for exact tree
```

---

## 4. Git / GitHub workflow (mandatory for every code push)

- **Remote:** `https://github.com/TaraPranay44/analytics_dashbaord` (GitHub).
- **`develop` is the integration branch.** It plays the role `main`/`master` normally
  plays here — all work lands on `develop` via PR, never by pushing directly to it.
- **Authentication:** use a GitHub PAT or `gh auth login` locally (env var / git
  credential helper). **Never** write a token/PAT into any file in this repo (CLAUDE.md,
  `.env`, config, scripts, commit messages, etc.) or paste it into a commit — a
  committed secret is a leaked secret the moment it's pushed, even to a private repo.
  If a token was ever pasted in plaintext chat/logs, treat it as compromised and
  rotate/revoke it on GitHub afterwards.
- **Before pushing any code, review it against this repo's good/bad practice rules**
  — the non-negotiables in §1 plus the relevant rules doc from §2 (`04_BACKEND_RULES.md`
  / `05_FRONTEND_WEB_RULES.md` / `06_MOBILE_RULES.md` for whatever layer changed):
  no hallucinated APIs, pagination on list endpoints, aggregates read from precomputed
  stat tables, docs updated alongside code, lint/formatters clean. Fix anything that
  fails this check before proceeding.
- **Branching flow for every change:**
  1. Create a `feature/<short-name>` branch (new capability) or `fix/<short-name>`
     branch (bug fix) off the latest `develop` — never commit straight to `develop`.
  2. Commit the change there and push that branch to `origin` first.
  3. Open a PR from that branch **into `develop`**.
  4. Once checks pass (see backend test rule below) and the review above is clean,
     merge the PR into `develop`.
- **Backend changes have a hard gate: all test cases must pass before pushing/merging.**
  Any change under `analytics_portal/` (the Frappe backend) must have its test suite
  run locally, green, before the branch is pushed or the PR is merged. Do not push
  backend changes with failing or skipped tests — fix the tests or the code first.

---

## 5. When in doubt

If a task doesn't clearly map to one row in §2, or the relevant doc doesn't answer
the question, **ask rather than improvising** — this project is deliberately run on
strict written rules specifically so an agent doesn't have to guess.
