# JSONB в PostgreSQL

## Основные понятия
**JSONB** - бинарное представление JSON в PostgreSQL с:
- Поддержкой индексов
- Быстрыми операциями
- Сохранением структуры данных

## Создание таблицы с JSONB
```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    profile JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);
```

## Пример JSONB данных
```json
{
  "age": 28,
  "contacts": {
    "email": "user@example.com",
    "phones": ["+123456789", "+987654321"]
  },
  "preferences": {
    "theme": "dark",
    "notifications": true
  },
  "skills": ["SQL", "PostgreSQL", "JSON"]
}
```

## Основные операторы

### 1. Извлечение данных
- `->` - получить JSON объект/массив
- `->>` - получить текст
- `#>` - получить по пути
- `#>>` - получить текст по пути

**Примеры:**
```sql
-- Получить email как JSON
SELECT profile->'contacts'->'email' FROM users;

-- Получить email как текст
SELECT profile->>'contacts'->>'email' FROM users;

-- Получить первый телефон
SELECT profile#>>'{contacts,phones,0}' FROM users;
```

### 2. Проверка содержимого
- `?` - существует ли ключ
- `?|` - любой из ключей существует
- `?&` - все ключи существуют
- `@>` - содержит ли JSON указанное значение
- `<@` - содержится ли в указанном JSON

**Примеры:**
```sql
-- Пользователи с указанным email
SELECT name FROM users WHERE profile->'contacts' ? 'email';

-- Пользователи с темой 'dark'
SELECT name FROM users WHERE profile @> '{"preferences": {"theme": "dark"}}';
```

### 3. Модификация JSONB
- `||` - объединение
- `-` - удаление ключа
- `#-` - удаление по пути

**Примеры:**
```sql
-- Добавить новый ключ
UPDATE users 
SET profile = profile || '{"status": "active"}'::jsonb;

-- Удалить ключ
UPDATE users 
SET profile = profile - 'status';

-- Удалить второй телефон
UPDATE users 
SET profile = profile #- '{contacts,phones,1}';
```

## Работа с массивами
```sql
-- Добавить элемент в массив
UPDATE users
SET profile = jsonb_set(
  profile,
  '{skills}',
  profile->'skills' || '"NoSQL"'::jsonb
);

-- Проверить наличие элемента
SELECT name FROM users 
WHERE profile->'skills' @> '"PostgreSQL"'::jsonb;
```

## Функции для работы с JSONB

### 1. Создание JSONB
- `jsonb_build_object()` - создать объект
- `jsonb_build_array()` - создать массив

**Пример:**
```sql
SELECT jsonb_build_object(
  'name', 'Test',
  'values', jsonb_build_array(1, 2, 3)
);
```

### 2. Разбор JSONB
- `jsonb_array_elements()` - развернуть массив
- `jsonb_each()` - развернуть объект

**Пример:**
```sql
-- Развернуть массив навыков
SELECT 
  u.name,
  skill.value AS skill
FROM users u,
jsonb_array_elements_text(u.profile->'skills') AS skill;
```

### 3. Агрегация
- `jsonb_agg()` - агрегировать в массив
- `jsonb_object_agg()` - агрегировать в объект

**Пример:**
```sql
-- Собрать все email пользователей в массив
SELECT jsonb_agg(profile->'contacts'->'email') FROM users;
```

## Индексы для JSONB
```sql
-- GIN индекс для всех ключей
CREATE INDEX idx_users_profile ON users USING GIN (profile);

-- Индекс для конкретного поля
CREATE INDEX idx_users_email ON users ((profile->>'contacts'->>'email'));
```

## Практические сценарии

### 1. Динамические атрибуты
```sql
-- Добавление неструктурированных данных
UPDATE products 
SET attributes = attributes || '{"weight": "1.5kg"}'::jsonb;
```

### 2. Поиск по сложным критериям
```sql
-- Найти пользователей с 2+ телефонами
SELECT name FROM users 
WHERE jsonb_array_length(profile->'contacts'->'phones') >= 2;
```

### 3. Частичное обновление
```sql
-- Изменить тему оформления
UPDATE users 
SET profile = jsonb_set(
  profile,
  '{preferences,theme}',
  '"light"'::jsonb
);
```

### 4. Агрегация данных
```sql
-- Статистика по возрастам
SELECT 
  (profile->>'age')::int / 10 * 10 AS age_group,
  COUNT(*) 
FROM users 
GROUP BY age_group;
```

## Оптимизация
1. Для часто используемых полей создавайте отдельные колонки
2. Используйте индексы для часто запрашиваемых JSONB-полей
3. Рассмотрите частичные индексы для фильтров по JSONB

JSONB в PostgreSQL предоставляет гибкость NoSQL с мощью реляционной СУБД.
