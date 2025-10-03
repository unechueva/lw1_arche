#!/bin/bash

if [ $# -lt 3 ]; then
    echo "Использование: $0 <путь_к_логам> <порог_МБ> <кол-во_файлов_для_архива>"
    exit 1
fi

TARGET_DIR="$1"
THRESHOLD="$2"
COUNT="$3"
BACKUP_DIR="$TARGET_DIR/../backup"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Ошибка! Папка не найдена: $TARGET_DIR"
    exit 1
fi

mkdir -p "$BACKUP_DIR"

SIZE_BYTES=$(du -sb "$TARGET_DIR" | cut -f1)
SIZE_MB=$(( SIZE_BYTES / 1024 / 1024 ))
PERCENT=$(( SIZE_MB * 100 / THRESHOLD ))

echo "Папка: $TARGET_DIR"
echo "Размер: ${SIZE_MB}M (порог: ${THRESHOLD}M)"
echo "Процент от порога: ${PERCENT}%"

if [ "$PERCENT" -gt 100 ]; then
    echo "Порог превышен! Архивируем $COUNT старейших файлов..."

    OLDEST_FILES=$(ls -tr "$TARGET_DIR" | head -n "$COUNT")

    if [ -z "$OLDEST_FILES" ]; then
        echo "Нет файлов для архивации"
        exit 0
    fi

    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    ARCHIVE_FILE="$BACKUP_DIR/archive_${TIMESTAMP}.tar.gz"

    tar -czf "$ARCHIVE_FILE" -C "$TARGET_DIR" $OLDEST_FILES 2>/dev/null
    if [ $? -eq 0 ]; then
        for f in $OLDEST_FILES; do
            rm -f "$TARGET_DIR/$f"
        done
        echo "Архив создан: $ARCHIVE_FILE"
    else
        echo "Ошибка при создании архива"
    fi
else
    echo "Всё в порядке: параметр ниже порога"
fi
