import { useEffect, useState } from 'react';
import { CrudSection } from '../components/CrudSection';
import { PageHeader } from '../components/PageHeader';
import { terminalsService } from '../api/services';
import { useAuth } from '../contexts/AuthContext';
import type { Terminal } from '../types';

export function TerminalsPage() {
  const { token, isAdmin } = useAuth();
  const [items, setItems] = useState<Terminal[]>([]);
  const [error, setError] = useState('');

  const loadItems = async () => {
    if (!token) return;
    try {
      setItems(await terminalsService.list(token));
      setError('');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Не удалось загрузить терминалы');
    }
  };

  useEffect(() => {
    void loadItems();
  }, [token]);

  return (
    <>
      <PageHeader title="Терминалы" description="CRUD для таблицы terminals." />
      {error && <div className="alert error">{error}</div>}
      <CrudSection<Terminal>
        title="Управление терминалами"
        items={items}
        columns={[
          { key: 'id', header: 'ID' },
          { key: 'serial_number', header: 'Серийный номер' },
          { key: 'name', header: 'Название' },
          { key: 'address', header: 'Адрес' },
        ]}
        fields={[
          { name: 'serial_number', label: 'Серийный номер' },
          { name: 'name', label: 'Название' },
          { name: 'address', label: 'Адрес' },
        ]}
        canMutate={isAdmin}
        accessDeniedMessage="Недостаточно прав: обычный пользователь может просматривать терминалы, но не может изменять или удалять записи."
        onCreate={async (payload) => {
          if (!token) return;
          await terminalsService.create(payload, token);
          await loadItems();
        }}
        onUpdate={async (id, payload) => {
          if (!token) return;
          await terminalsService.update(id, payload, token);
          await loadItems();
        }}
        onDelete={async (id) => {
          if (!token) return;
          await terminalsService.remove(id, token);
          await loadItems();
        }}
      />
    </>
  );
}
