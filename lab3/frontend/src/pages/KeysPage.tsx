import { useEffect, useState } from 'react';
import { CrudSection } from '../components/CrudSection';
import { PageHeader } from '../components/PageHeader';
import { keysService } from '../api/services';
import { useAuth } from '../contexts/AuthContext';
import type { KeyRecord } from '../types';

export function KeysPage() {
  const { token, isAdmin } = useAuth();
  const [items, setItems] = useState<KeyRecord[]>([]);
  const [error, setError] = useState('');

  const loadItems = async () => {
    if (!token) return;
    try {
      setItems(await keysService.list(token));
      setError('');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Не удалось загрузить ключи');
    }
  };

  useEffect(() => {
    void loadItems();
  }, [token]);

  return (
    <>
      <PageHeader title="Ключи" description="CRUD для таблицы keys." />
      {error && <div className="alert error">{error}</div>}
      <CrudSection<KeyRecord>
        title="Управление ключами"
        items={items}
        columns={[
          { key: 'id', header: 'ID' },
          { key: 'key_value', header: 'Значение ключа' },
          { key: 'description', header: 'Описание' },
        ]}
        fields={[
          { name: 'key_value', label: 'Значение ключа' },
          { name: 'description', label: 'Описание' },
        ]}
        canMutate={isAdmin}
        accessDeniedMessage="Недостаточно прав: обычный пользователь может просматривать ключи, но не может изменять или удалять записи."
        onCreate={async (payload) => {
          if (!token) return;
          await keysService.create(payload, token);
          await loadItems();
        }}
        onUpdate={async (id, payload) => {
          if (!token) return;
          await keysService.update(id, payload, token);
          await loadItems();
        }}
        onDelete={async (id) => {
          if (!token) return;
          await keysService.remove(id, token);
          await loadItems();
        }}
      />
    </>
  );
}
