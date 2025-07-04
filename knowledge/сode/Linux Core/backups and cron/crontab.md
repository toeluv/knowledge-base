### **Выполнение рутинных задач в Linux (cron, anacron, systemd, at, /var/spool и другие инструменты)**

---

## **1. Планировщики задач**
### **1.1. Cron (crontab)**
**Cron** — демон для выполнения задач по расписанию в Linux/Unix.  
**Crontab** — файл с расписанием для cron.

#### **Основные команды:**
```bash
crontab -e          # редактировать crontab текущего пользователя
crontab -l          # показать текущие задачи
crontab -r          # удалить все задачи (осторожно!)
```

#### **Формат записи в crontab:**
```
МИН ЧАС ДЕНЬ МЕС ДЕНЬ_НЕДЕЛИ КОМАНДА
```
Примеры:
```bash
* * * * *  command       # каждую минуту
0 * * * *  command       # каждый час (в :00)
30 3 * * * command       # каждый день в 3:30
0 0 * * 0  command       # каждое воскресенье в 00:00
@reboot     command      # при загрузке системы
```

#### **Специальные символы:**
- `*` — любое значение  
- `,` — перечисление (`1,3,5`)  
- `-` — диапазон (`1-5`)  
- `/` — шаг (`*/10` — каждые 10 единиц)  

#### **Примеры задач:**
```bash
# Резервное копирование каждый день в 2:00
0 2 * * * tar -czf /backup/backup.tar.gz /home/user

# Очистка кеша каждые 30 минут
*/30 * * * * rm -rf /tmp/*
```

---

### **1.2. Anacron**
**Anacron** — альтернатива cron для систем, которые не работают 24/7 (например, ноутбуки).  
Задачи выполняются при следующем включении, если пропустили время.

#### **Конфигурация:**
Файлы в `/etc/anacrontab`:
```bash
ПЕРИОД ЗАДЕРЖКА ИМЯ_ЗАДАЧИ КОМАНДА
```
- **ПЕРИОД** — интервал в днях (`1` — ежедневно, `7` — еженедельно).  
- **ЗАДЕРЖКА** — задержка перед выполнением (в минутах).  

#### **Пример:**
```bash
1 5 backup tar -czf /backup/daily.tar.gz /home
7 10 weekly-backup /scripts/cleanup.sh
```

#### **Метки времени в `/var/spool/anacron/`**
Anacron хранит даты последнего выполнения задач в:  
```bash
/var/spool/anacron/cron.daily    # содержит дату в формате YYYYMMDD
```

---

### **1.3. Systemd Timers (альтернатива cron)**
Для систем, использующих `systemd`, можно создавать таймеры.  

#### **Пример:**
1. Создаем сервис (`/etc/systemd/system/backup.service`):
   ```ini
   [Unit]
   Description=Backup Service

   [Service]
   ExecStart=/usr/bin/tar -czf /backup/backup.tar.gz /home
   ```
2. Создаем таймер (`/etc/systemd/system/backup.timer`):
   ```ini
   [Unit]
   Description=Run backup daily

   [Timer]
   OnCalendar=*-*-* 02:00:00
   Persistent=true

   [Install]
   WantedBy=timers.target
   ```
3. Запускаем:
   ```bash
   systemctl enable --now backup.timer
   ```

---

### **1.4. At и Batch**
- **`at`** — выполнение команды **один раз** в заданное время.
  ```bash
  echo "command" | at 15:00
  atq          # список задач
  atrm 1       # удалить задачу с ID=1
  ```
- **`batch`** — выполнение задач при низкой загрузке системы.

#### **Хранение задач в `/var/spool/at/`**
Задачи `at` хранятся в:  
```bash
/var/spool/at/  # файлы вида a0001234
```

---

## **2. Директория `/var/spool` и её роль**
В Linux `/var/spool` хранит временные файлы, ожидающие обработки:

### **2.1. Cron и Anacron**
- **Crontab пользователей** (в RHEL/CentOS):  
  ```bash
  /var/spool/cron/username
  ```
- **Метки времени anacron**:  
  ```bash
  /var/spool/anacron/cron.daily  # дата последнего выполнения
  ```

### **2.2. Почтовые уведомления cron**
Вывод команд cron отправляется в:  
```bash
/var/spool/mail/username  # или /var/mail/username
```
Чтобы отключить почту:  
```bash
0 * * * * command >/dev/null 2>&1
```

### **2.3. Проблемы и решения**
- **Ошибка прав доступа**:  
  ```bash
  sudo chmod 600 /var/spool/cron/username
  ```
- **Сброс anacron**:  
  ```bash
  sudo rm /var/spool/anacron/*
  ```

---

## **3. Полезные команды для отладки**
- **Логи cron**:  
  ```bash
  grep CRON /var/log/syslog
  ```
- **Проверка anacron**:  
  ```bash
  sudo anacron -f -d  # принудительный запуск с логами
  ```
- **Просмотр таймеров systemd**:  
  ```bash
  systemctl list-timers
  journalctl -u backup.service
  ```

---

## **4. Лучшие практики**
1. **Используйте полные пути** (`/usr/bin/tar` вместо `tar`).  
2. **Логируйте выполнение**:  
   ```bash
   * * * * * /script.sh >> /var/log/script.log 2>&1
   ```
3. **Тестируйте команды** перед добавлением в cron.  
4. **Для разовых задач** используйте `at`, для непостоянных систем — `anacron`.  

---

## **Итог**
| Инструмент       | Назначение                          | Где хранятся данные      |
|------------------|-------------------------------------|--------------------------|
| **Cron**         | Регулярные задачи (24/7)            | `/var/spool/cron/`       |
| **Anacron**      | Задачи для ПК/ноутбуков             | `/var/spool/anacron/`    |
| **Systemd Timer**| Современная альтернатива cron       | `/etc/systemd/system/`   |
| **At/Batch**     | Разовые задачи                      | `/var/spool/at/`         |

Директория `/var/spool/` — ключевое место для хранения временных данных планировщиков.
