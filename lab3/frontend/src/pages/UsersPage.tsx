import { useEffect, useState } from 'react';
import { CrudSection } from '../components/CrudSection';
import { PageHeader } from '../components/PageHeader';
import { usersService } from '../api/services';
import { useAuth } from '../contexts/AuthContext';
import type { User } from '../types';

export function UsersPage() {
  const { token, isAdmin } = useAuth();
  const [users, setUsers] = useState<User[]>([]);
  const [error, setError] = useState('');

  const loadUsers = async () => {
    if (!token) return;
    try {
      setUsers(await usersService.list(token));
      setError('');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Не удалось загрузить пользователей');
    }
  };

  useEffect(() => {
    void loadUsers();
  }, [token]);

  return (
    <>
      <PageHeader title="Пользователи" description="CRUD для таблицы users." />
      {error && <div className="alert error">{error}</div>}
      <CrudSection<User>
        title="Управление пользователями"
        items={users}
        columns={[
          { key: 'id', header: 'ID' },
          { key: 'login', header: 'Логин' },
          { key: 'name', header: 'Имя' },
          { key: 'is_admin', header: 'Админ', render: (item) => (item.is_admin ? 'Да' : 'Нет') },
        ]}
        fields={[
          { name: 'login', label: 'Логин' },
          { name: 'name', label: 'Имя' },
          { name: 'password', label: 'Пароль' },
          { name: 'is_admin', label: 'Администратор', type: 'checkbox' },
        ]}
        canMutate={isAdmin}
        accessDeniedMessage="Недостаточно прав: обычный пользователь может просматривать пользователей, но не может изменять или удалять записи."
        onCreate={async (payload) => {
          if (!token) return;
          await usersService.create(payload, token);
          await loadUsers();
        }}
        onUpdate={async (id, payload) => {
          if (!token) return;
          await usersService.update(id, payload, token);
          await loadUsers();
        }}
        onDelete={async (id) => {
          if (!token) return;
          await usersService.remove(id, token);
          await loadUsers();
        }}
      />
    </>
  );
}
