#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

echo "=== Autonomous Support Agent — Setup ==="
echo ""

if [ ! -f .env ]; then
  echo "Creating .env from .env.example..."
  cp .env.example .env
  echo "  Edit .env and set POSTGRES_PASSWORD, N8N secrets, and WEBHOOK_AUTH_TOKEN."
else
  echo ".env already exists, skipping copy."
fi

PROFILE="${1:-cpu}"
echo ""
echo "Starting Docker stack (profile: $PROFILE)..."
echo "  First boot pulls Ollama models — this may take 5-15 minutes on CPU."
echo ""

docker compose --profile "$PROFILE" up -d

echo ""
echo "Waiting for services..."
sleep 5

# Wait for postgres
for i in {1..30}; do
  if docker compose exec -T postgres pg_isready -U support_agent -d support_agent >/dev/null 2>&1; then
    echo "  Postgres: ready"
    break
  fi
  sleep 2
done

# Wait for n8n
for i in {1..60}; do
  if curl -sf http://localhost:5678/healthz >/dev/null 2>&1; then
    echo "  n8n: ready"
    break
  fi
  sleep 3
done

echo ""
echo "=== Stack is starting ==="
echo ""
echo "  n8n UI:        http://localhost:5678"
echo "  Qdrant:        http://localhost:6333/dashboard"
echo "  Postgres:      localhost:5432 (db: support_agent)"
echo "  Demo form:     open demo/index.html in your browser"
echo ""
echo "Next steps:"
echo "  1. Open n8n → configure credentials (see README.md)"
echo "  2. Run workflow '01 - KB Ingestion' (manual trigger)"
echo "  3. Connect Gmail OAuth (see docs/gmail-setup.md)"
echo "  4. Activate workflow '02 - Support Agent'"
echo "  5. Update demo/config.js webhook URL if needed"
echo ""
echo "Monitor Ollama model pull:"
echo "  docker compose logs -f ollama-init"
echo ""
