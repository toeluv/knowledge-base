Если `nmcli connection show` не показывает `enp0s3`, это означает, что NetworkManager не управляет этим интерфейсом. Это может произойти по нескольким причинам:

**Причины и решения:**

1.  **Интерфейс управляется другим инструментом:**

    *   **Проблема:** Интерфейс может управляться непосредственно через файл `/etc/network/interfaces` (в Debian/Ubuntu и других подобных дистрибутивах) или другими утилитами, отличными от NetworkManager.  Когда интерфейс настроен таким образом, NetworkManager его игнорирует.
    *   **Решение:**
        *   **Проверьте файл `/etc/network/interfaces`:**  Откройте файл `/etc/network/interfaces` с помощью текстового редактора (например, `sudo nano /etc/network/interfaces`).
        *   **Найдите записи для `enp0s3`:**  Если вы видите строки, определяющие интерфейс `enp0s3`, например:

            ```
            auto enp0s3
            iface enp0s3 inet dhcp
            ```

            или

            ```
            auto enp0s3
            iface enp0s3 inet static
                address 192.168.1.100
                netmask 255.255.255.0
                gateway 192.168.1.1
            ```

            это означает, что интерфейс управляется через этот файл, а не через NetworkManager.

        *   **Удалите или закомментируйте записи:** Чтобы позволить NetworkManager управлять интерфейсом, удалите или закомментируйте все строки, относящиеся к `enp0s3`, в файле `/etc/network/interfaces`.  Файл должен выглядеть примерно так (только loopback):

            ```
            # This file describes the network interfaces available on your system
            # and how to activate them. For more information, see interfaces(5).

            source /etc/network/interfaces.d/*

            auto lo
            iface lo inet loopback
            ```
            **Важно:** Убедитесь, что вы не удалили записи для loopback-интерфейса (`lo`).

        *   **Перезагрузите NetworkManager:**  После внесения изменений перезагрузите службу NetworkManager:

            ```bash
            sudo systemctl restart NetworkManager
            ```

        *   **Проверьте снова:**  Теперь команда `nmcli connection show` должна показывать интерфейс `enp0s3` и связанное с ним соединение.  Если соединения нет, переходите к следующему шагу.

2.  **Интерфейс не настроен в NetworkManager:**

    *   **Проблема:**  После удаления настроек из `/etc/network/interfaces`, NetworkManager может все еще не иметь никакой информации о интерфейсе.
    *   **Решение:**  Нужно создать новое соединение в NetworkManager для интерфейса `enp0s3`.

        *   **Проверьте статус устройства:**  Убедитесь, что NetworkManager видит интерфейс:

            ```bash
            nmcli device status
            ```

            Интерфейс `enp0s3` должен быть в списке. Если он имеет статус `unmanaged` или `disconnected`, переходите к следующим командам.

        *   **Создайте новое соединение (DHCP):**  Если вы хотите использовать DHCP, выполните следующую команду:

            ```bash
            sudo nmcli connection add type ethernet ifname enp0s3 con-name "Wired connection enp0s3" autoconnect yes
            ```

        *   **Создайте новое соединение (статический IP-адрес):** Если вы хотите использовать статический IP-адрес, выполните следующие команды, заменив `<IP_ADDRESS>`, `<NETMASK>`, `<GATEWAY>` и `<DNS_SERVER>` на соответствующие значения:

            ```bash
            sudo nmcli connection add type ethernet ifname enp0s3 con-name "Static connection enp0s3" ip4 <IP_ADDRESS>/<NETMASK> gw4 <GATEWAY> ipv4.dns <DNS_SERVER> autoconnect yes
            ```
            Пример:
            ```bash
            sudo nmcli connection add type ethernet ifname enp0s3 con-name "Static connection enp0s3" ip4 192.168.1.100/24 gw4 192.168.1.1 ipv4.dns 8.8.8.8 autoconnect yes
            ```

        *   **Перезагрузите соединение:**
            ```bash
            sudo nmcli connection down "Wired connection enp0s3" && sudo nmcli connection up "Wired connection enp0s3"
            ```
            (Или используйте имя, которое вы указали при создании соединения).

        *   **Проверьте результат:**  Теперь команда `nmcli connection show` должна показывать новое соединение для `enp0s3`.  Проверьте также, что интерфейс получил IP-адрес (с помощью `ip addr` или `ifconfig`).

3.  **NetworkManager отключен или не работает:**

    *   **Проблема:** Служба NetworkManager может быть отключена или не запущена.
    *   **Решение:**
        *   **Проверьте статус NetworkManager:**

            ```bash
            sudo systemctl status NetworkManager
            ```

        *   **Если NetworkManager не работает, запустите его:**

            ```bash
            sudo systemctl start NetworkManager
            ```

        *   **Включите NetworkManager для автоматического запуска при загрузке системы:**

            ```bash
            sudo systemctl enable NetworkManager
            ```

4.  **udev Rules:**

    *   **Проблема:**  В редких случаях, udev rules могут мешать NetworkManager управлять интерфейсом.
    *   **Решение:**
        *   Проверьте наличие каких-либо кастомных udev rules, которые могут влиять на `enp0s3`. Они обычно находятся в директории `/etc/udev/rules.d/`.
        *   Если вы найдете такие правила, попробуйте их временно отключить (переименовав файл, добавив расширение `.disabled`) и перезагрузите систему, чтобы проверить, решит ли это проблему.

**Последовательность действий:**

1.  **Проверьте и измените `/etc/network/interfaces`:**  Это наиболее вероятная причина.  Удалите или закомментируйте записи для `enp0s3`.  Перезагрузите NetworkManager.
2.  **Создайте новое соединение NetworkManager:**  Используйте `nmcli connection add`, чтобы создать новое соединение для `enp0s3` (DHCP или статический IP-адрес).
3.  **Проверьте статус NetworkManager:** Убедитесь, что NetworkManager работает и включен для автоматического запуска.
4.  **Перезагрузите систему:**

После выполнения этих действий, `enp0s3` должен появиться в списке `nmcli connection show`, и NetworkManager должен автоматически подключаться к сети после перезагрузки.
