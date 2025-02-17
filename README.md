# Название выполняемого задания;
Systemd

# Текст задания
Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/default).
Установить spawn-fcgi и создать unit-файл (spawn-fcgi.sevice) с помощью переделки init-скрипта (https://gist.github.com/cea2k/1318020).
Доработать unit-файл Nginx (nginx.service) для запуска нескольких инстансов сервера с разными конфигурационными файлами одновременно

# Запуск
```bash
vagrant up
```

# Проверка

## 1
```bash
sergey@fedora:~/Otus/homework/10/vagrant$ ssh vagrant@127.0.0.1 -p 2222 "sh -c 'tail -n 1000 /var/log/syslog  | grep word'"
vagrant@127.0.0.1's password: 
2025-02-17T18:24:24.295571+00:00 vagrant kernel: systemd[1]: Started systemd-ask-password-wall.path - Forward Password Requests to Wall Directory Watch.
2025-02-17T18:24:24.295660+00:00 vagrant kernel: audit: type=1400 audit(1739816663.472:3): apparmor="STATUS" operation="profile_load" profile="unconfined" name="1password" pid=500 comm="apparmor_parser"
2025-02-17T18:24:24.304567+00:00 vagrant systemd[1]: Started systemd-ask-password-console.path - Dispatch Password Requests to Console Directory Watch.
2025-02-17T18:24:24.304574+00:00 vagrant systemd[1]: systemd-ask-password-plymouth.path - Forward Password Requests to Plymouth Directory Watch was skipped because of an unmet condition check (ConditionPathExists=/run/plymouth/pid).
2025-02-17T18:34:04.403867+00:00 vagrant root: Mon Feb 17 06:34:04 PM UTC 2025: I found word, Master!
2025-02-17T18:34:43.325722+00:00 vagrant root: Mon Feb 17 06:34:43 PM UTC 2025: I found word, Master!
2025-02-17T18:35:45.458124+00:00 vagrant root: Mon Feb 17 06:35:45 PM UTC 2025: I found word, Master!
2025-02-17T18:36:20.289611+00:00 vagrant root: Mon Feb 17 06:36:20 PM UTC 2025: I found word, Master!
```
## 2
```bash
sergey@fedora:~/Otus/homework/10/vagrant$ ssh vagrant@127.0.0.1 -p 2222 "sh -c 'sudo systemctl status spawn-fcgi'"
vagrant@127.0.0.1's password: 
● spawn-fcgi.service - Spawn-fcgi startup service by Otus
     Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; preset: enabled)
     Active: active (running) since Mon 2025-02-17 18:24:56 UTC; 7min ago
   Main PID: 10694 (php-cgi)
      Tasks: 33 (limit: 1067)
     Memory: 14.4M (peak: 14.7M)
        CPU: 20ms
     CGroup: /system.slice/spawn-fcgi.service
             ├─10694 /usr/bin/php-cgi
             ├─10698 /usr/bin/php-cgi
             ├─10699 /usr/bin/php-cgi
             ├─10700 /usr/bin/php-cgi
             ├─10701 /usr/bin/php-cgi
             ├─10702 /usr/bin/php-cgi
             ├─10703 /usr/bin/php-cgi
             ├─10704 /usr/bin/php-cgi
             ├─10705 /usr/bin/php-cgi
             ├─10706 /usr/bin/php-cgi
             ├─10707 /usr/bin/php-cgi
             ├─10708 /usr/bin/php-cgi
             ├─10709 /usr/bin/php-cgi
             ├─10710 /usr/bin/php-cgi
             ├─10711 /usr/bin/php-cgi
             ├─10712 /usr/bin/php-cgi
             ├─10713 /usr/bin/php-cgi
             ├─10714 /usr/bin/php-cgi
             ├─10715 /usr/bin/php-cgi
             ├─10716 /usr/bin/php-cgi
             ├─10717 /usr/bin/php-cgi
             ├─10718 /usr/bin/php-cgi
             ├─10719 /usr/bin/php-cgi
             ├─10720 /usr/bin/php-cgi
             ├─10721 /usr/bin/php-cgi
             ├─10722 /usr/bin/php-cgi
             ├─10723 /usr/bin/php-cgi
             ├─10724 /usr/bin/php-cgi
             ├─10725 /usr/bin/php-cgi
             ├─10726 /usr/bin/php-cgi
             ├─10727 /usr/bin/php-cgi
             ├─10728 /usr/bin/php-cgi
             └─10729 /usr/bin/php-cgi

Feb 17 18:24:56 belousovSystemD systemd[1]: Started spawn-fcgi.service - Spawn-fcgi startup service by Otus.
Feb 17 18:24:58 belousovSystemD systemd[1]: /etc/systemd/system/spawn-fcgi.service:7: PIDFile= references a path below legacy directory /var/run/, updating /var/run/spawn-fcgi.pid → /run/spawn-fcgi.pid; please update the unit file accordingly.
Feb 17 18:24:58 belousovSystemD systemd[1]: /etc/systemd/system/spawn-fcgi.service:7: PIDFile= references a path below legacy directory /var/run/, updating /var/run/spawn-fcgi.pid → /run/spawn-fcgi.pid; please update the unit file accordingly.
```

## 3
```bash
sergey@fedora:~/Otus/homework/10/vagrant$ ssh vagrant@127.0.0.1 -p 2222 "sh -c 'sudo ss -tnulp | grep ngin'"
vagrant@127.0.0.1's password: 
tcp   LISTEN 0      511           0.0.0.0:9001      0.0.0.0:*    users:(("nginx",pid=10977,fd=5),("nginx",pid=10976,fd=5),("nginx",pid=10975,fd=5))
tcp   LISTEN 0      511           0.0.0.0:9002      0.0.0.0:*    users:(("nginx",pid=10987,fd=5),("nginx",pid=10986,fd=5),("nginx",pid=10985,fd=5))
```
