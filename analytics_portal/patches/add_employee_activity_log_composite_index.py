"""Add the `(employee, date)` composite index required on `Employee Activity Log`.

See docs/04_BACKEND_RULES.md §4.2 — this table is expected to hold 11M+ rows,
so this index is required for `employee_logs` / stats jobs to stay fast.
"""

import frappe


def execute() -> None:
	"""Create the composite index via `frappe.db.add_index`."""
	frappe.db.add_index("Employee Activity Log", ["employee", "date"])
