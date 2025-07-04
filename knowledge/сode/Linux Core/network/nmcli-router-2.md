Настройка маршрутизатора и клиента с помощью `nmcli` включает в себя несколько шагов, как описано ранее, но с четкой разницей в конфигурации каждого устройства. Вот общий план и конкретные команды:

**I. Маршрутизатор (Виртуальная машина):**

Предположения:

*   `eth0` - Подключен к внешней сети (интернету). Получает IP-адрес динамически или имеет статический IP-адрес.
*   `eth1` - Подключен к внутренней сети. Будет иметь статический IP-адрес (например, `192.168.1.1/24`).
*   Доступ в интернет для устройств внутренней сети.

Шаги:

1.  **Настройте eth1 (внутренняя сеть):**
    ```bash
    sudo nmcli connection add type ethernet con-name "Internal Network" ifname eth1 ip4 192.168.1.1/24 ipv4.method manual
    sudo nmcli connection modify "Internal Network" connection.autoconnect yes
    sudo nmcli connection down "Internal Network" && sudo nmcli connection up "Internal Network"
    ```

2. **Проверьте IP адрес:**

```bash
ip addr show eth1
```

3.  **Включите IP Forwarding:**
    ```bash
    sudo sysctl -w net.ipv4.ip_forward=1
    sudo nano /etc/sysctl.conf
    ```
    Раскомментируйте или добавьте `net.ipv4.ip_forward=1`, сохраните и выполните `sudo sysctl -p`.

4.  **Настройте NAT:**
    ```bash
    sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    sudo iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
    sudo iptables -A FORWARD -i eth0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT
    ```
    **Замените `eth0`** на имя интерфейса, подключенного к внешней сети (интернету), если он отличается.

5.  **Сохраните правила iptables:**
    ```bash
    sudo apt install iptables-persistent # Или dnf install для Fedora/CentOS
    sudo netfilter-persistent save
    ```

**II. Клиент (Внутренняя сеть):**

Предположения:

*   Подключен к внутренней сети, созданной маршрутизатором.
*   Должен получать IP-адрес от DHCP или иметь статический IP-адрес.
*   Должен иметь доступ в интернет через маршрутизатор.

**Вариант A: Статический IP-адрес**

Шаги:

1.  **Настройте статический IP-адрес:**
    ```bash
    sudo nmcli connection add type ethernet con-name "Client Network" ifname <имя_интерфейса> ip4 192.168.1.100/24 gw4 192.168.1.1 ipv4.dns 8.8.8.8 ipv4.method manual
    sudo nmcli connection modify "Client Network" connection.autoconnect yes
    sudo nmcli connection down "Client Network" && sudo nmcli connection up "Client Network"
    ```

    *   **`<имя_интерфейса>`:** Замените на имя сетевого интерфейса на клиентской машине (например, `eth0` или `enp0s3`).
    *   `ip4 192.168.1.100/24`: Укажите статический IP-адрес для клиента (в диапазоне `192.168.1.2 - 192.168.1.254`, но отличный от адреса маршрутизатора).
    *   `gw4 192.168.1.1`: Укажите `192.168.1.1` (IP-адрес eth1 на маршрутизаторе) в качестве шлюза по умолчанию.
    *   `ipv4.dns 8.8.8.8`:  Укажите DNS-сервер (например, Google DNS).

**Вариант B: DHCP (Требуется DHCP-сервер на маршрутизаторе):**

Если вы хотите использовать DHCP для автоматической выдачи IP-адресов клиентам, нужно установить и настроить DHCP-сервер на *маршрутизаторе*.

1.  **Настройте DHCP-сервер (на маршрутизаторе):**
    *   Установите DHCP-сервер (например, `dnsmasq`):
        ```bash
        sudo apt install dnsmasq
        ```
    *   Настройте `dnsmasq` для выдачи IP-адресов в диапазоне `192.168.1.2 - 192.168.1.254` (например, отредактировав `/etc/dnsmasq.conf`):

        ```
        interface=eth1
        dhcp-range=192.168.1.2,192.168.1.254,255.255.255.0,12h
        dhcp-option=option:router,192.168.1.1
        ```
    *  Перезапустите службу `dnsmasq`:
    ```bash
    sudo systemctl restart dnsmasq
    ```

2.  **Настройте клиент для получения IP-адреса автоматически (DHCP):**
    ```bash
    sudo nmcli connection add type ethernet con-name "Client Network DHCP" ifname <имя_интерфейса> ipv4.method auto
    sudo nmcli connection modify "Client Network DHCP" connection.autoconnect yes
    sudo nmcli connection down "Client Network DHCP" && sudo nmcli connection up "Client Network DHCP"
    ```
    *   **`<имя_интерфейса>`:** Замените на имя сетевого интерфейса на клиентской машине.
    *   `ipv4.method auto`: Указывает, что IP-адрес будет получен автоматически через DHCP.

**III. Проверка соединения:**

1.  **На маршрутизаторе:**

*  Проверьте eth0 подключение к интернету (`ping 8.8.8.8`).
*  Проверьте IP forwarding (`cat /proc/sys/net/ipv4/ip_forward`).
*   Проверьте правила `iptables` (`sudo iptables -t nat -L`, `sudo iptables -L FORWARD`).

2.  **На клиенте:**

*   Проверьте IP-адрес (`ip addr show <имя_интерфейса>`).  Если используется DHCP, проверьте, что получен IP-адрес из правильного диапазона.
*   Проверьте маршрут по умолчанию (`ip route`).  Шлюз по умолчанию должен указывать на IP-адрес eth1 маршрутизатора (192.168.1.1).
*   Проверьте доступ в интернет (`ping 8.8.8.8`).

**Важные замечания:**

*   **Имена интерфейсов:** Замените `eth0`, `eth1` и `<имя_интерфейса>` на фактические имена интерфейсов в вашей системе. Используйте `ip addr` или `ifconfig` для их обнаружения.
*   **Брандмауэр:** Убедитесь, что брандмауэр не блокирует трафик. Если это так, настройте `iptables` или `nftables`, чтобы разрешить необходимый трафик.
*   **Конфликты IP-адресов:** Избегайте конфликтов IP-адресов. Каждый клиент во внутренней сети должен иметь уникальный IP-адрес.
*   **DNS:** Укажите DNS-серверы на клиенте (или на маршрутизаторе, если используется DNS-прокси).
*   **Безопасность:**  Не забудьте о безопасности вашей сети. Настройте брандмауэр и используйте надежные пароли.
*   **Перезагрузка:** Перезагрузите устройства после внесения изменений.
*   **Вывод команд:** Всегда анализируйте вывод команд, чтобы убедиться, что все настроено правильно.

Следуя этим инструкциям, вы сможете настроить маршрутизатор и клиента с помощью `nmcli`, обеспечивая доступ в интернет для устройств во внутренней сети.
