export type User = {
  id: number;
  login: string;
  name: string;
  password?: string;
  is_admin: boolean;
  created_at?: string;
};

export type Terminal = {
  id: number;
  serial_number: string;
  address: string;
  name: string;
  created_at?: string;
};

export type Card = {
  id: number;
  card_number: string;
  balance: number;
  is_locked: boolean;
  owner_name: string;
  key_id?: number | null;
  created_at?: string;
};

export type KeyRecord = {
  id: number;
  key_value: string;
  description: string;
  created_at?: string;
};

export type Transaction = {
  id: number;
  amount: number;
  card_id: number;
  terminal_id: number;
  transaction_date?: string;
};

export type LoginRequest = {
  login: string;
  password: string;
};

export type AuthResponse = {
  token: string;
};

export type TerminalAuthorizationRequest = {
  card_number: string;
  amount: number;
  terminal_sn: string;
};

export type TerminalAuthorizationResponse = {
  authorized: boolean;
  message?: string;
};

export type Column<T> = {
  key: keyof T | string;
  header: string;
  render?: (item: T) => React.ReactNode;
};
