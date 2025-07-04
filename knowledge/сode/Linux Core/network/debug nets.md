### **Конспект: Настройка сети и диагностика в Linux**  
#### **Полезные команды для настройки и отладки (debug) сети**  

---

## **1. Просмотр информации о сети**  
### **Интерфейсы и IP-адреса**  
```bash
ip addr show           # все интерфейсы и их IP (аналог `ifconfig`)  
ip -br addr           # краткий вывод (только имя, состояние, IP)  
ip -c link show       # цветной вывод (подсветка)  
ip -s link            # статистика по пакетам/ошибкам  
```  

### **Маршрутизация (Routing)**  
```bash
ip route show         # таблица маршрутизации  
ip -br route          # краткий вывод маршрутов  
route -n              # устаревший аналог (если нет `ip`)  
```  

### **ARP-таблица (соответствие IP → MAC)**  
```bash
ip neigh show         # ARP-таблица (аналог `arp -a`)  
ip -s neigh           # + статистика  
```  

---

## **2. Проверка доступности сети**  
### **Ping (ICMP-запросы)**  
```bash
ping 8.8.8.8                 # проверка доступности IP  
ping -c 4 google.com         # отправить 4 пакета  
ping -I eth1 8.8.8.8         # пинг с указанного интерфейса  
```  

### **Traceroute (трассировка маршрута)**  
```bash
traceroute google.com        # классический traceroute  
tracepath google.com         # альтернатива (не требует root)  
mtr google.com               # комбо ping + traceroute (лучше!)  
```  

---

## **3. Проверка DNS**  
```bash
dig google.com               # детальная DNS-информация  
dig +short google.com        # только IP-адрес  
nslookup google.com          # альтернативный DNS-запрос  
host google.com              # простой DNS-запрос  
cat /etc/resolv.conf         # текущие DNS-серверы  
```  

---

## **4. Анализ открытых портов и подключений**  
```bash
ss -tulnp                    # все открытые порты (аналог `netstat`)  
ss -tulnp | grep 80          # поиск по порту  
lsof -i :80                  # какие процессы используют порт 80?  
nc -zv example.com 80        # проверка доступности порта  
telnet example.com 80        # ручное TCP-подключение (если нет `nc`)  
```  

---

## **5. Проброс трафика (tcpdump, wireshark)**  
### **Захват пакетов (tcpdump)**  
```bash
sudo tcpdump -i eth0                 # все пакеты на интерфейсе  
sudo tcpdump -i eth0 port 80         # только HTTP-трафик  
sudo tcpdump -i eth0 host 8.8.8.8    # только пакеты с/на 8.8.8.8  
sudo tcpdump -i eth0 -w dump.pcap    # запись в файл (можно открыть в Wireshark)  
```  

### **Анализ скорости и нагрузки (iftop, nload)**  
```bash
sudo iftop -i eth0           # мониторинг трафика в реальном времени  
sudo nload eth0              # график скорости (входящий/исходящий)  
```  

---

## **6. Проблемы с DHCP**  
```bash
sudo dhclient -v eth0        # принудительно запросить DHCP  
journalctl -u NetworkManager --no-pager | grep DHCP  # логи DHCP  
cat /var/lib/dhcp/dhclient.leases  # арендованные DHCP-адреса  
```  

---

## **7. Сброс сети и перезагрузка сервисов**  
```bash
sudo systemctl restart NetworkManager  # перезапуск NetworkManager  
sudo nmcli networking off && sudo nmcli networking on  # сброс сети  
sudo ip link set eth0 down && sudo ip link set eth0 up  # перезагрузка интерфейса  
```  

---

## **Вывод: что делать, если сеть не работает?**  
1. **Проверить, есть ли IP (`ip addr show`)** → если нет, попробовать `dhclient`.  
2. **Проверить маршруты (`ip route show`)** → если нет шлюза, добавить вручную.  
3. **Проверить DNS (`dig google.com`)** → если не работает, сменить DNS в `/etc/resolv.conf`.  
4. **Проверить доступность (`ping 8.8.8.8`)** → если не пингуется, проблема с маршрутом или фаерволом.  
5. **Проверить порты (`ss -tulnp`)** → если сервис не слушает порт, перезапустить его.  
6. **Анализировать трафик (`tcpdump`, `mtr`)** → если пакеты теряются, искать проблему на маршруте.  

🚀 **Главное:**  
- **`ip`** – замена старому `ifconfig`/`route`.  
- **`ss`** – замена `netstat`.  
- **`mtr`** – лучше, чем `traceroute`.  
- **`tcpdump`** – мощный сниффер (альтернатива – Wireshark).  
- **`journalctl`** – смотрим логи, если что-то сломалось.  

Эти команды помогут быстро найти и исправить проблемы с сетью в Linux! 🐧
