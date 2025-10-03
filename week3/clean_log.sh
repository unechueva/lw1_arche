#!/bin/bash

LOG_DIR=$1
THRESHOLD=$2
COUNT=$3
BACKUP_DIR=$(dirname "$LOG_DIR")/backup

if [ -z "$LOG_DIR" ] || [ -z "$THRESHOLD" ] || [ -z "$COUNT" ]; then
    echo "Использование: $0 <путь к log> <порог %> <количество файлов>"
    exit 1
fi

if [ ! -d "$LOG_DIR" ]; then
    echo "Ошибка! Папка не найдена: $LOG_DIR"
    exit 1
fi

mkdir -p "$BACKUP_DIR"

USAGE=$(df -h "$LOG_DIR" | awk 'NR==2 {print $5}' | tr -d '%')

echo "Папка: $LOG_DIR"
echo "Занято: ${USAGE}% (порог: ${THRESHOLD}%)"

if [ "$USAGE" -ge "$THRESHOLD" ]; then
    echo "Порог превышен! Архивируем $COUNT старейших файлов..."
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    ARCHIVE="$BACKUP_DIR/archive_${TIMESTAMP}.tar.gz"

    FILES=$(ls -t "$LOG_DIR" | tail -n "$COUNT")
    if [ -z "$FILES" ]; then
        echo "Нет файлов для архивации"
        exit 0
    fi

    tar -czf "$ARCHIVE" -C "$LOG_DIR" $FILES && rm -f $(for f in $FILES; do echo "$LOG_DIR/$f"; done)

    if [ $? -eq 0 ]; then
        echo "Архив создан: $ARCHIVE"
    else
        echo "Ошибка при создании архива"
    fi
else
    echo "Всё в порядке: параметр ниже порога"
fi

