#!/bin/bash

if [ $# -lt 3 ]; then
    echo "Использование: $0 <путь_к_логам> <порог_МБ> <кол-во_файлов_для_архива>" >&2
    exit 1
fi

target_dir="$1"
threshold="$2"
count="$3"
backup_dir="$target_dir/../backup"

if [ ! -d "$target_dir" ]; then
    echo "Ошибка! Папка не найдена: $target_dir" >&2
    exit 1
fi

mkdir -p "$backup_dir"

size_bytes=$(du -sb "$target_dir" | cut -f1)
size_mb=$(( size_bytes / 1024 / 1024 ))
percent=$(( size_mb * 100 / threshold ))

echo "Папка: $target_dir"
echo "Размер: ${size_mb}M (порог: ${threshold}M)"
echo "Процент от порога: ${percent}%"

if [ "$percent" -gt 100 ]; then
    echo "Порог превышен! Архивируем $count старейших файлов..."
    oldest_files=$(ls -tr "$target_dir" | head -n "$count")

    if [ -z "$oldest_files" ]; then
        echo "Нет файлов для архивации"
        exit 0
    fi

    timestamp=$(date +%Y%m%d_%H%M%S)
    archive_file="$backup_dir/archive_${timestamp}.tar.gz"

    tar -czf "$archive_file" -C "$target_dir" $oldest_files 2>/dev/null
    if [ $? -eq 0 ]; then
        for f in $oldest_files; do
            rm -f "$target_dir/$f"
        done
        echo "Архив создан: $archive_file"
    else
        echo "Ошибка при создании архива" >&2
        exit 2
    fi
else
    echo "Всё в порядке: параметр ниже порога"
fi
