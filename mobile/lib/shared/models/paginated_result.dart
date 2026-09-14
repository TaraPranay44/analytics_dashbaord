/// Shared paginated envelope shape - every list-returning `api/v1` endpoint
/// returns this exact shape (`{"data": [...], "start", "limit", "has_more"}`).
/// See docs/04_BACKEND_RULES.md §5. Mirrors web/src/types/apiResponse.ts.
class PaginatedResult<T> {
  const PaginatedResult({
    required this.data,
    required this.start,
    required this.limit,
    required this.hasMore,
  });

  final List<T> data;
  final int start;
  final int limit;
  final bool hasMore;
}
