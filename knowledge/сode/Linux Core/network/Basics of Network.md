
# Сети (основы)

## ip a
Отображение ip-адресов.
Добавить адрес:
```bash
$ ip addr add 192.168.0.1/24 dev ens33 # сбросится после reboot
```
`ens33` - имя карты из `ip a`

### /etc/network/interfaces
Чтобы после перезагрузки сохранялись статические адреса:
```
iface ens33 inet static
adress 192.168.0.1
network 255.255.255.0
```
## hostname
```bash
$ hostname # выведет хост
$ hostname new # присвоит значение
```
Чтобы задать имя хоста постоянно:
```bash
$ echo "new-hostname" > /etc/hostname
$ hostnamectl set-hostname new-hostname
```

## Настройка DHCP

Автоматическая выдача IP-адресов.

### DHCP-клиент (на клиентской машине)

Присвоение IP-адреса автоматически:

```bash
$ dhclient ens33
```

Пример настройки в `/etc/network/interfaces`:

`auto ens33
iface ens33 inet dhcp` 

### DHCP-сервер (на сервере)

Установка DHCP-сервера (напр. isc-dhcp-server):

```bash
$ sudo apt install isc-dhcp-server
```
Файл конфигурации: `/etc/dhcp/dhcpd.conf`

Пример:

```bash
subnet 192.168.0.0 netmask 255.255.255.0 {
  range 192.168.0.100 192.168.0.200;
  option routers 192.168.0.1;
  option domain-name-servers 8.8.8.8;
}
```
Указать интерфейс в `/etc/default/isc-dhcp-server`:
`INTERFACESv4="ens33"` 

Перезапуск сервиса:

```bash
$ sudo systemctl restart isc-dhcp-server
$ sudo systemctl status isc-dhcp-server 
```
## Полезные команды

Просмотр маршрутов:

```bash
$ ip route
```

Просмотр пути пакета:
```bash
$ traceroute host
```

Проверка доступности узла:
```bash
$ ping 192.168.0.1
```
Проверка DNS:

```bash
$ nslookup ya.ru
```

Проверка порта:

```bash
$ nc -zv 192.168.0.1 22
```
