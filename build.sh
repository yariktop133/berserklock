#!/usr/bin/env bash
set -e

echo "=== Сборка твика BerserkLock для Dopamine Rootless (iOS 15.8.7) ==="

if [ -z "$THEOS" ]; then
    if [ -d "$HOME/theos" ]; then
        export THEOS="$HOME/theos"
    elif [ -d "/var/theos" ]; then
        export THEOS="/var/theos"
    else
        echo "Ошибка: Переменная THEOS не установлена, и каталог theos не найден в $HOME/theos"
        echo "Установите Theos: bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/theos/theos/master/bin/install-theos)\""
        exit 1
    fi
fi

echo "Используется Theos: $THEOS"

# Очистка предыдущих сборок
make clean

# Сборка финального deb-пакета
make package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=rootless

echo "=== Сборка успешно завершена! ==="
echo "Пакет находится в директории ./packages/"
ls -la packages/
