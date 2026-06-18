#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}✓${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; FAILURES=$((FAILURES + 1)); }
warn() { echo -e "${YELLOW}!${NC} $1"; }

FAILURES=0

echo "=== Stack Verification ==="
echo ""

# Docker
if command -v docker >/dev/null 2>&1; then
  pass "Docker installed"
else
  fail "Docker not installed"
fi

# n8n
if curl -sf http://localhost:5678/healthz >/dev/null 2>&1; then
  pass "n8n healthy (http://localhost:5678)"
else
  fail "n8n not reachable — run ./scripts/setup.sh"
fi

# Postgres
if docker compose exec -T postgres pg_isready -U support_agent -d support_agent >/dev/null 2>&1; then
  pass "PostgreSQL ready"
  TABLE=$(docker compose exec -T postgres psql -U support_agent -d support_agent -tAc "SELECT COUNT(*) FROM information_schema.tables WHERE table_name='support_interactions';" 2>/dev/null || echo "0")
  if [ "$TABLE" = "1" ]; then
    pass "support_interactions table exists"
  else
    fail "support_interactions table missing"
  fi
else
  fail "PostgreSQL not ready"
fi

# Qdrant
if curl -sf http://localhost:6333/readyz >/dev/null 2>&1; then
  pass "Qdrant healthy"
  if curl -sf http://localhost:6333/collections/support_kb >/dev/null 2>&1; then
    POINTS=$(curl -sf http://localhost:6333/collections/support_kb | python3 -c "import sys,json; print(json.load(sys.stdin).get('result',{}).get('points_count',0))" 2>/dev/null || echo "0")
    if [ "${POINTS:-0}" -gt 0 ] 2>/dev/null; then
      pass "Qdrant collection support_kb has $POINTS vectors"
    else
      warn "Qdrant collection empty — run KB Ingestion workflow"
    fi
  else
    warn "Collection support_kb not found — run KB Ingestion workflow"
  fi
else
  fail "Qdrant not reachable"
fi

# Ollama
if curl -sf http://localhost:11434/api/tags >/dev/null 2>&1; then
  pass "Ollama API reachable"
  TAGS=$(curl -sf http://localhost:11434/api/tags | python3 -c "import sys,json; print(' '.join(m.get('name','') for m in json.load(sys.stdin).get('models',[])))" 2>/dev/null || echo "")
  echo "$TAGS" | grep -q "llama3.2" && pass "llama3.2 model available" || warn "llama3.2 not pulled yet"
  echo "$TAGS" | grep -q "nomic-embed-text" && pass "nomic-embed-text model available" || warn "nomic-embed-text not pulled yet"
else
  fail "Ollama not reachable at localhost:11434"
fi

# Workflows JSON
for wf in workflows/*.json; do
  python3 -c "import json; json.load(open('$wf'))" 2>/dev/null && pass "Valid JSON: $(basename "$wf")" || fail "Invalid JSON: $(basename "$wf")"
done

# KB articles
KB_COUNT=$(find knowledge-base -name '*.md' | wc -l | tr -d ' ')
[ "$KB_COUNT" -ge 10 ] && pass "Knowledge base: $KB_COUNT articles" || warn "Knowledge base: only $KB_COUNT articles"

echo ""
if [ "$FAILURES" -eq 0 ]; then
  echo -e "${GREEN}All critical checks passed.${NC}"
  echo "Next: configure credentials in n8n, run ingestion, activate Support Agent."
else
  echo -e "${RED}$FAILURES critical check(s) failed.${NC}"
  exit 1
fi
