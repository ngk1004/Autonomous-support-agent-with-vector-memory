#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PORT="${1:-8080}"

echo "Serving demo at http://localhost:$PORT"
echo "Open http://localhost:$PORT/index.html"
echo "Press Ctrl+C to stop."
echo ""

cd "$PROJECT_DIR/demo"
python3 -m http.server "$PORT"
