import { useEffect, useState } from 'react';
import { DataTable } from '../components/DataTable';
import { PageHeader } from '../components/PageHeader';
import { transactionsService } from '../api/services';
import { useAuth } from '../contexts/AuthContext';
import type { Transaction } from '../types';

export function TransactionsPage() {
  const { token } = useAuth();
  const [items, setItems] = useState<Transaction[]>([]);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const load = async () => {
    if (!token) return;
    setLoading(true);
    try {
      setItems(await transactionsService.list(token));
      setError('');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Не удалось загрузить транзакции');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void load();
  }, [token]);

  return (
    <>
      <PageHeader
        title="Транзакции"
        description="Просмотр таблицы transactions. Новые записи появляются после успешной авторизации списания на странице 'Терминал'."
      />
      {error && <div className="alert error">{error}</div>}
      <section className="card-section">
        <div className="section-toolbar">
          <button className="primary-button" type="button" onClick={() => void load()} disabled={loading}>
            {loading ? 'Обновляем...' : 'Обновить список'}
          </button>
        </div>
        <DataTable<Transaction>
          columns={[
            { key: 'id', header: 'ID' },
            { key: 'amount', header: 'Сумма' },
            { key: 'card_id', header: 'Card ID' },
            { key: 'terminal_id', header: 'Terminal ID' },
            { key: 'transaction_date', header: 'Дата' },
          ]}
          rows={items}
        />
      </section>
    </>
  );
}
