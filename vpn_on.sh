#!/bin/bash

echo "🔧 Настройка брандмауэра для работы ТОЛЬКО через VPN..."

# Даем время VPN подключиться
sleep 10

# Определяем VPN-интерфейс
VPN_IF=$(ifconfig | grep -o "utun[0-9]" | head -n 1)

# Определяем шлюз VPN
VPN_GATEWAY=$(netstat -rn | grep "^default" | grep "$VPN_IF" | awk '{print $2}')

# Создаём временный конфиг для PF
PF_RULES="/tmp/pf.vpn_rules"
echo "block all" > "$PF_RULES"

# 🔹 Разрешаем трафик для VPN-клиента (OpenVPN, WireGuard, IPsec)
# OpenVPN (UDP 1194, 443) и IPsec (UDP 500, 4500)
echo "pass out proto udp to any port 1194 keep state" >> "$PF_RULES"
echo "pass out proto udp to any port 500 keep state" >> "$PF_RULES"
echo "pass out proto udp to any port 4500 keep state" >> "$PF_RULES"
echo "pass out proto tcp to any port 443 keep state" >> "$PF_RULES"

# Разрешаем DNS-запросы (UDP 53), чтобы VPN-клиент мог находить серверы
echo "pass out proto udp to any port 53 keep state" >> "$PF_RULES"

# Если VPN включен, разрешаем трафик через него
if [[ -n "$VPN_IF" && -n "$VPN_GATEWAY" ]]; then
    echo "✅ VPN подключен: интерфейс $VPN_IF, шлюз $VPN_GATEWAY"

    # Удаляем существующий маршрут по умолчанию и добавляем новый через VPN
    sudo route delete default > /dev/null 2>&1
    sudo route add default "$VPN_GATEWAY"

    # Разрешаем трафик через ВСЕ utun-интерфейсы
    for utun in $(ifconfig | grep -o "utun[0-9]"); do
        echo "pass in on $utun all keep state" >> "$PF_RULES"
        echo "pass out on $utun all keep state" >> "$PF_RULES"
    done

    # Разрешаем трафик к VPN-шлюзу (чтобы VPN мог подключаться)
    for iface in $(ifconfig | grep -o "en[0-9]"); do
        echo "pass out on $iface to $VPN_GATEWAY keep state" >> "$PF_RULES"
    done
else
    echo "❌ VPN выключен! Блокируем весь интернет, кроме VPN-подключений."
fi

# Загружаем конфиг в PF и включаем брандмауэр
sudo pfctl -f "$PF_RULES"
sudo pfctl -e

echo "✅ Брандмауэр обновлен: интернет работает ТОЛЬКО через VPN."