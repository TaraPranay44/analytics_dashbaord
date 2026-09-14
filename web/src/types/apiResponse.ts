export interface PaginatedResponse<T> {
  data: T[]
  start: number
  limit: number
  has_more: boolean
}