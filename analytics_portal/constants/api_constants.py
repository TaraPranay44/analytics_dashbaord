"""Pagination and cache-window defaults shared across the API/service layer.

See docs/04_BACKEND_RULES.md §7 — every list query must be paginated and
capped at PAGE_SIZE_MAX; never hardcode a page size, TTL, or window length
inline elsewhere (§10).
"""

PAGE_SIZE_DEFAULT: int = 20
PAGE_SIZE_MAX: int = 100

# `employee_list` cache TTL in seconds — see docs/04_BACKEND_RULES.md §6.
EMPLOYEE_LIST_CACHE_TTL_SECONDS: int = 90

# Trailing window (days) for the `employee_detail` trend series — see
# docs/04_BACKEND_RULES.md §5 ("a trend series, e.g. daily hours for the
# last 30 days").
EMPLOYEE_DETAIL_TREND_DAYS: int = 30

# Trailing window (days) of `Org Daily Stats` history embedded in
# `org_dashboard`'s response, for the landing page's sparklines/trend badges.
ORG_DASHBOARD_HISTORY_DAYS: int = 14

# `org_insights`: how far below the org-wide average (`avg_hours_org`) counts
# as "low hours" for the `low_hours_employee_count` figure.
LOW_HOURS_MARGIN_HOURS: float = 1.0

# `org_insights`: trailing window (days) for the "recently joined" headcount figure.
RECENT_HIRES_WINDOW_DAYS: int = 90

# `org_insights`: comparison window (days) for the registered-headcount growth figure.
HEADCOUNT_GROWTH_WINDOW_DAYS: int = 30

# `org_dashboard`: how many trailing months of registered-headcount snapshots
# to embed as `headcount_trend`, for the "employees tracked" sparkline
# (monthly, not daily - headcount barely moves day to day at this org's size).
HEADCOUNT_TREND_MONTHS: int = 12
