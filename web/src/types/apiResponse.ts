/**
 * Shared paginated envelope shape - every list-returning `api/v1` endpoint
 * returns this exact shape. See docs/04_BACKEND_RULES.md §5.
 */
export interface PaginatedResponse<T> {
  data: T[];
  start: number;
  limit: number;
  has_more: boolean;
}
