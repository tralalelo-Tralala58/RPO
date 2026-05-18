import { BrowserRouter, Route, Routes } from 'react-router-dom';
import { ProtectedRoute } from './components/ProtectedRoute';
import { AuthProvider } from './contexts/AuthContext';
import { AppLayout } from './layouts/AppLayout';
import { CardsPage } from './pages/CardsPage';
import { DashboardPage } from './pages/DashboardPage';
import { KeysPage } from './pages/KeysPage';
import { LoginPage } from './pages/LoginPage';
import { TerminalToolsPage } from './pages/TerminalToolsPage';
import { TerminalsPage } from './pages/TerminalsPage';
import { TransactionsPage } from './pages/TransactionsPage';
import { UsersPage } from './pages/UsersPage';

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<LoginPage />} />
          <Route element={<ProtectedRoute />}>
            <Route element={<AppLayout />}>
              <Route path="/" element={<DashboardPage />} />
              <Route path="/users" element={<UsersPage />} />
              <Route path="/terminals" element={<TerminalsPage />} />
              <Route path="/cards" element={<CardsPage />} />
              <Route path="/keys" element={<KeysPage />} />
              <Route path="/transactions" element={<TransactionsPage />} />
              <Route path="/terminal-tools" element={<TerminalToolsPage />} />
            </Route>
          </Route>
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}
