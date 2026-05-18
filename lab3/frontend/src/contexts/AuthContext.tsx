import { createContext, useContext, useMemo, useState } from 'react';

type CurrentUser = {
  user_id: number;
  login: string;
  is_admin: boolean;
};

type AuthContextValue = {
  token: string | null;
  user: CurrentUser | null;
  isAdmin: boolean;
  isAuthenticated: boolean;
  login: (tokenValue: string) => void;
  logout: () => void;
};

const AuthContext = createContext<AuthContextValue | undefined>(undefined);
const STORAGE_KEY = 'payment-auth-token';

function decodeBase64Url(value: string): string {
  const base64 = value.replace(/-/g, '+').replace(/_/g, '/');
  const padded = base64.padEnd(base64.length + ((4 - (base64.length % 4)) % 4), '=');
  return decodeURIComponent(
    atob(padded)
      .split('')
      .map((char) => `%${char.charCodeAt(0).toString(16).padStart(2, '0')}`)
      .join(''),
  );
}

function getUserFromToken(token: string | null): CurrentUser | null {
  if (!token) return null;

  try {
    const [, payload] = token.split('.');
    if (!payload) return null;

    const parsed = JSON.parse(decodeBase64Url(payload)) as Partial<CurrentUser> & { exp?: number };

    if (parsed.exp && parsed.exp * 1000 < Date.now()) {
      return null;
    }

    if (typeof parsed.user_id !== 'number' || typeof parsed.login !== 'string') {
      return null;
    }

    return {
      user_id: parsed.user_id,
      login: parsed.login,
      is_admin: Boolean(parsed.is_admin),
    };
  } catch {
    return null;
  }
}

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [token, setToken] = useState<string | null>(() => localStorage.getItem(STORAGE_KEY));
  const user = useMemo(() => getUserFromToken(token), [token]);

  const value = useMemo<AuthContextValue>(
    () => ({
      token: user ? token : null,
      user,
      isAdmin: Boolean(user?.is_admin),
      isAuthenticated: Boolean(token && user),
      login: (tokenValue: string) => {
        localStorage.setItem(STORAGE_KEY, tokenValue);
        setToken(tokenValue);
      },
      logout: () => {
        localStorage.removeItem(STORAGE_KEY);
        setToken(null);
      },
    }),
    [token, user],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
}
