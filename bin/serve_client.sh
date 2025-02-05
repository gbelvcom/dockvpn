#!/bin/sh
# Отдаем клиенту содержимое файла client.http
cat /etc/openvpn/client.http
# Если cat завершился успешно, считаем, что передача завершена
if [ $? -eq 0 ]; then
    echo "client_downloaded" > /tmp/client_downloaded.marker
fi