#!/bin/bash

echo "🔧 Отключение защиты и восстановление стандартного интернета..."

# Отключаем PF (брандмауэр)
sudo pfctl -d
echo "✅ PF (брандмауэр) отключен."

# Определяем VPN-интерфейс
VPN_IF=$(ifconfig | grep -o "utun[0-9]" | tail -n 1)

if [[ -n "$VPN_IF" ]]; then
    # Определяем VPN-шлюз
    VPN_GATEWAY=$(netstat -rn | grep "^default" | grep "$VPN_IF" | awk '{print $2}')

    # Удаляем маршрут через VPN
    if [[ -n "$VPN_GATEWAY" ]]; then
        sudo route delete default "$VPN_GATEWAY"
        echo "✅ Маршрут через VPN ($VPN_GATEWAY) удалён."
    fi
else
    echo "⚠ Не найден VPN-интерфейс. Возможно, VPN уже отключен."
fi

# Восстанавливаем стандартный интернет (Wi-Fi / Ethernet)
DEFAULT_GATEWAY=$(netstat -rn | grep default | grep -E "en[0-9]" | awk '{print $2}' | head -n 1)

if [[ -n "$DEFAULT_GATEWAY" ]]; then
    sudo route add default "$DEFAULT_GATEWAY"
    echo "✅ Интернет восстановлен через $DEFAULT_GATEWAY"
else
    echo "⚠ Не удалось автоматически восстановить маршрут! Проверьте соединение Wi-Fi или Ethernet."
fi

echo "✅ Защита отключена. Интернет работает без VPN."
