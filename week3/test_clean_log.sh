#!/bin/bash

LOG_DIR="$HOME/vdisk_test/log"
BACKUP_DIR="$HOME/vdisk_test/backup"

mkdir -p "$LOG_DIR"
mkdir -p "$BACKUP_DIR"

cleanup() {
    rm -f "$LOG_DIR"/*
    rm -f "$BACKUP_DIR"/*
}

create_file() {
    local name=$1
    local size_mb=$2
    dd if=/dev/zero of="$LOG_DIR/$name" bs=1M count="$size_mb" status=none
}

cleanup
echo "Тест 1: пустая папка"
echo "Папка: $LOG_DIR"
~/lw1_arche/week3/clean_log.sh "$LOG_DIR" 70 5
echo "Тест 1 завершён"
echo "----"

cleanup
echo "Создаем несколько маленьких файлов"
create_file "file1.txt" 1
create_file "file2.txt" 1
create_file "file3.txt" 1
echo "Тест 2: мало файлов"
echo "Папка: $LOG_DIR"
~/lw1_arche/week3/clean_log.sh "$LOG_DIR" 70 5
echo "Тест 2 завершён"
echo "----"

cleanup
echo "Создаем большие файлы для переполнения"
create_file "bigfile1" 200
create_file "bigfile2" 200
create_file "bigfile3" 200
create_file "bigfile4" 200
echo "Тест 3: переполнение (порог 10%)"
echo "Папка: $LOG_DIR"
~/lw1_arche/week3/clean_log.sh "$LOG_DIR" 10 3
echo "Тест 3 завершён"
echo "----"

echo "Тест 4: проверка архива"
ls -lh "$BACKUP_DIR"
echo "Тест 4 завершён"
echo "----"

echo "Все тесты завершены!"
