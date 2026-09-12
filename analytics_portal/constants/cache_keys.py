"""Cache key builders for Redis-backed `frappe.cache()` usage.

Every cache key used anywhere in this app must be built by one of these
functions — never assembled as a raw string inline. See docs/04_BACKEND_RULES.md §6
for the TTL/invalidation contract of each key pattern below.
"""


def search_key(query_hash: str) -> str:
	"""Build the cache key for an employee search result page.

	Args:
	    query_hash: hash of the normalized search query string.

	Returns:
	    Cache key in the `cache:search:{query_hash}` pattern (TTL 90s).
	"""
	return f"cache:search:{query_hash}"


def emp_summary_key(employee_id: str) -> str:
	"""Build the cache key for an employee's summary card data.

	Args:
	    employee_id: the `Employee.employee_id` value.

	Returns:
	    Cache key in the `cache:emp_summary:{employee_id}` pattern, invalidated
	    by the nightly aggregation job.
	"""
	return f"cache:emp_summary:{employee_id}"


def org_dashboard_key() -> str:
	"""Build the cache key for the org-wide dashboard tiles.

	Returns:
	    The `cache:org_dashboard` cache key, invalidated by the nightly
	    aggregation job.
	"""
	return "cache:org_dashboard"
