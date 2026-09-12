"""Add the `(employee, year_month)` composite index required on `Employee Monthly Stats`.

See docs/04_BACKEND_RULES.md §4.3.
"""

import frappe


def execute() -> None:
	"""Create the composite index via `frappe.db.add_index`."""
	frappe.db.add_index("Employee Monthly Stats", ["employee", "year_month"])
