"""Pagination defaults shared by every list-returning API endpoint.

See docs/04_BACKEND_RULES.md §7 — every list query must be paginated and
capped at PAGE_SIZE_MAX; never hardcode a page size inline elsewhere.
"""

PAGE_SIZE_DEFAULT: int = 20
PAGE_SIZE_MAX: int = 100
