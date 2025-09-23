while [ $# -gt 0 ]; do
    if [ "$1" = "--path" ]; then
        path="$2"
        shift 2
    elif [ "$1" = "--threshold" ]; then
        threshold="$2"
        shift 2
    else
        echo "Неизвестный параметр: $1"
        echo "Использование: $0 --path <папка> --threshold <число>"
        exit 1
    fi
done

if [ -z "$path" ] || [ -z "$threshold" ]; then
    echo "Ошибка"
    exit 1
fi

used=$(du -s "$path" | awk '{print $1}')

total=$(df "$path" | tail -1 | awk '{print $2}')

percent=$((used * 100 / total))

echo "Папка: $path"
echo "Занято: $percent% (порог: $threshold%)"

if [ "$percent" -gt "$threshold" ]; then
    echo "Папка не ок"
else
    echo "Папка ок"
fi
