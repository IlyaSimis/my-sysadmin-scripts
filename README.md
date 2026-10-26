Скрипт раз в 10 секунд дописывает в monitor.log снимок free -h, df -h и uptime с меткой времени.

Образ из Dockerfile запускает этот скрипт и отдаёт monitor.log по HTTP на порту 8080. Nginx (nginx/my-app.conf) проксирует на этот порт и включает HTTPS. Служба systemd/my-app.service поднимает контейнер вместе с Docker.
