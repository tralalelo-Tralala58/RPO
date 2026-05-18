import { useEffect, useState } from 'react';
import { CrudSection } from '../components/CrudSection';
import { PageHeader } from '../components/PageHeader';
import { cardsService } from '../api/services';
import { useAuth } from '../contexts/AuthContext';
import type { Card } from '../types';

export function CardsPage() {
  const { token, isAdmin } = useAuth();
  const [items, setItems] = useState<Card[]>([]);
  const [error, setError] = useState('');

  const loadItems = async () => {
    if (!token) return;
    try {
      setItems(await cardsService.list(token));
      setError('');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Не удалось загрузить карты');
    }
  };

  useEffect(() => {
    void loadItems();
  }, [token]);

  return (
    <>
      <PageHeader title="Карты" description="CRUD для таблицы cards." />
      {error && <div className="alert error">{error}</div>}
      <CrudSection<Card>
        title="Управление картами"
        items={items}
        columns={[
          { key: 'id', header: 'ID' },
          { key: 'card_number', header: 'Номер карты' },
          { key: 'owner_name', header: 'Владелец' },
          { key: 'balance', header: 'Баланс' },
          { key: 'is_locked', header: 'Заблокирована', render: (item) => (item.is_locked ? 'Да' : 'Нет') },
          { key: 'key_id', header: 'Key ID' },
        ]}
        fields={[
          { name: 'card_number', label: 'Номер карты' },
          { name: 'owner_name', label: 'Владелец' },
          { name: 'balance', label: 'Баланс', type: 'number' },
          { name: 'key_id', label: 'ID ключа', type: 'number' },
          { name: 'is_locked', label: 'Карта заблокирована', type: 'checkbox' },
        ]}
        canMutate={isAdmin}
        accessDeniedMessage="Недостаточно прав: обычный пользователь может просматривать карты, но не может изменять или удалять записи."
        onCreate={async (payload) => {
          if (!token) return;
          await cardsService.create(payload, token);
          await loadItems();
        }}
        onUpdate={async (id, payload) => {
          if (!token) return;
          await cardsService.update(id, payload, token);
          await loadItems();
        }}
        onDelete={async (id) => {
          if (!token) return;
          await cardsService.remove(id, token);
          await loadItems();
        }}
      />
    </>
  );
}
