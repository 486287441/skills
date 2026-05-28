#!/usr/bin/env python3
"""Kami preview: static files + optional POST /api/save-choices (html-mode 通常不用)."""
from __future__ import annotations

import json
import os
import sys
from http.server import HTTPServer, SimpleHTTPRequestHandler
from pathlib import Path

ROOT = Path(sys.argv[1]).resolve()
PORT = int(sys.argv[2]) if len(sys.argv) > 2 else 3001


class KamiHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT), **kwargs)

    def do_POST(self) -> None:
        if self.path.split("?", 1)[0] != "/api/save-choices":
            self.send_error(404)
            return
        length = int(self.headers.get("Content-Length", 0))
        raw = self.rfile.read(length)
        try:
            data = json.loads(raw.decode("utf-8"))
        except (json.JSONDecodeError, UnicodeDecodeError):
            self.send_error(400, "Invalid JSON")
            return
        out = ROOT / "choices.json"
        out.write_text(
            json.dumps(data, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        body = json.dumps({"ok": True, "path": str(out)}, ensure_ascii=False).encode(
            "utf-8"
        )
        self.send_response(200)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt: str, *args) -> None:
        if args and str(args[0]).startswith("POST /api/save-choices"):
            sys.stderr.write("Kami: saved choices.json\n")


def main() -> None:
    os.chdir(ROOT)
    server = HTTPServer(("127.0.0.1", PORT), KamiHandler)
    print(f"Kami preview: http://localhost:{PORT}", flush=True)
    print(f"Serving: {ROOT}", flush=True)
    server.serve_forever()


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("usage: kami-serve.py <directory> [port]", file=sys.stderr)
        sys.exit(2)
    main()
