import { PageHeader } from '../components/PageHeader';

const cards = [
  {
    title: 'JWT авторизация',
    text: 'Логин через /auth/login и хранение токена в localStorage для всех защищённых запросов.',
  },
  {
    title: 'CRUD-панели',
    text: 'Отдельные страницы для users, terminals, cards, keys и просмотра transactions.',
  },
  {
    title: 'Инструменты терминала',
    text: 'Проверка авторизации списания и загрузка ключей через специальные terminal endpoints.',
  },
];

export function DashboardPage() {
  return (
    <>
      <PageHeader
        title="Панель управления сервером"
        description="Это готовый React frontend для твоего Go + SQLite + JWT проекта."
      />

      <section className="stats-grid">
        {cards.map((card) => (
          <article key={card.title} className="info-card">
            <h3>{card.title}</h3>
            <p>{card.text}</p>
          </article>
        ))}
      </section>

      <section className="card-section">
        <h2>Что уже реализовано</h2>
        <p>
          SPA на React + TypeScript, роутинг, общая API-обвязка, защищённые страницы, формы создания и редактирования,
          табличное отображение данных и отдельный экран для операций терминала.
        </p>
      </section>
    </>
  );
}
