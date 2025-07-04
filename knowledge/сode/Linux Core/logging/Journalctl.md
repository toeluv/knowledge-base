## **journalctl и настройка journald в Linux**

`journald` — это компонент `systemd`, который занимается сбором и управлением системными логами в бинарном формате. Вместо традиционных текстовых логов (как в `syslog`), он хранит данные в структурированном виде, что позволяет удобно фильтровать и анализировать логи.

---

## **1. Основные команды journalctl**
`journalctl` — утилита для просмотра логов из `journald`.

### **Базовые команды**
| Команда | Описание |
|---------|----------|
| `journalctl` | Показать все логи (с самого начала) |
| `journalctl -b` | Логи текущей загрузки |
| `journalctl -b -1` | Логи предыдущей загрузки |
| `journalctl -f` | Режим "слежения" (как `tail -f`) |
| `journalctl -u nginx.service` | Логи только для сервиса `nginx` |
| `journalctl -k` | Логи ядра (аналог `dmesg`) |
| `journalctl -p err` | Только ошибки (`emerg`, `alert`, `crit`, `err`, `warning`, `notice`, `info`, `debug`) |
| `journalctl --since "2024-05-10" --until "2024-05-11"` | Логи за определённый период |
| `journalctl -o json-pretty` | Вывод в формате JSON (удобно для скриптов) |

### **Примеры**
```bash
# Просмотр логов Apache за последний час
journalctl -u apache2 --since "1 hour ago"

# Поиск ошибок в логах
journalctl -p err -b

# Логи определённого пользователя
journalctl _UID=1000

# Логи определённого процесса
journalctl _PID=1234
```

---

## **2. Конфигурация journald**
Настройки `journald` хранятся в `/etc/systemd/journald.conf`.  

### **Основные параметры**
```ini
[Journal]
Storage=persistent          # auto (по умолчанию), volatile (в RAM), persistent (на диск)
Compress=yes               # сжатие логов
SystemMaxUse=1G            # максимальный размер логов (1 ГБ)
RuntimeMaxUse=100M         # макс. размер в /run (для volatile)
MaxRetentionSec=1month     # как долго хранить логи
ForwardToSyslog=no         # не дублировать в syslog (если нужен только journald)
```

### **Применение изменений**
```bash
sudo systemctl restart systemd-journald
```

---

## **3. Где хранятся логи journald?**
- По умолчанию (`Storage=auto` или `persistent`):  
  `/var/log/journal/` (если каталог существует, логи пишутся на диск).  
- При `Storage=volatile`:  
  Логи хранятся в `/run/log/journal/` и пропадают после перезагрузки.

### **Как включить постоянное хранение логов**
```bash
sudo mkdir -p /var/log/journal
sudo systemctl restart systemd-journald
```

---

## **4. Ротация и очистка логов**
`journald` автоматически управляет размером логов, но можно вручную почистить старые записи.

### **Очистка логов**
```bash
# Очистить логи старше 2 дней
journalctl --vacuum-time=2d

# Оставить только 100 МБ логов
journalctl --vacuum-size=100M

# Удалить все логи до текущей загрузки
journalctl --vacuum-files=1
```

### **Автоматическая очистка**
Можно настроить через `journald.conf`:
```ini
SystemMaxUse=500M      # Макс. размер логов
SystemMaxFileSize=50M  # Макс. размер одного файла
MaxRetentionSec=1week  # Хранить логи не больше недели
```

---

## **5. Перенаправление логов в syslog**
Если нужно дублировать логи в классический `syslog`:
```ini
[Journal]
ForwardToSyslog=yes
```
(но это может приводить к дублированию записей, если `rsyslog` тоже настроен).

---

## **6. Просмотр логов в реальном времени**
```bash
journalctl -f            # все логи
journalctl -f -u nginx   # только логи nginx
```

---

## **7. Экспорт логов**
Можно сохранить логи в текстовый или JSON-формат:
```bash
journalctl -u mysql --since "yesterday" > mysql.log
journalctl -o json > logs.json
```

---

## **Вывод**
- `journald` — современная система логирования, интегрированная в `systemd`.
- Логи хранятся в бинарном виде, но удобно фильтруются через `journalctl`.
- Можно гибко настраивать размер, сжатие и срок хранения логов.
- Подходит для серверов и десктопов, но иногда требует дополнительной настройки (например, для интеграции с внешними системами мониторинга).