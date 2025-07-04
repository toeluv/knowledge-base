**Network Interfaces и NetworkManager в Linux**  

#### **1. Сетевые интерфейсы (Network Interfaces)**  
Сетевые интерфейсы — это точки подключения системы к сети (физические или виртуальные).  

**Типы интерфейсов:**  
- **Физические (`eth0`, `enp3s0`, `wlan0`)** – реальные сетевые карты (Ethernet, Wi-Fi).  
- **Виртуальные (`lo`, `tun0`, `virbr0`)** – программные интерфейсы (loopback, VPN, мосты).  

**Просмотр интерфейсов:**  
```bash
ip link show       # список всех интерфейсов
ifconfig -a        # устаревший аналог (пакет net-tools)
ls /sys/class/net  # список интерфейсов через sysfs
```  

---  

#### **2. Настройка сети вручную (без NetworkManager)**  
**Используется `ip` (из пакета `iproute2`) и конфиги в `/etc/network/`.**  

**Основные команды `ip`:**  
```bash
ip addr show                   # показать IP-адреса  
ip addr add 192.168.1.10/24 dev eth0  # добавить IP  
ip addr del 192.168.1.10/24 dev eth0  # удалить IP  
ip route show                  # показать маршруты  
ip route add default via 192.168.1.1  # добавить шлюз  
ip link set eth0 up            # включить интерфейс  
ip link set eth0 down          # выключить интерфейс  
```  

**Статическая настройка через конфиги (Debian/Ubuntu):**  
Файл `/etc/network/interfaces`:  
```ini
auto eth0  
iface eth0 inet static  
    address 192.168.1.10  
    netmask 255.255.255.0  
    gateway 192.168.1.1  
    dns-nameservers 8.8.8.8  
```  
Применить:  
```bash
systemctl restart networking  # или ifdown eth0 && ifup eth0  
```  

---  

#### **3. NetworkManager (управление сетями)**  
**NetworkManager** – стандартный демон для управления сетями в современных дистрибутивах (GUI + CLI).  

**Утилиты:**  
- **`nmtui`** – TUI-интерфейс для настройки.  
- **`nmcli`** – консольная утилита.  

**Основные команды `nmcli`:**  
```bash
nmcli device status          # список интерфейсов  
nmcli connection show        # список подключений  
nmcli connection up "Wired"  # активировать профиль  
nmcli connection down "Wired" # отключить профиль  
```  

**Добавление статического IP:**  
```bash
nmcli con add con-name "static-eth0" ifname eth0 type ethernet \  
    ip4 192.168.1.10/24 gw4 192.168.1.1  
nmcli con mod "static-eth0" ipv4.dns "8.8.8.8"  
nmcli con up "static-eth0"  
```  

**Wi-Fi управление:**  
```bash
nmcli dev wifi list          # список сетей  
nmcli dev wifi connect "SSID" password "PASS"  # подключиться  
```  

---  

#### **4. Полезные команды для диагностики**  
```bash
ping 8.8.8.8                 # проверка соединения  
dig google.com               # проверка DNS  
ss -tulnp                    # список открытых портов  
journalctl -u NetworkManager # логи NetworkManager  
```  

---  

### **Вывод**  
- **`ip` + конфиги** – ручная настройка (серверы, минимальные системы).  
- **`nmcli`/`nmtui`** – удобное управление в десктопах и современных дистрибутивах.  
- **NetworkManager** упрощает работу с динамическими сетями (Wi-Fi, DHCP).  

📌 **Важно:** В некоторых серверных дистрибутивах (например, Ubuntu Server) NetworkManager может отсутствовать – там используется `netplan` или `/etc/network/interfaces`.
