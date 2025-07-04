### **Конспект 1: Настройка DHCP в dnsmasq**  
**Цель**: Настроить `dnsmasq` как DHCP-сервер для автоматической раздачи IP-адресов, шлюза и DNS.  

#### **1. Установка dnsmasq**  
```bash
sudo apt update && sudo apt install dnsmasq  # Debian/Ubuntu
sudo yum install dnsmasq                    # CentOS/RHEL
```

#### **2. Конфигурация DHCP**  
Редактируем `/etc/dnsmasq.conf`:  
```ini
# Слушаем интерфейс (например, eth0)
interface=eth0
bind-interfaces

# Диапазон IP для раздачи
dhcp-range=192.168.1.100,192.168.1.200,24h

# Основной шлюз (роутер)
dhcp-option=option:router,192.168.1.1

# DNS-сервер (может быть этот же сервер или внешний)
dhcp-option=option:dns-server,192.168.1.1,8.8.8.8

# Доп. опции (пример):
dhcp-option=option:ntp-server,192.168.1.1   # NTP-сервер
dhcp-option=option:domain-name,home.lan     # Домен сети

# Фиксированные IP для устройств по MAC
dhcp-host=AA:BB:CC:DD:EE:FF,192.168.1.50
```

#### **3. Перезапуск и проверка**  
```bash
sudo systemctl restart dnsmasq
```
**Проверка**:  
- На клиенте выполните:  
  ```bash
  ip a show eth0  # Linux
  ipconfig /all   # Windows
  ```  
  Должны отобразиться:  
  - IP из диапазона `192.168.1.100-200`,  
  - Шлюз `192.168.1.1`,  
  - DNS `192.168.1.1`.  

---

### **Конспект 2: Настройка DNS в dnsmasq**  
**Цель**: Настроить `dnsmasq` как DNS-сервер с локальными именами и кэшированием.  

#### **1. Отключение DHCP (если не нужно)**  
В `/etc/dnsmasq.conf`:  
```ini
no-dhcp-interface=
```

#### **2. Конфигурация DNS**  
```ini
# Слушаем DNS на нужном IP
listen-address=127.0.0.1,192.168.1.1

# Локальные DNS-записи
addn-hosts=/etc/dnsmasq.hosts

# Кэширование DNS
cache-size=1000

# Блокировка рекламы (пример)
address=/ads.example.com/0.0.0.0

# Перенаправление всех запросов .local на локальный IP
address=/.local/192.168.1.1
```

#### **3. Добавление локальных имен**  
Создаем файл `/etc/dnsmasq.hosts`:  
```text
192.168.1.10   server.local
192.168.1.20   printer.local
```

#### **4. Перезапуск и проверка**  
```bash
sudo systemctl restart dnsmasq
```
**Проверка**:  
```bash
dig server.local @192.168.1.1  # Должен вернуть 192.168.1.10
nslookup google.com 192.168.1.1  # Должен разрешить внешний DNS
```

---

### **Ключевые отличия**  
| **Настройка** | **DHCP**                          | **DNS**                          |  
|--------------|-----------------------------------|----------------------------------|  
| **Основная роль** | Раздает IP-адреса, шлюз, DNS. | Разрешает доменные имена.        |  
| **Клиентские данные** | IP, шлюз, DNS, NTP, домен.  | Только DNS-записи.               |  
| **Конфиг-опции** | `dhcp-range`, `dhcp-option`. | `addn-hosts`, `cache-size`.      |  
| **Проверка** | `ipconfig /all` (Windows).    | `dig @server имя` (Linux).       |  

**Важно**: Если DHCP и DNS работают на одном сервере, клиенты автоматически получат его IP как DNS-сервер через `dhcp-option=option:dns-server`.
