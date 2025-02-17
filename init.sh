apt update

## 1. Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/default).

echo -e 'WORD="ALERT"\nLOG=/var/log/watchlog.log' > /etc/default/watchlog

cat > /opt/watchlog.sh <<EOF
#!/bin/bash

WORD=\$1
LOG=\$2
DATE=\`date\`

if grep \$WORD \$LOG &> /dev/null
then
logger "\$DATE: I found word, Master!"
else
exit 0
fi
EOF

chmod +x /opt/watchlog.sh

cat > /etc/systemd/system/watchlog.service <<EOF
[Unit]
Description=My watchlog service

[Service]
Type=oneshot
EnvironmentFile=/etc/default/watchlog
ExecStart=/opt/watchlog.sh \$WORD \$LOG
EOF

cat > /etc/systemd/system/watchlog.timer <<EOF
[Unit]
Description=Run watchlog script every 30 second

[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=watchlog.service

[Install]
WantedBy=multi-user.target
EOF

systemctl start watchlog.timer
systemctl start watchlog.service

echo 'ALERT !!!!' > /var/log/watchlog.log

## 2. Установить spawn-fcgi и создать unit-файл (spawn-fcgi.sevice) с помощью переделки init-скрипта (https://gist.github.com/cea2k/1318020).

apt install spawn-fcgi php php-cgi php-cli apache2 libapache2-mod-fcgid -y

mkdir /etc/spawn-fcgi
cat > /etc/spawn-fcgi/fcgi.conf <<EOF
SOCKET=/var/run/php-fcgi.sock
OPTIONS="-u www-data -g www-data -s \$SOCKET -S -M 0600 -C 32 -F 1 -- /usr/bin/php-cgi"
EOF

cat >/etc/systemd/system/spawn-fcgi.service <<EOF
[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target

[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/spawn-fcgi/fcgi.conf
ExecStart=/usr/bin/spawn-fcgi -n \$OPTIONS
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

systemctl start spawn-fcgi

## 3. Доработать unit-файл Nginx (nginx.service) для запуска нескольких инстансов сервера с разными конфигурационными файлами одновременно

apt install nginx -y

cat > /etc/systemd/system/nginx@.service <<EOF
[Unit]
Description=A high performance web server and a reverse proxy server
Documentation=man:nginx(8)
After=network.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx-%I.pid
ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx-%I.conf -q -g 'daemon on; master_process on;'
ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx-%I.conf -g 'daemon on; master_process on;'
ExecReload=/usr/sbin/nginx -c /etc/nginx/nginx-%I.conf -g 'daemon on; master_process on;' -s reload
ExecStop=-/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /run/nginx-%I.pid
TimeoutStopSec=5
KillMode=mixed

[Install]
WantedBy=multi-user.target
EOF

cp /etc/nginx/nginx.conf /etc/nginx/nginx-first.conf
sed -i 's/nginx.pid/nginx-first.pid/' /etc/nginx/nginx-first.conf
sed -i 's/include \/etc\/nginx\/conf/#include \/etc\/nginx\/conf/' /etc/nginx/nginx-first.conf
sed -i 's/include \/etc\/nginx\/sites-enabled/#include \/etc\/nginx\/sites-enabled/' /etc/nginx/nginx-first.conf
sed -i 's/http {/http{ server { listen 9001; }/' /etc/nginx/nginx-first.conf

cp /etc/nginx/nginx.conf /etc/nginx/nginx-second.conf
sed -i 's/nginx.pid/nginx-second.pid/' /etc/nginx/nginx-second.conf
sed -i 's/include \/etc\/nginx\/conf/#include \/etc\/nginx\/conf/' /etc/nginx/nginx-second.conf
sed -i 's/include \/etc\/nginx\/sites-enabled/#include \/etc\/nginx\/sites-enabled/' /etc/nginx/nginx-second.conf
sed -i 's/http {/http{ server { listen 9002; }/' /etc/nginx/nginx-second.conf

systemctl start nginx@first
systemctl start nginx@second