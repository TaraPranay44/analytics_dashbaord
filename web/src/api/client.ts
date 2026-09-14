import { frappeRequest } from 'frappe-ui'

export async function callApi<T>(
  method: string,
  params: Record<string, string | number | undefined> = {}
): Promise<T> {
  const cleanParams: Record<string, string | number> = {}

  Object.entries(params).forEach(([key, value]) => {
    if (value !== undefined) {
      cleanParams[key] = value
    }
  })

  return frappeRequest({
    url: `/api/method/${method}`,
    method: 'GET',
    params: cleanParams,
  }) as Promise<T>
}