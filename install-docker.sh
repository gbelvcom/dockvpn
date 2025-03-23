#!/bin/bash

set -e

echo "🔧 Обновляем систему..."
sudo apt update && sudo apt upgrade -y

echo "📦 Устанавливаем зависимости..."
sudo apt install -y ca-certificates curl gnupg lsb-release

echo "🔑 Добавляем GPG-ключ Docker..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "📁 Добавляем Docker репозиторий..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "🔄 Обновляем индекс пакетов..."
sudo apt update

echo "🐳 Устанавливаем Docker Engine и утилиты..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "✅ Проверка установки Docker..."
sudo docker version

echo "👤 Добавляем пользователя $USER в группу docker..."
sudo usermod -aG docker $USER

echo "✅ Установка завершена. Перезапусти терминал или выполни команду 'newgrp docker', чтобы применять права без перезагрузки."
