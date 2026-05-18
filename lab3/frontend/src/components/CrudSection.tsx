import { useEffect, useMemo, useState } from 'react';
import { DataTable } from './DataTable';
import type { Column } from '../types';

type FieldConfig<T> = {
  name: keyof T;
  label: string;
  type?: 'text' | 'number' | 'checkbox';
  placeholder?: string;
};

type CrudSectionProps<T extends { id: number }> = {
  title: string;
  columns: Column<T>[];
  fields: FieldConfig<T>[];
  items: T[];
  onCreate: (payload: Partial<T>) => Promise<void>;
  onUpdate: (id: number, payload: Partial<T>) => Promise<void>;
  onDelete: (id: number) => Promise<void>;
  canMutate?: boolean;
  accessDeniedMessage?: string;
};

function getInitialState<T>(fields: FieldConfig<T>[]): Record<string, unknown> {
  return fields.reduce<Record<string, unknown>>((acc, field) => {
    acc[String(field.name)] = field.type === 'checkbox' ? false : '';
    return acc;
  }, {});
}

export function CrudSection<T extends { id: number }>({
  title,
  columns,
  fields,
  items,
  onCreate,
  onUpdate,
  onDelete,
  canMutate = true,
  accessDeniedMessage = 'Недостаточно прав для выполнения этой операции.',
}: CrudSectionProps<T>) {
  const [editingId, setEditingId] = useState<number | null>(null);
  const initialFormState = useMemo(() => getInitialState(fields), [fields]);
  const [formData, setFormData] = useState<Record<string, unknown>>(initialFormState);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [localMessage, setLocalMessage] = useState('');

  useEffect(() => {
    if (editingId === null) {
      setFormData(initialFormState);
    }
  }, [editingId, initialFormState]);

  const denyAccess = () => {
    setLocalMessage(accessDeniedMessage);
  };

  const submit = async (event: React.FormEvent) => {
    event.preventDefault();

    if (!canMutate) {
      denyAccess();
      return;
    }

    setIsSubmitting(true);
    setLocalMessage('');
    try {
      const payload = Object.fromEntries(
        Object.entries(formData).map(([key, value]) => {
          if (value === '') return [key, undefined];
          return [key, value];
        }),
      ) as Partial<T>;

      if (editingId === null) {
        await onCreate(payload);
      } else {
        await onUpdate(editingId, payload);
      }

      setEditingId(null);
      setFormData(initialFormState);
    } catch (err) {
      setLocalMessage(err instanceof Error ? err.message : 'Операция не выполнена');
    } finally {
      setIsSubmitting(false);
    }
  };

  const startEdit = (item: T) => {
    if (!canMutate) {
      denyAccess();
      return;
    }

    setLocalMessage('');
    setEditingId(item.id);
    const nextState = { ...initialFormState };
    fields.forEach((field) => {
      nextState[String(field.name)] = item[field.name] as unknown;
    });
    setFormData(nextState);
  };

  const deleteItem = async (id: number) => {
    if (!canMutate) {
      denyAccess();
      return;
    }

    setLocalMessage('');
    try {
      await onDelete(id);
    } catch (err) {
      setLocalMessage(err instanceof Error ? err.message : 'Удаление не выполнено');
    }
  };

  return (
    <section className="card-section">
      <div className="section-head">
        <h2>{title}</h2>
      </div>

      {!canMutate && <div className="alert warning">{accessDeniedMessage}</div>}
      {localMessage && <div className="alert error">{localMessage}</div>}

      {canMutate && (
        <form className="entity-form" onSubmit={submit}>
          <div className="grid-form">
            {fields.map((field) => (
              <label key={String(field.name)} className={field.type === 'checkbox' ? 'checkbox-field' : ''}>
                <span>{field.label}</span>
                {field.type === 'checkbox' ? (
                  <input
                    type="checkbox"
                    checked={Boolean(formData[String(field.name)])}
                    onChange={(event) =>
                      setFormData((prev) => ({
                        ...prev,
                        [String(field.name)]: event.target.checked,
                      }))
                    }
                  />
                ) : (
                  <input
                    type={field.type ?? 'text'}
                    value={String(formData[String(field.name)] ?? '')}
                    placeholder={field.placeholder}
                    onChange={(event) =>
                      setFormData((prev) => ({
                        ...prev,
                        [String(field.name)]: field.type === 'number' ? Number(event.target.value) : event.target.value,
                      }))
                    }
                  />
                )}
              </label>
            ))}
          </div>

          <div className="form-actions">
            <button className="primary-button" type="submit" disabled={isSubmitting}>
              {editingId === null ? 'Создать' : 'Сохранить'}
            </button>
            {editingId !== null && (
              <button className="ghost-button" type="button" onClick={() => setEditingId(null)}>
                Отмена
              </button>
            )}
          </div>
        </form>
      )}

      <DataTable
        columns={columns}
        rows={items}
        actions={
          canMutate
            ? (item) => (
                <>
                  <button className="table-button" type="button" onClick={() => startEdit(item)}>
                    Изменить
                  </button>
                  <button className="table-button danger" type="button" onClick={() => void deleteItem(item.id)}>
                    Удалить
                  </button>
                </>
              )
            : undefined
        }
      />
    </section>
  );
}
