В `nginx` директива `location` используется внутри блока `server` и определяет, как `nginx` будет обрабатывать запросы, соответствующие определённым URL-путям. Эта директива часто используется в связке с `proxy_pass` — для проксирования запросов на другой сервер или порт. Ниже — подробное объяснение с особенностями:

---

## 📌 Основы `location`

Синтаксис:

```nginx
location [modifiers] [pattern] {
    # настройки
}
```

### Основные модификаторы:

| Модификатор          | Описание                                                                            |
| -------------------- | ----------------------------------------------------------------------------------- |
| `= `                 | Точное совпадение пути.                                                             |
| `~`                  | Совпадение по **регистрозависимому** регулярному выражению.                         |
| `~*`                 | Регистронезависимое регулярное выражение.                                           |
| `^~`                 | Если найдено совпадение по началу строки (префиксное), прекратить дальнейший поиск. |
| *(без модификатора)* | Префиксное совпадение по пути URI. Может быть перекрыто регулярным выражением.      |

Примеры:

```nginx
location = / {
    # Точное совпадение: только "/"
}
location /images/ {
    # Любой путь начинающийся с "/images/"
}
location ~* \.(jpg|png)$ {
    # Регулярка: все .jpg и .png (регистр игнорируется)
}
```

---

## 🌀 `proxy_pass`: Основы и особенности

### Синтаксис:

```nginx
proxy_pass URL;
```

`proxy_pass` указывает, куда перенаправлять запросы. Это может быть:

* **Протокол + домен/IP + порт** (например, `http://localhost:3000`)
* **Просто URI-путь**, если нужно направить на другой location внутри `nginx`

---

### ⚠️ Важная особенность: поведение `proxy_pass` зависит от **того, заканчивается ли путь в `location` на `/` или нет**.

#### 📍 Примеры:

### 🔹 Пример 1: без `/` в `location` и без изменения URI

```nginx
location /api {
    proxy_pass http://backend;
}
```

**Поведение:**

* Если пришел запрос `/api/users`, то он будет отправлен как `http://backend/api/users`
* Т.е. **часть URI сохраняется**

---

### 🔹 Пример 2: с `/` в `location`, но без неё в `proxy_pass`

```nginx
location /api/ {
    proxy_pass http://backend;
}
```

**Поведение:**

* Запрос `/api/users` отправится как `http://backend/users`
* Т.е. **часть `/api/` обрезается**, и подставляется "хвост" URI.

---

### 🔹 Пример 3: с `/` в `location` и в `proxy_pass`

```nginx
location /api/ {
    proxy_pass http://backend/;
}
```

**Поведение:**

* `/api/users` → `http://backend/users`
* Всё так же, как и выше — потому что в `proxy_pass` указан слэш на конце.
  Он говорит: "не добавляй `/api/` при проксировании".

---

### ❗ Резюме:

| Location | Proxy\_pass       | Внешний URI | Прокси URI                |
| -------- | ----------------- | ----------- | ------------------------- |
| `/api`   | `http://backend`  | `/api/test` | `http://backend/api/test` |
| `/api/`  | `http://backend`  | `/api/test` | `http://backend/test`     |
| `/api/`  | `http://backend/` | `/api/test` | `http://backend/test`     |

---

## 🧠 Полезные директивы с `proxy_pass`

* `proxy_set_header Host $host;` — передаёт оригинальный `Host` заголовок (или меняет его)
* `proxy_set_header X-Real-IP $remote_addr;` — передаёт IP клиента
* `proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;`
* `proxy_http_version 1.1;` — если бекенд использует keep-alive
* `proxy_redirect off;` — отключить редиректы от бэкенда

---

## 🛠 Пример боевой конфигурации

```nginx
server {
    listen 80;
    server_name example.com;

    location /api/ {
        proxy_pass http://localhost:3000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
    }

    location / {
        root /var/www/html;
        index index.html;
    }
}
```

### 💡 Главное правило (при **proxy\_pass без слэша на конце**):

> Если `location` **НЕ заканчивается на `/`**, Nginx **не обрезает** из URI путь из `location` при проксировании.

А вот если `location` **заканчивается на `/`**, то та часть, которая совпадает с `location`, **обрезается**, и оставшийся хвост подставляется к `proxy_pass`.

---

Теперь разберем твои **3 варианта**, подробно с объяснением:

---

## ✅ Вариант 1:

```nginx
location ^~ /api/test {
    proxy_pass http://backend:8080/api;
}
```

### 🔎 Поведение:

* Запрос: `/api/test/foo`
* URI **не изменяется**, так как:

  * `location` не заканчивается на `/`
  * `proxy_pass` тоже **без** `/` на конце

### 🧠 Что получится:

* Прокси-URL: `http://backend:8080/api/test/foo`

→ **Итого**: к `proxy_pass` прибавляется **весь URI запроса**, не обрезая `location`.

---

## ✅ Вариант 2:

```nginx
location ^~ /api/test {
    proxy_pass http://backend:8080/api/test;
}
```

### 🔎 Поведение:

* Запрос: `/api/test/foo`
* URI не изменяется (аналогично 1-му варианту)

### 🧠 Что получится:

* Прокси-URL: `http://backend:8080/api/test/foo`

→ **Итого**: URI почти полностью дублируется. Это часто **ошибка проектирования**, если ты не хочешь повторяющийся путь на бэкенде.

---

## ✅ Вариант 3:

```nginx
location ^~ /api/test {
    proxy_pass http://backend:8080/test;
}
```

### 🔎 Поведение:

* Запрос: `/api/test/foo`
* URI **не обрезается**
* Итого URI, отправляемый на бекенд: `/api/test/foo`

### 🧠 Что получится:

* Прокси-URL: `http://backend:8080/test/api/test/foo`

→ ❗ ВНИМАНИЕ: путь дублируется: **`/test/api/test/foo`**

→ Это **ошибка**, если ты предполагал, что `/test` заменит `/api/test`. В таком случае, надо правильно настроить **обрезку URI** (см. ниже).

---

## 🛠 Как правильно "заменить" путь?

Если ты хочешь, чтобы клиент запрашивал `/api/test/foo`, а бэкенд получал `/foo`, нужно:

```nginx
location ^~ /api/test/ {
    proxy_pass http://backend:8080/;
}
```

→ Здесь `/api/test/` будет **обрезано**, и оставшийся хвост (`foo`) подставится к `http://backend:8080/`.

---

## 🔄 Визуальная сводка

| Конфигурация                                   | URI клиента     | Итоговый proxy URL                   | Комментарий              |
| ---------------------------------------------- | --------------- | ------------------------------------ | ------------------------ |
| `/api/test` → `proxy_pass http://.../api`      | `/api/test/foo` | `/api/test/foo` → `.../api/test/foo` | `location` не обрезается |
| `/api/test` → `proxy_pass http://.../api/test` | `/api/test/foo` | `.../api/test/foo`                   | Повторный путь           |
| `/api/test` → `proxy_pass http://.../test`     | `/api/test/foo` | `.../test/api/test/foo`              | Часто ошибка             |
| `/api/test/` → `proxy_pass http://.../`        | `/api/test/foo` | `.../foo`                            | Правильная обрезка пути  |

---

## 🔧 Рекомендация

Если ты хочешь перекидывать `/api/test` → `/test` на бэкенде, используй:

```nginx
location ^~ /api/test/ {
    proxy_pass http://backend:8080/test/;
}
```

→ Тогда:

* `/api/test/foo` → `http://backend:8080/test/foo`

