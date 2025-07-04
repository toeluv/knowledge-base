### **nftables**  

**nftables** — это современная система фильтрации сетевых пакетов в Linux, пришедшая на смену **iptables**. Она предоставляет более простой синтаксис, лучшую производительность и объединяет функциональность `iptables`, `ip6tables`, `arptables` и `ebtables` в единый фреймворк.  

---

## **1. Основные концепции**  
### **Таблицы (Tables)**  
- Содержат **цепочки (chains)** и **правила (rules)**.  
- Разделяются по семействам (families):  
  - `ip` (IPv4)  
  - `ip6` (IPv6)  
  - `inet` (IPv4 + IPv6)  
  - `arp` (ARP-трафик)  
  - `bridge` (мостовой трафик)  
  - `netdev` (фильтрация на уровне сетевого интерфейса)  

### **Цепочки (Chains)**  
- Аналогичны цепочкам в iptables (`INPUT`, `OUTPUT`, `FORWARD`).  
- Типы:  
  - **filter** (фильтрация пакетов)  
  - **route** (изменение маршрутизации)  
  - **nat** (трансляция адресов)  

### **Правила (Rules)**  
- Определяют действия (`accept`, `drop`, `reject`, `log` и др.).  
- Могут включать условия (`if tcp dport 22 then accept`).  

---

## **2. Установка и запуск**  
### **Установка**  
```bash
sudo apt install nftables  # Debian/Ubuntu
sudo yum install nftables  # RHEL/CentOS
sudo pacman -S nftables    # Arch Linux
```

### **Запуск и автозагрузка**  
```bash
sudo systemctl enable --now nftables
```

### **Проверка статуса**  
```bash
sudo nft list ruleset
```
### ** Перевод из iptables**
```bash
sudo iptables-translate -A INPUT -t filter -p tcp --dport 22 -j ACCEPT
```
---

## **3. Базовые команды**  
| Команда | Описание |
|---------|----------|
| `nft list tables` | Показать все таблицы |
| `nft list table <семейство> <таблица>` | Показать правила таблицы |
| `nft add table <семейство> <таблица>` | Создать таблицу |
| `nft delete table <семейство> <таблица>` | Удалить таблицу |
| `nft add chain <семейство> <таблица> <цепочка>` | Создать цепочку |
| `nft add rule <семейство> <таблица> <цепочка> <правило>` | Добавить правило |
| `nft flush ruleset` | Очистить все правила |

---

## **4. Примеры правил**  
### **Базовый firewall (разрешить SSH, HTTP, HTTPS, запретить остальное)**  
```bash
# Создаем таблицу
nft add table inet filter

# Добавляем цепочки
nft add chain inet filter input { type filter hook input priority 0 \; }
nft add chain inet filter forward { type filter hook forward priority 0 \; }
nft add chain inet filter output { type filter hook output priority 0 \; }

# Разрешаем локальный трафик
nft add rule inet filter input iif "lo" accept
nft add rule inet filter output oif "lo" accept

# Разрешаем SSH (22), HTTP (80), HTTPS (443)
nft add rule inet filter input tcp dport { 22, 80, 443 } accept
nft add rule inet filter input ct state established,related accept

# Запрещаем всё остальное
nft add rule inet filter input drop
```

### **NAT (маскарадинг для выхода в интернет)**  
```bash
nft add table nat
nft add chain nat postrouting { type nat hook postrouting priority 100 \; }
nft add rule nat postrouting oifname "eth0" masquerade
```

### **Логирование пакетов**  
```bash
nft add rule inet filter input tcp dport 22 log prefix "SSH attempt: " accept
```

---

## **5. Сохранение и восстановление правил**  
### **Сохранение в файл**  
```bash
sudo nft list ruleset > /etc/nftables.conf
```

### **Восстановление из файла**  
```bash
sudo nft -f /etc/nftables.conf
```

### **Автозагрузка (systemd)**  
```bash
sudo systemctl enable nftables
```

---

## **6. Отличия от iptables**  
| **nftables** | **iptables** |
|-------------|-------------|
| Единый синтаксис для IPv4/IPv6 | Разные команды (`iptables`, `ip6tables`) |
| Поддержка JSON | Нет JSON |
| Более высокая производительность | Медленнее при большом количестве правил |
| Упрощённое управление множеством правил | Сложнее масштабировать |

---

## **7. Полезные ссылки**  
- Официальная документация: [https://wiki.nftables.org](https://wiki.nftables.org)  
- `man nft` – справочник по синтаксису  

---

### **Вывод**  
**nftables** — мощный и гибкий инструмент для управления сетевым трафиком в Linux. Он проще iptables, поддерживает современные функции и рекомендуется для использования в новых системах. 🚀
