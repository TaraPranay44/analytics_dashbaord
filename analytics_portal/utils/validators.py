"""Shared input validation helpers.

See docs/04_BACKEND_RULES.md §9/§5 — every endpoint must validate `employee_id`
exists before querying further, raising frappe.DoesNotExistError, not returning
a silent empty response.
"""


def assert_employee_exists(employee_id: str) -> None:
	"""Raise frappe.DoesNotExistError if no Employee with this employee_id exists.

	Args:
	    employee_id: the `Employee.employee_id` value to check.

	Raises:
	    frappe.DoesNotExistError: if no matching Employee record exists.
	"""
	raise NotImplementedError
