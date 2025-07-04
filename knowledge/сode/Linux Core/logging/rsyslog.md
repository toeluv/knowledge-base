### **Rsyslog: система логирования в Linux**

**Rsyslog** — это мощная система сбора, обработки и пересылки логов в Linux. Она пришла на смену старому **syslogd** и поддерживает:
- Фильтрацию логов по различным критериям,
- Запись в файлы, базы данных (MySQL, PostgreSQL) и удалённые серверы,
- Шифрование передаваемых логов (TLS),
- Гибкую настройку формата сообщений,
- Интеграцию с **systemd-journald**.

---

## **1. Основные возможности**
- **Поддержка протокола syslog (RFC 3164 и RFC 5424)**  
  Совместимость с legacy-системами.
- **Модульность**  
  Можно подключать модули для работы с базами данных, шифрования и др.
- **Высокая производительность**  
  Поддержка многопоточной обработки и очередей.
- **Гибкие правила фильтрации**  
  Логи можно сортировать по приоритету, тегу, хосту и другим параметрам.
- **Удалённая пересылка**  
  Возможность централизованного сбора логов на одном сервере.

---

## **2. Конфигурация Rsyslog**
Основной конфигурационный файл:  
- `/etc/rsyslog.conf` – главный файл настроек,  
- `/etc/rsyslog.d/*.conf` – дополнительные конфиги (рекомендуется использовать их).  

### **Структура конфигурации**
1. **Модули**  
   Загружаются в начале файла:
   ```bash
   module(load="imuxsock")   # сбор локальных логов
   module(load="imklog")    # сбор логов ядра
   module(load="ommysql")   # вывод в MySQL
   ```
2. **Правила фильтрации и действий**  
   Формат:
   ```bash
   facility.priority    действие
   ```
   - **facility** (источник):  
     `auth`, `authpriv`, `kern`, `mail`, `cron`, `daemon`, `syslog`, `local0`–`local7` и др.  
   - **priority** (уровень важности):  
     `debug`, `info`, `notice`, `warning`, `err`, `crit`, `alert`, `emerg`.  

   Примеры:
   ```bash
   # Все сообщения ядра (kern) уровня error и выше — в /var/log/kern.log
   kern.err      /var/log/kern.log

   # Логи аутентификации (authpriv) — в отдельный файл
   authpriv.*    /var/log/auth.log

   # Критические ошибки — отправить на удалённый сервер (@ означает UDP, @@ — TCP)
   *.crit       @192.168.1.100:514
   ```

3. **Шаблоны (форматирование логов)**  
   Можно задать свой формат сообщений:
   ```bash
   $template MyFormat, "%timestamp% %hostname% %syslogtag% %msg%\n"
   *.* /var/log/all.log;MyFormat
   ```

---

## **3. Примеры настройки**
### **Локальное логирование**
```bash
# Логи ядра (kern) уровня warning и выше — в /var/log/kernel.log
kern.warning    /var/log/kernel.log

# Логи почты (mail) — в /var/log/mail.log
mail.*          /var/log/mail.log

# Все сообщения, кроме cron и auth, — в /var/log/syslog
*.*;cron,authpriv.none    /var/log/syslog
```

### **Отправка логов на удалённый сервер**
```bash
# Отправка всех логов на сервер 192.168.1.100 через UDP (@) или TCP (@@)
*.* @192.168.1.100:514
```

### **Сохранение логов в MySQL**
1. Установка модуля:
   ```bash
   sudo apt install rsyslog-mysql  # Debian/Ubuntu
   sudo yum install rsyslog-mysql  # RHEL/CentOS
   ```
2. Настройка Rsyslog:
   ```bash
   module(load="ommysql")
   action(type="ommysql" server="localhost" db="Syslog" uid="rsyslog" pwd="password")
   ```

---

## **4. Включение и управление Rsyslog**
```bash
# Перезапуск Rsyslog после изменения конфига
sudo systemctl restart rsyslog

# Проверка статуса
sudo systemctl status rsyslog

# Просмотр логов Rsyslog (его собственные ошибки)
tail -f /var/log/syslog | grep rsyslog
```

---

## **5. Интеграция с journald**
Если система использует **systemd**, Rsyslog может брать логи из journald:
```bash
module(load="imjournal")  # импорт логов из journald
```

Но чаще journald сам пересылает логи в Rsyslog (если в `/etc/systemd/journald.conf` стоит `ForwardToSyslog=yes`).

---

## **6. Ротация логов (logrotate)**
Rsyslog не управляет ротацией логов — это делает **logrotate**.  
Пример конфига `/etc/logrotate.d/rsyslog`:
```bash
/var/log/syslog {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    postrotate
        /usr/lib/rsyslog/rsyslog-rotate
    endscript
}
```

---

## **7. Проблемы и диагностика**
- **Логи не записываются**  
  Проверьте:  
  ```bash
  sudo rsyslogd -N1  # тест конфига на ошибки
  sudo systemctl status rsyslog
  ```
- **Нет прав на запись**  
  Убедитесь, что папка `/var/log/` доступна для записи.  
- **Ошибки подключения к удалённому серверу**  
  Проверьте фаервол (`ufw`, `iptables`) и настройки портов.

---

## **Вывод**
- **Rsyslog** — стандартная и гибкая система логирования в Linux.  
- Поддерживает фильтрацию, пересылку, шифрование и интеграцию с БД.  
- Конфигурация строится на правилах `facility.priority → действие`.  
- Для ротации логов используется **logrotate**.  
- Альтернативы: **syslog-ng**, **Fluentd**, **journald** (в systemd).  

Если нужна централизованная система сбора логов, Rsyslog — отличный выбор!