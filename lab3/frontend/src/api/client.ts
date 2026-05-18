const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? '/api/v1';

const buildHeaders = (token?: string, contentType = true): HeadersInit => ({
  ...(contentType ? { 'Content-Type': 'application/json' } : {}),
  ...(token ? { Authorization: `Bearer ${token}` } : {}),
});

async function handleResponse<T>(response: Response): Promise<T> {
  if (!response.ok) {
    const text = await response.text();

    if (response.status === 401) {
      throw new Error('Нужно заново войти в систему.');
    }

    if (response.status === 403) {
      throw new Error('Недостаточно прав для выполнения этой операции.');
    }

    try {
      const parsed = JSON.parse(text);
      throw new Error(parsed.error ?? parsed.message ?? 'Ошибка запроса');
    } catch {
      throw new Error(text || 'Ошибка запроса');
    }
  }

  if (response.status === 204) {
    return undefined as T;
  }

  return (await response.json()) as T;
}

export const apiClient = {
  get: <T>(path: string, token?: string) =>
    fetch(`${API_BASE_URL}${path}`, {
      method: 'GET',
      headers: buildHeaders(token, false),
    }).then(handleResponse<T>),

  post: <T>(path: string, body: unknown, token?: string) =>
    fetch(`${API_BASE_URL}${path}`, {
      method: 'POST',
      headers: buildHeaders(token),
      body: JSON.stringify(body),
    }).then(handleResponse<T>),

  put: <T>(path: string, body: unknown, token?: string) =>
    fetch(`${API_BASE_URL}${path}`, {
      method: 'PUT',
      headers: buildHeaders(token),
      body: JSON.stringify(body),
    }).then(handleResponse<T>),

  delete: <T>(path: string, token?: string) =>
    fetch(`${API_BASE_URL}${path}`, {
      method: 'DELETE',
      headers: buildHeaders(token, false),
    }).then(handleResponse<T>),
};
