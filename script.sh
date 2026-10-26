#!/bin/bash
# Раз в INTERVAL секунд дописывает в LOG_FILE снимок free -h, df -h и uptime.

INTERVAL=10
LOG_FILE="monitor.log"

die() {
  echo "error: $*" >&2
  exit 1
}

require_commands() {
  local cmd
  for cmd in free df uptime date mktemp; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      die "команда не найдена: $cmd"
    fi
  done
}

ensure_log() {
  if ! touch "$LOG_FILE" 2>/dev/null; then
    die "не удалось создать файл лога: $LOG_FILE"
  fi
  if [ ! -w "$LOG_FILE" ]; then
    die "нет прав на запись в $LOG_FILE"
  fi
}

write_snapshot() {
  local tmp status
  tmp=$(mktemp) || return 1
  (
    echo "--- $(date '+%Y-%m-%d %H:%M:%S') ---" || exit 1
    free -h || exit 1
    df -h || exit 1
    uptime || exit 1
    echo
  ) > "$tmp"
  status=$?
  if [ "$status" -ne 0 ]; then
    rm -f "$tmp"
    return 1
  fi
  cat "$tmp" >> "$LOG_FILE"
  status=$?
  rm -f "$tmp"
  return "$status"
}

on_stop() {
  echo "мониторинг остановлен" >&2
  exit 0
}

require_commands
ensure_log
trap on_stop INT TERM

echo "мониторинг запущен, интервал ${INTERVAL} с, лог: ${LOG_FILE}" >&2

while true; do
  if ! write_snapshot; then
    die "ошибка записи в $LOG_FILE"
  fi
  sleep "$INTERVAL" || exit 0
done
