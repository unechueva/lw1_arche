#!/bin/bash

base_dir=~/vdisk_test
log_dir="$base_dir/log"
backup_dir="$base_dir/backup"
script_path=./clear_logs.sh

cleanup()
{
    rm -rf "$base_dir"
    mkdir -p "$log_dir" "$backup_dir"
}

create_file()
{
    dd if=/dev/urandom of="$1" bs=1M count="$2" status=none
    touch -d "$3 days ago" "$1"
}

cleanup
echo "Тест 1: пустая папка"
$script_path "$log_dir" 70 3
echo "----"

cleanup
echo "Тест 2: несколько маленьких файлов"
for i in {1..3}
do
    create_file "$log_dir/file_$i.txt" 1 "$i"
done
$script_path "$log_dir" 70 3
echo "----"

cleanup
echo "Тест 3: переполнение (порог 10%)"
for i in {1..8}
do
    create_file "$log_dir/old_$i.log" 100 "$i"
done
$script_path "$log_dir" 10 3
echo "----"

echo "Тест 4: проверка архива"
sleep 1
ls -lh "$backup_dir"
latest_archive=$(ls -t "$backup_dir"/*.tar.gz 2>/dev/null | head -n 1)
if [ -n "$latest_archive" ]; then
    echo "Содержимое архива:"
    tar -tzf "$latest_archive" | head -n 5
else
    echo "Архив не найден!"
fi
echo "----"

cleanup
echo "Тест 5: папка >0.5 ГБ"
for i in {1..6}
do
    create_file "$log_dir/big_$i.log" 100 "$i"
done
$script_path "$log_dir" 500 3
echo "Тест 5 завершён"
echo "----"

echo "Все тесты завершены!"
