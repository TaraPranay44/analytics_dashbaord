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
