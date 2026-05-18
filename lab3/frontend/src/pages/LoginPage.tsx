import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { authService } from '../api/services';
import { useAuth } from '../contexts/AuthContext';

export function LoginPage() {
  const navigate = useNavigate();
  const { login } = useAuth();
  const [form, setForm] = useState({ login: '', password: '' });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const submit = async (event: React.FormEvent) => {
    event.preventDefault();
    setLoading(true);
    setError('');

    try {
      const response = await authService.login(form);
      login(response.token);
      navigate('/');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Ошибка входа');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="auth-page">
      <form className="auth-card" onSubmit={submit}>
        <p className="brand-label">JWT login</p>
        <h1>Вход в панель управления</h1>
        <p>Используй логин и пароль из backend, чтобы работать с таблицами и терминалом.</p>

        <label>
          <span>Логин</span>
          <input
            value={form.login}
            onChange={(event) => setForm((prev) => ({ ...prev, login: event.target.value }))}
            placeholder="admin"
          />
        </label>

        <label>
          <span>Пароль</span>
          <input
            type="password"
            value={form.password}
            onChange={(event) => setForm((prev) => ({ ...prev, password: event.target.value }))}
            placeholder="••••••••"
          />
        </label>

        {error && <div className="alert error">{error}</div>}

        <button className="primary-button full-width" type="submit" disabled={loading}>
          {loading ? 'Входим...' : 'Войти'}
        </button>
      </form>
    </div>
  );
}
