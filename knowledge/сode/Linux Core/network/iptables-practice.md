## 🔹 **Основы iptables**
### **1. Таблицы и цепочки (Tables & Chains)**
В `iptables` есть несколько **таблиц**, каждая из которых отвечает за разные задачи:
- **`filter`** (по умолчанию) — фильтрация пакетов (`INPUT`, `OUTPUT`, `FORWARD`).
- **`nat`** — трансляция адресов (`PREROUTING`, `POSTROUTING`, `OUTPUT`).
- **`mangle`** — модификация пакетов (редко используется).
- **`raw`** — отключение отслеживания соединений.

**Основные цепочки (chains):**
- **`INPUT`** — входящие пакеты (для этого сервера).
- **`OUTPUT`** — исходящие пакеты (с этого сервера).
- **`FORWARD`** — пакеты, которые проходят через сервер (если он работает как роутер).

---

## 🔹 **Основные команды iptables**
### **1. Просмотр текущих правил**
```bash
sudo iptables -L -v -n  # Показать правила filter (по умолчанию)
sudo iptables -t nat -L -v -n  # Показать правила NAT
```
- `-L` — список правил.
- `-v` — подробный вывод.
- `-n` — показывать IP вместо имен.

### **2. Сброс всех правил (осторожно!)**
```bash
sudo iptables -F  # Очистить все правила
sudo iptables -X  # Удалить пользовательские цепочки
sudo iptables -Z  # Обнулить счётчики пакетов
```

### **3. Блокировка и разрешение трафика**
#### **Заблокировать IP-адрес**
```bash
sudo iptables -A INPUT -s 192.168.1.100 -j DROP
```
- `-A INPUT` — добавить правило в цепочку `INPUT`.
- `-s 192.168.1.100` — источник (можно использовать `-d` для адреса назначения).
- `-j DROP` — действие (`DROP` — отбросить, `REJECT` — отклонить с ответом, `ACCEPT` — разрешить).

#### **Разрешить SSH (22 порт)**
```bash
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
```
- `-p tcp` — протокол (`tcp`, `udp`, `icmp`).
- `--dport 22` — порт назначения.

#### **Разрешить только определённые IP доступ к порту**
```bash
sudo iptables -A INPUT -p tcp --dport 80 -s 192.168.1.50 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80 -j DROP  # Блокировать всех остальных
```
### **Как удалить цепочку (chain) в iptables**  

В **iptables** можно удалить как пользовательскую цепочку, так и очистить правила в стандартной (встроенной) цепочке.  

---

## **Удаление пользовательской цепочки**  
Пользовательские цепочки создаются вручную (например, `-N MY_CHAIN`).  

### **Шаги:**  
1. **Проверить существующие цепочки:**  
   ```bash
   sudo iptables -L -n --line-numbers
   ```
   (Или `sudo iptables -t nat -L -n` для таблицы `nat`).  

2. **Удалить все правила из цепочки (если они есть):**  
   ```bash
   sudo iptables -F MY_CHAIN  # Очищает цепочку MY_CHAIN
   ```

3. **Удалить саму цепочку:**  
   ```bash
   sudo iptables -X MY_CHAIN  # Удаляет пустую пользовательскую цепочку
   ```
   - `-X` — удаляет **только пустые** пользовательские цепочки.  
   - Если в цепочке есть правила, сначала нужно выполнить `-F`.  

---

## **Удаление всех правил из стандартной цепочки**  
Стандартные цепочки (`INPUT`, `FORWARD`, `OUTPUT`, `PREROUTING`, `POSTROUTING` и др.) нельзя удалить, но можно **очистить** от правил.  

### **Очистка всех правил в цепочке:**  
```bash
sudo iptables -F INPUT      # Очищает цепочку INPUT
sudo iptables -t nat -F    # Очищает все правила в таблице nat
```

### **Удаление конкретного правила по номеру:**  
Если нужно удалить одно правило, а не всю цепочку:  
1. Показать правила с номерами:  
   ```bash
   sudo iptables -L INPUT --line-numbers
   ```
   Вывод:  
   ```
   Chain INPUT (policy ACCEPT)
   num  target     prot opt source               destination
   1    DROP       tcp  --  192.168.1.100        0.0.0.0/0
   2    ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0
   ```
2. Удалить правило №1:  
   ```bash
   sudo iptables -D INPUT 1
   ```

---

## **Полный сброс iptables (всех правил и цепочек)**  
Если нужно **полностью очистить** iptables (например, для начальной настройки):  
```bash
sudo iptables -F           # Очищает все правила в фильтре
sudo iptables -t nat -F    # Очищает NAT
sudo iptables -t mangle -F # Очищает mangle
sudo iptables -X           # Удаляет ВСЕ пользовательские цепочки
sudo iptables -Z           # Сбрасывает счётчики пакетов и байтов
```

> ⚠️ **Внимание!** Если не настроены правила по умолчанию (`-P`), после `-F` трафик может **блокироваться**. Перед сбросом лучше установить политику `ACCEPT`:  
> ```bash
> sudo iptables -P INPUT ACCEPT
> sudo iptables -P FORWARD ACCEPT
> sudo iptables -P OUTPUT ACCEPT
> ```

---

---

## 🔹 **Примеры использования**
### **1. Защита сервера (базовые правила)**
```bash
# Разрешить локальный трафик
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT

# Разрешить входящие SSH (22) и HTTP (80)
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Разрешить ответы на исходящие запросы
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Заблокировать все остальные входящие соединения
sudo iptables -A INPUT -j DROP
```

### **2. NAT и проброс портов**
#### **Включение форвардинга (если сервер — роутер)**
```bash
echo 1 > /proc/sys/net/ipv4/ip_forward  # Включить временно
```
Чтобы сохранить после перезагрузки, добавьте в `/etc/sysctl.conf`:
```bash
net.ipv4.ip_forward = 1
```

#### **Проброс порта 8080 на внутренний сервер 192.168.1.2:80**
```bash
sudo iptables -t nat -A PREROUTING -p tcp --dport 8080 -j DNAT --to-destination 192.168.1.2:80
sudo iptables -t nat -A POSTROUTING -j MASQUERADE  # Для маскарадинга (если сервер — шлюз)
```

---

## 🔹 **Сохранение правил**
Правила `iptables` сбрасываются после перезагрузки. Чтобы сохранить их:
### **Debian/Ubuntu**
```bash
sudo apt install iptables-persistent
sudo netfilter-persistent save
```
Или вручную:
```bash
sudo iptables-save > /etc/iptables/rules.v4
sudo ip6tables-save > /etc/iptables/rules.v6
```

### **CentOS/RHEL**
```bash
sudo service iptables save  # (или iptables-services)
```

---

## 🔹 **Дополнительные фишки**
- **Логирование блокируемых пакетов**  
  ```bash
  sudo iptables -A INPUT -j LOG --log-prefix "BLOCKED: "
  ```
- **Ограничение числа соединений (защита от DDoS)**  
  ```bash
  sudo iptables -A INPUT -p tcp --dport 80 -m connlimit --connlimit-above 50 -j DROP
  ```
- **Блокировка по стране (используя `ipset`)**  
  ```bash
  sudo apt install ipset
  sudo ipset create blocked_countries hash:net
  sudo iptables -A INPUT -m set --match-set blocked_countries src -j DROP
  ```

---

## ❗ **Важно!**
- **Не блокируйте SSH, если подключены удалённо** — потеряете доступ!
- **Проверяйте правила перед сохранением** (`iptables -L`).
- **Для IPv6** используйте `ip6tables`.

Теперь ты знаешь основы `iptables`! Попробуй настроить простой фаервол и проверь работу. 😊
