"""Wrapper around `frappe.cache()` implementing a get-or-set pattern.

See docs/04_BACKEND_RULES.md §6/§9 — every cache read must have a deliberate
invalidation path (TTL or event-based), stated at the call site.
"""

from collections.abc import Callable
from typing import Any


def get_or_set(key: str, ttl: int | None, compute_fn: Callable[[], Any]) -> Any:
	"""Return the cached value for `key`, computing and caching it on a miss.

	Args:
	    key: cache key, built via one of `constants/cache_keys.py`'s functions.
	    ttl: time-to-live in seconds, or None for keys invalidated only by an
	        explicit event (e.g. the nightly aggregation job clearing it).
	    compute_fn: zero-arg callable that computes the value on a cache miss.

	Returns:
	    The cached or freshly computed value.
	"""
	raise NotImplementedError
