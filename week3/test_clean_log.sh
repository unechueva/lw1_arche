#!/bin/bash

TEST_DIR="$HOME/vdisk_test"
LOG_DIR="$TEST_DIR/log"
BACKUP_DIR="$TEST_DIR/backup"

rm -rf "$TEST_DIR"
mkdir -p "$LOG_DIR" "$BACKUP_DIR"

echo "Тест 1: пустая папка"
~/lw1_arche/week3/clean_log.sh "$LOG_DIR" 70 5
echo "----"

echo "Создаем несколько маленьких файлов"
for i in {1..3}; do echo "test$i" > "$LOG_DIR/file$i.txt"; done

echo "Тест 2: мало файлов"
~/lw1_arche/week3/clean_log.sh "$LOG_DIR" 70 5
echo "----"

echo "Создаем большие файлы для переполнения"
for i in {1..10}; do dd if=/dev/zero of="$LOG_DIR/bigfile$i" bs=1M count=10 status=none; done

echo "Тест 3: переполнение (порог 1 МБ)"
~/lw1_arche/week3/clean_log.sh "$LOG_DIR" 1 5
echo "----"

echo "Тест 4: проверка архива"
ls -lh "$BACKUP_DIR"
echo "----"

echo "Все тесты завершены"
