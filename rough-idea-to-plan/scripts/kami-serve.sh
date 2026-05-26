#!/usr/bin/env bash
# Kami static preview — port 3000, serves one folder (e.g. 对话 html)
set -euo pipefail

DIR="${1:?usage: kami-serve.sh <directory> [port]}"
PORT="${2:-3000}"

cd "$(cd "$DIR" && pwd)"

free_port() {
  local p="$1"
  if command -v lsof >/dev/null 2>&1; then
    lsof -ti:"$p" 2>/dev/null | xargs -r kill -9 2>/dev/null || true
  elif command -v fuser >/dev/null 2>&1; then
    fuser -k "${p}/tcp" 2>/dev/null || true
  fi
  sleep 0.3
}

free_port "$PORT"

wait_for_port() {
  local port="$1" max="${2:-20}" i=0 limit=$((max * 5))
  while [ "$i" -lt "$limit" ]; do
    if command -v nc >/dev/null 2>&1; then
      nc -z 127.0.0.1 "$port" 2>/dev/null && return 0
    elif (echo >/dev/tcp/127.0.0.1/"$port") 2>/dev/null; then
      return 0
    fi
    sleep 0.2
    i=$((i + 1))
  done
  return 1
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVE_PY="$HOME/.cursor/scripts/kami-serve.py"
[ -f "$SERVE_PY" ] || SERVE_PY="$SCRIPT_DIR/kami-serve.py"

if [ -f "$SERVE_PY" ] && command -v python3 >/dev/null 2>&1; then
  nohup python3 "$SERVE_PY" "$DIR" "$PORT" >/dev/null 2>&1 &
elif [ -f "$SERVE_PY" ] && command -v python >/dev/null 2>&1; then
  nohup python "$SERVE_PY" "$DIR" "$PORT" >/dev/null 2>&1 &
elif command -v python3 >/dev/null 2>&1; then
  nohup python3 -m http.server "$PORT" >/dev/null 2>&1 &
elif command -v python >/dev/null 2>&1; then
  nohup python -m http.server "$PORT" >/dev/null 2>&1 &
elif command -v npx >/dev/null 2>&1; then
  nohup npx --yes serve -l "$PORT" . >/dev/null 2>&1 &
else
  echo "Need python3 or npx on PATH" >&2
  exit 1
fi

if ! wait_for_port "$PORT"; then
  echo "Port $PORT not listening after 20s. Check Python install or server logs." >&2
  exit 1
fi

echo "Kami preview: http://localhost:${PORT}"
echo "Serving: $(pwd)"
