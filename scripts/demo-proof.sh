#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
cd "$PROJECT_DIR"

echo ""
show_logo
echo -e "  ${CYAN}${BOLD}"
cat <<'ART'
      ____  ____   ___  ____  _____
     |  _ \|  _ \ / _ \|  _ \| ____|
     | |_) | |_) | | | | | | |  _|
     |  __/|  __/| |_| | |_| | |___
     |_|   |_|    \___/|____/|_____|
ART
echo -e "${NC}${DIM}     does the code work?${NC}"
echo ""

# Load env
if [ -f .env ]; then
  load_env
else
  err "No .env file — run ./guide first"
  exit 1
fi

WEBHOOK_URL="${WEBHOOK_URL:-http://localhost:5678/webhook/support-inquiry}"
TOKEN="${WEBHOOK_AUTH_TOKEN:-}"

say "Layer 1: Infrastructure"
"$SCRIPT_DIR/verify-stack.sh" || true
echo ""

say "Layer 2: Vector store (RAG knowledge)"
if curl -sf http://localhost:6333/collections/support_kb >/dev/null 2>&1; then
  POINTS=$(curl -sf http://localhost:6333/collections/support_kb | python3 -c "import sys,json; print(json.load(sys.stdin).get('result',{}).get('points_count',0))" 2>/dev/null || echo "0")
  if [ "${POINTS:-0}" -gt 0 ] 2>/dev/null; then
    ok "Qdrant has $POINTS embedded chunks"
  else
    warn "Qdrant collection empty — run KB Ingestion in n8n"
  fi
else
  warn "Collection support_kb not found"
fi
echo ""

say "Layer 3: End-to-end webhook"
PAYLOAD='{"customer_name":"Demo Proof","customer_email":"'"${GMAIL_FROM_ADDRESS:-demo@example.com}"'","subject":"API 401","message":"API returns 401 invalid_api_key with Bearer auth"}'
say "POST $WEBHOOK_URL"

HTTP_CODE=$(curl -s -o /tmp/demo-proof-response.json -w "%{http_code}" \
  -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -H "X-Webhook-Token: $TOKEN" \
  -d "$PAYLOAD" \
  --max-time 300 || echo "000")

if [ "$HTTP_CODE" = "200" ]; then
  ok "Webhook returned 200"
  python3 -m json.tool /tmp/demo-proof-response.json 2>/dev/null | sed 's/^/    /'
elif [ "$HTTP_CODE" = "404" ]; then
  err "Webhook 404 — activate '02 - Support Agent' in n8n"
elif [ "$HTTP_CODE" = "401" ]; then
  err "Webhook 401 — token mismatch in .env vs demo/config.js"
else
  err "Webhook returned HTTP $HTTP_CODE"
fi
echo ""

say "Layer 4: Postgres audit trail"
if docker compose exec -T postgres pg_isready -U support_agent -d support_agent >/dev/null 2>&1; then
  ROWS=$(docker compose exec -T postgres psql -U support_agent -d support_agent -tAc "SELECT COUNT(*) FROM support_interactions;" 2>/dev/null || echo "0")
  ok "support_interactions has $ROWS row(s)"
  if [ "${ROWS:-0}" -gt 0 ] 2>/dev/null; then
    docker compose exec -T postgres psql -U support_agent -d support_agent -c \
      "SELECT created_at, intent, status, processing_ms FROM support_interactions ORDER BY created_at DESC LIMIT 3;" 2>/dev/null | sed 's/^/    /'
  fi
fi
echo ""

if [ "$HTTP_CODE" = "200" ]; then
  show_complete_art
else
  warn "Finish n8n setup — run ./guide for help"
fi
