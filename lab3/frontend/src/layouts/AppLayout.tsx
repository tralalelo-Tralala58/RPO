import { NavLink, Outlet } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

const navItems = [
  { to: '/', label: 'Главная' },
  { to: '/users', label: 'Пользователи' },
  { to: '/terminals', label: 'Терминалы' },
  { to: '/cards', label: 'Карты' },
  { to: '/keys', label: 'Ключи' },
  { to: '/transactions', label: 'Транзакции' },
  { to: '/terminal-tools', label: 'Терминал' },
];

export function AppLayout() {
  const { logout, user, isAdmin } = useAuth();

  return (
    <div className="app-shell">
      <aside className="sidebar">
        <div>
          <div className="brand-block">
            <p className="brand-label">React frontend</p>
            <h2>{isAdmin ? 'Payment Auth Admin' : 'Payment Auth User'}</h2>
            <div className="user-chip">
              <span>{user?.login ?? 'Пользователь'}</span>
              <strong>{isAdmin ? 'Администратор' : 'Обычный пользователь'}</strong>
            </div>
          </div>

          <nav className="nav-menu">
            {navItems.map((item) => (
              <NavLink
                key={item.to}
                to={item.to}
                end={item.to === '/'}
                className={({ isActive }) => `nav-link ${isActive ? 'active' : ''}`}
              >
                {item.label}
              </NavLink>
            ))}
          </nav>
        </div>

        <button type="button" className="ghost-button full-width" onClick={logout}>
          Выйти
        </button>
      </aside>

      <main className="content-area">
        <Outlet />
      </main>
    </div>
  );
}
