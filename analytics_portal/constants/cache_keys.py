"""Cache key builders for Redis-backed `frappe.cache()` usage.

Every cache key used anywhere in this app must be built by one of these
functions - never assembled as a raw string inline. See docs/04_BACKEND_RULES.md §6
for the TTL/invalidation contract of each key pattern below.

⚠️ Correction note (post-review): `search_key`/`emp_summary_key` were renamed to
`employee_list_key`/`employee_detail_key` to match the corrected `employee_list`/
`employee_detail` endpoints in docs/04_BACKEND_RULES.md §5.
"""

import hashlib


def employee_list_key(q: str, manager: str | None, sort: str | None, start: int, limit: int) -> str:
	"""Build the cache key for one page of the `employee_list` directory.

	Args:
	    q: search string (name/ID fragment); empty string means browse-all.
	    manager: optional manager `employee_id` filter.
	    sort: optional sort spec.
	    start: zero-based row offset.
	    limit: page size.

	Returns:
	    Cache key in the `cache:employee_list:{query_hash}` pattern (TTL 90s),
	    where `query_hash` folds in every param so different pages/filters
	    cache separately.
	"""
	raw = f"{q}|{manager}|{sort}|{start}|{limit}"
	query_hash = hashlib.sha256(raw.encode("utf-8")).hexdigest()
	return f"cache:employee_list:{query_hash}"


def employee_detail_key(employee_id: str) -> str:
	"""Build the cache key for one employee's `employee_detail` data.

	Args:
	    employee_id: the `Employee.employee_id` value.

	Returns:
	    Cache key in the `cache:employee_detail:{employee_id}` pattern,
	    invalidated by the nightly aggregation job.
	"""
	return f"cache:employee_detail:{employee_id}"


def org_dashboard_key() -> str:
	"""Build the cache key for the org-wide dashboard tiles.

	Returns:
	    The `cache:org_dashboard` cache key, invalidated by the nightly
	    aggregation job.
	"""
	return "cache:org_dashboard"
