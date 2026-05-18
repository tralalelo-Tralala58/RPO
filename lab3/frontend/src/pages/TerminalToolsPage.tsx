import { useState } from 'react';
import { terminalService } from '../api/services';
import { PageHeader } from '../components/PageHeader';
import { useAuth } from '../contexts/AuthContext';
import type { KeyRecord, TerminalAuthorizationResponse } from '../types';

const ACCESS_DENIED_MESSAGE = 'Недостаточно прав: операции терминала доступны только администратору.';

export function TerminalToolsPage() {
  const { token, isAdmin } = useAuth();
  const [form, setForm] = useState({ card_number: '', amount: 0, terminal_sn: '' });
  const [result, setResult] = useState<TerminalAuthorizationResponse | null>(null);
  const [keys, setKeys] = useState<KeyRecord[]>([]);
  const [error, setError] = useState('');

  const authorize = async (event: React.FormEvent) => {
    event.preventDefault();
    if (!token) return;

    if (!isAdmin) {
      setResult(null);
      setError(ACCESS_DENIED_MESSAGE);
      return;
    }

    try {
      const response = await terminalService.authorize(form, token);
      setResult(response);
      setError('');
    } catch (err) {
      setResult(null);
      setError(err instanceof Error ? err.message : 'Ошибка авторизации транзакции');
    }
  };

  const loadKeys = async () => {
    if (!token) return;

    if (!isAdmin) {
      setKeys([]);
      setError(ACCESS_DENIED_MESSAGE);
      return;
    }

    try {
      setKeys(await terminalService.keys(token));
      setError('');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Не удалось загрузить ключи');
    }
  };

  return (
    <>
      <PageHeader title="Инструменты терминала" description="Проверка terminal API из браузера." />
      {!isAdmin && <div className="alert warning">{ACCESS_DENIED_MESSAGE}</div>}
      {error && <div className="alert error">{error}</div>}

      <section className="two-columns">
        <article className="card-section">
          <h2>Авторизация списания</h2>
          <form className="entity-form" onSubmit={authorize}>
            <label>
              <span>Номер карты</span>
              <input
                value={form.card_number}
                onChange={(event) => setForm((prev) => ({ ...prev, card_number: event.target.value }))}
              />
            </label>
            <label>
              <span>Сумма</span>
              <input
                type="number"
                value={form.amount}
                onChange={(event) => setForm((prev) => ({ ...prev, amount: Number(event.target.value) }))}
              />
            </label>
            <label>
              <span>Серийный номер терминала</span>
              <input
                value={form.terminal_sn}
                onChange={(event) => setForm((prev) => ({ ...prev, terminal_sn: event.target.value }))}
              />
            </label>
            <button className="primary-button" type="submit">
              Проверить транзакцию
            </button>
          </form>

          {result && (
            <div className={`alert ${result.authorized ? 'success' : 'error'}`}>
              {result.authorized ? 'Одобрено' : 'Отклонено'}: {result.message}
            </div>
          )}
        </article>

        <article className="card-section">
          <h2>Загрузка ключей</h2>
          <button className="primary-button" type="button" onClick={loadKeys}>
            Получить ключи
          </button>
          <div className="keys-list">
            {keys.map((key) => (
              <div key={key.id} className="key-item">
                <strong>#{key.id}</strong>
                <span>{key.description || 'Без описания'}</span>
                <code>{key.key_value}</code>
              </div>
            ))}
            {keys.length === 0 && <p className="muted">Ключи ещё не загружены.</p>}
          </div>
        </article>
      </section>
    </>
  );
}
