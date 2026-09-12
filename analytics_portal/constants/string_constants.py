"""User-facing labels and message strings.

No literal message string may appear inline in api/, services/, or repositories/
code — import it from here instead (docs/04_BACKEND_RULES.md §10).
"""

EMPLOYEE_NOT_FOUND_MESSAGE: str = "Employee not found."
EMPLOYEE_MANAGER_SELF_REFERENCE_MESSAGE: str = "An employee cannot be their own manager."
EMPLOYEE_MANAGER_CYCLE_MESSAGE: str = "This manager assignment would create a reporting cycle."
ACTIVITY_LOG_LOGOUT_BEFORE_LOGIN_MESSAGE: str = "Logout time cannot be before login time."
