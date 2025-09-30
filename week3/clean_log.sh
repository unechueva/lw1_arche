#!/bin/bash
TARGET=""
THR=70
NUM=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --path) TARGET="$2"; shift 2 ;;
    --threshold) THR="$2"; shift 2 ;;
    --count) NUM="$2"; shift 2 ;;
    *) echo "Использование: $0 --path <путь> --threshold <процент> --count <число>"; exit 1 ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  echo "Ошибка! Обязательно должен быть параметр --path"
  exit 1
fi

if [[ ! -d "$TARGET" ]]; then
  echo "Ошибка! Папка не найдена: $TARGET"
  exit 1
fi

BACK_DIR="${TARGET%/*}/backup"
mkdir -p "$BACK_DIR"

used_blocks=$(du -s "$TARGET" | awk '{print $1}')
total_blocks=$(df "$TARGET" | tail -1 | awk '{print $2}')

if [[ -z "$used_blocks" ]] || [[ -z "$total_blocks" ]] || [[ "$total_blocks" -eq 0 ]]; then
  echo "Ошибка! Невозможно определить размер диска"
  exit 1
fi

PCT=$(( used_blocks * 100 / total_blocks ))

echo "Папка: $TARGET"
echo "Занято: ${PCT}% (порог: ${THR}%)"

if (( PCT <= THR )); then
  echo "Всё в порядке: параметр ниже порога"
  exit 0
fi

file_count=$(find "$TARGET" -maxdepth 1 -type f | wc -l)
if (( file_count == 0 )); then
  echo "Не найдены файлы для архивации"
  exit 0
fi

if (( NUM > file_count )); then
  NUM=$file_count
fi

mapfile -t ordered_files < <(find "$TARGET" -maxdepth 1 -type f -printf '%T@ %p\n' | sort -n | awk '{$1=""; sub(/^ /,""); print}')
selected=( "${ordered_files[@]:0:NUM}" )

basenames=()
for f in "${selected[@]}"; do
  basenames+=( "$(basename "$f")" )
done

archive="${BACK_DIR}/archive_$(date +%Y%m%d_%H%M%S).tar.gz"

tar -czf "$archive" -C "$TARGET" "${basenames[@]}" && {
  for b in "${basenames[@]}"; do rm -f "$TARGET/$b"; done
  echo "Архив создан: $archive"
} || {
  echo "Ошибка при создании архива"
  exit 1
}
