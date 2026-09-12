"""Named error codes raised by the service layer.

Paired with docs/04_BACKEND_RULES.md §10 — services raise these, never an
ad-hoc string, so clients can match on a stable code.
"""

EMPLOYEE_NOT_FOUND: str = "EMPLOYEE_NOT_FOUND"
