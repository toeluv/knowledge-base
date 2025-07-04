---
tags:
  - ansible
---
## Основные команды
- **Запуск модуля  `ping` на всех хостах файла `hosts`**:
```sh
ansible all -i hosts -m ping
```
- **Создать роль:**
```sh
ansible-galaxy init rolename
```

- **Выполнить плейбук `playbook.yaml` на всех хостах файла `hosts`**: 

```sh
ansible-playbook -i hosts playbook.yaml
```