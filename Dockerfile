FROM alpine:latest

# Устанавливаем нужные пакеты
RUN apk --no-cache add --update openvpn iptables socat curl openssl stunnel

# Добавляем исполняемые файлы в контейнер
ADD ./bin /usr/local/sbin

# Создаём нужные директории
RUN mkdir -p /etc/openvpn /etc/stunnel /var/log
VOLUME /etc/openvpn
# Пробрасываем порты для VPN и обфускации
EXPOSE 443/tcp 1194/udp 8080/tcp

# Запускаем основной скрипт
CMD ["run"]