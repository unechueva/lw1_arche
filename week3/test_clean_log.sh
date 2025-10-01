#!/bin/bash

LOG_DIR="$HOME/vdisk_test/log"
BACKUP_DIR="$HOME/vdisk_test/backup"
SCRIPT="$HOME/lw1_arche/week3/clean_log.sh"

rm -rf "$LOG_DIR" "$BACKUP_DIR"
mkdir -p "$LOG_DIR" "$BACKUP_DIR"

echo "Тест 1: пустая папка"
$SCRIPT --path "$LOG_DIR" --threshold 70 --count 2
echo "----"

echo "Создаем несколько маленьких файлов"
for i in {1..5}; do
    echo "file$i" > "$LOG_DIR/file$i.txt"
done

echo "Тест 2: мало файлов"
$SCRIPT --path "$LOG_DIR" --threshold 70 --count 2
echo "----"

echo "Создаем большие файлы для переполнения"
for i in {1..10}; do
    dd if=/dev/zero of="$LOG_DIR/bigfile$i" bs=10M count=1 status=none
done

echo "Тест 3: переполнение (порог 10%)"
$SCRIPT --path "$LOG_DIR" --threshold 10 --count 5
echo "----"

echo "Тест 4: проверка архива"
ls -lh "$BACKUP_DIR"
echo "----"

echo "Все тесты завершены!"
