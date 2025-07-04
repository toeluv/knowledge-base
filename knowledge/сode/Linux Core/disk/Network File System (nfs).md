### **Настройка NFS (Network File System) в Linux**  

**NFS** — сетевой протокол для доступа к файлам по сети (работает по принципу клиент-сервер).  

---

## **1. Установка NFS**  
### **На сервере (экспорт папки):**  
```bash
# Debian/Ubuntu
sudo apt update && sudo apt install nfs-kernel-server

# RHEL/CentOS/Fedora
sudo yum install nfs-utils
```

### **На клиенте (подключение к NFS):**  
```bash
# Debian/Ubuntu
sudo apt install nfs-common

# RHEL/CentOS/Fedora
sudo yum install nfs-utils
```

---

## **2. Настройка сервера NFS**  
### **1. Создаем папку для экспорта**  
```bash
sudo mkdir -p /srv/nfs_share
sudo chown nobody:nogroup /srv/nfs_share  # или ваш пользователь
sudo chmod 777 /srv/nfs_share  # временно для теста
```

### **2. Настраиваем экспорт в `/etc/exports`**  
```bash
sudo nano /etc/exports
```
Добавляем строку (настройки доступа):  
```
/srv/nfs_share client_IP(rw,sync,no_subtree_check)  # для одного IP
/srv/nfs_share 192.168.1.0/24(rw,sync,no_subtree_check)  # для подсети
```
**Опции:**  
- `rw` — чтение и запись  
- `ro` — только чтение  
- `sync` — синхронная запись (надежнее)  
- `async` — асинхронная (быстрее, но риск потери данных)  
- `no_subtree_check` — ускоряет работу  
- `no_root_squash` — разрешает root-доступ (опасно!)  

### **3. Применяем изменения**  
```bash
sudo exportfs -a  # обновляет экспортируемые папки
sudo systemctl restart nfs-kernel-server  # перезапуск NFS
```

### **4. Проверяем экспортируемые папки**  
```bash
sudo exportfs -v  # список экспортов
showmount -e localhost  # проверка доступных шарингов
```

---

## **3. Настройка клиента NFS**  
### **1. Создаем точку монтирования**  
```bash
sudo mkdir -p /mnt/nfs_share
```

### **2. Монтируем NFS-шару**  
```bash
sudo mount -t nfs server_IP:/srv/nfs_share /mnt/nfs_share
```
**Проверяем:**  
```bash
df -h | grep nfs  # должен отобразиться подключенный NFS
ls /mnt/nfs_share  # проверка содержимого
```

### **3. Автомонтирование (через `/etc/fstab`)**  
```bash
sudo nano /etc/fstab
```
Добавляем строку:  
```
server_IP:/srv/nfs_share  /mnt/nfs_share  nfs  defaults  0  0
```
**Применяем:**  
```bash
sudo mount -a  # тестируем fstab без перезагрузки
```

---

## **4. Безопасность NFS**  
### **1. Ограничение доступа**  
- В `/etc/exports` указывать только доверенные IP/подсети.  
- Не использовать `no_root_squash` без необходимости.  

### **2. Firewall (если включен)**  
```bash
# Разрешаем NFS (для ufw)
sudo ufw allow from client_IP to any port nfs

# Или для iptables:
sudo iptables -A INPUT -p tcp --dport 2049 -s client_IP -j ACCEPT
```

### **3. SELinux (если используется)**  
```bash
sudo setsebool -P nfs_export_all_rw 1  # разрешает запись
```

---

## **5. Устранение неполадок**  
### **1. Ошибки монтирования**  
- **"Access denied"** → Проверить `/etc/exports` и права на папку.  
- **"Connection refused"** → Проверить, запущен ли NFS-сервер (`systemctl status nfs-server`).  

### **2. Проверка подключения**  
```bash
rpcinfo -p server_IP  # проверка работы RPC-сервисов
showmount -e server_IP  # список доступных экспортов
```

### **3. Логи сервера**  
```bash
sudo tail -f /var/log/syslog  # Debian/Ubuntu
sudo journalctl -u nfs-server  # RHEL/CentOS
```

---

## **Вывод**  
✅ **NFS сервер:**  
1. Установка `nfs-kernel-server`  
2. Настройка `/etc/exports`  
3. `exportfs -a` + перезапуск сервиса  

✅ **NFS клиент:**  
1. Установка `nfs-common`  
2. `mount -t nfs server:/share /mnt/nfs`  
3. Автомонтирование через `/etc/fstab`  

⚠ **Безопасность:**  
- Ограничивать IP в `/etc/exports`  
- Не использовать `no_root_squash` без необходимости  
- Настроить фаервол  

Теперь вы можете обмениваться файлами между Linux-системами через NFS! 🚀
