#!/usr/bin/env bash
# html-mode-skill · 启动 3001 预览（Unix）
set -euo pipefail

ROOT="${1:?usage: kami-preview-3001.sh <workspaceRoot> [port]}"
PORT="${2:-3001}"
HTML_DIR="$ROOT/对话 html"

if [[ ! -d "$HTML_DIR" ]]; then
  echo "Missing: $HTML_DIR" >&2
  exit 1
fi
if [[ ! -f "$HTML_DIR/index.html" ]]; then
  echo "Missing: $HTML_DIR/index.html" >&2
  exit 1
fi

DIR="$(cd "$HTML_DIR" && pwd)"
SERVE_PY="${HOME}/.cursor/scripts/kami-serve.py"
if [[ ! -f "$SERVE_PY" ]]; then
  SERVE_PY="${HOME}/.cursor/skills/rough-idea-to-plan/scripts/kami-serve.py"
fi
if [[ ! -f "$SERVE_PY" ]]; then
  SERVE_PY="$(cd "$(dirname "$0")" && pwd)/kami-serve.py"
fi

if command -v lsof >/dev/null 2>&1; then
  lsof -ti:"$PORT" | xargs -r kill -9 2>/dev/null || true
elif command -v fuser >/dev/null 2>&1; then
  fuser -k "${PORT}/tcp" 2>/dev/null || true
fi
sleep 0.3

if [[ -f "$SERVE_PY" ]] && command -v python3 >/dev/null 2>&1; then
  (cd "$DIR" && python3 "$SERVE_PY" . "$PORT") &
elif command -v python3 >/dev/null 2>&1; then
  (cd "$DIR" && python3 -m http.server "$PORT" --bind 127.0.0.1) &
else
  echo "Need python3 on PATH" >&2
  exit 1
fi

PID=$!
for _ in $(seq 1 50); do
  if curl -fsS "http://127.0.0.1:${PORT}/" >/dev/null 2>&1; then
    echo "Kami preview: http://localhost:${PORT}"
    echo "Serving: $DIR"
    echo "PID=$PID"
    exit 0
  fi
  sleep 0.25
done

kill "$PID" 2>/dev/null || true
echo "Port $PORT not ready" >&2
exit 1
