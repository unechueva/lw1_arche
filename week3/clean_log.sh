#!/bin/bash

LOG_DIR="$1"
THRESHOLD=${2:-70} 
COUNT=${3:-5}
BACKUP_DIR="${LOG_DIR%/log}/backup"

if [ ! -d "$LOG_DIR" ]; then
    echo "Ошибка! Папка не найдена: $LOG_DIR"
    exit 1
fi

mkdir -p "$BACKUP_DIR"

DIR_SIZE=$(du -sm "$LOG_DIR" | awk '{print $1}')
echo "Папка: $LOG_DIR"
echo "Размер: $DIR_SIZE МБ (порог: $THRESHOLD МБ)"

if [ "$DIR_SIZE" -gt "$THRESHOLD" ]; then
    echo "Порог превышен! Архивируем $COUNT старейших файлов..."

    FILES=$(ls -tr "$LOG_DIR" | head -n "$COUNT")
    if [ -z "$FILES" ]; then
        echo "Нет файлов для архивирования."
        exit 0
    fi

    ARCHIVE="$BACKUP_DIR/archive_$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -czf "$ARCHIVE" -C "$LOG_DIR" $FILES
    if [ $? -eq 0 ]; then
        echo "Архив создан: $ARCHIVE"
        for f in $FILES; do
            rm -f "$LOG_DIR/$f"
        done
    else
        echo "Ошибка при создании архива"
    fi
else
    echo "Всё в порядке: параметр ниже порога"
fi
