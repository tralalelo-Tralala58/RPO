import { apiClient } from './client';
import type {
  AuthResponse,
  Card,
  KeyRecord,
  LoginRequest,
  Terminal,
  TerminalAuthorizationRequest,
  TerminalAuthorizationResponse,
  Transaction,
  User,
} from '../types';

export const authService = {
  login: (payload: LoginRequest) => apiClient.post<AuthResponse>('/auth/login', payload),
};

export const usersService = {
  list: (token: string) => apiClient.get<User[]>('/users', token),
  create: (payload: Partial<User>, token: string) => apiClient.post<User>('/users', payload, token),
  update: (id: number, payload: Partial<User>, token: string) => apiClient.put<User>(`/users/${id}`, payload, token),
  remove: (id: number, token: string) => apiClient.delete<{ message: string }>(`/users/${id}`, token),
};

export const terminalsService = {
  list: (token: string) => apiClient.get<Terminal[]>('/terminals', token),
  create: (payload: Partial<Terminal>, token: string) => apiClient.post<Terminal>('/terminals', payload, token),
  update: (id: number, payload: Partial<Terminal>, token: string) => apiClient.put<Terminal>(`/terminals/${id}`, payload, token),
  remove: (id: number, token: string) => apiClient.delete<{ message: string }>(`/terminals/${id}`, token),
};

export const cardsService = {
  list: (token: string) => apiClient.get<Card[]>('/cards', token),
  create: (payload: Partial<Card>, token: string) => apiClient.post<Card>('/cards', payload, token),
  update: (id: number, payload: Partial<Card>, token: string) => apiClient.put<Card>(`/cards/${id}`, payload, token),
  remove: (id: number, token: string) => apiClient.delete<{ message: string }>(`/cards/${id}`, token),
};

export const keysService = {
  list: (token: string) => apiClient.get<KeyRecord[]>('/keys', token),
  create: (payload: Partial<KeyRecord>, token: string) => apiClient.post<KeyRecord>('/keys', payload, token),
  update: (id: number, payload: Partial<KeyRecord>, token: string) => apiClient.put<KeyRecord>(`/keys/${id}`, payload, token),
  remove: (id: number, token: string) => apiClient.delete<{ message: string }>(`/keys/${id}`, token),
};

export const transactionsService = {
  list: (token: string) => apiClient.get<Transaction[]>('/transactions', token),
};

export const terminalService = {
  authorize: (payload: TerminalAuthorizationRequest, token: string) =>
    apiClient.post<TerminalAuthorizationResponse>('/terminal/authorize', payload, token),
  keys: (token: string) => apiClient.get<KeyRecord[]>('/terminal/keys', token),
};
