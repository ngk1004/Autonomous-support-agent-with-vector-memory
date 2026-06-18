#!/usr/bin/env bash
set -euo pipefail

echo "=== KB Ingestion Reminder ==="
echo ""
echo "KB ingestion runs inside n8n (not via curl)."
echo ""
echo "Steps:"
echo "  1. Open http://localhost:5678"
echo "  2. Open workflow '01 - KB Ingestion'"
echo "  3. Verify credentials: Qdrant Local, Ollama OpenAI Compatible"
echo "  4. Click 'Execute Workflow'"
echo ""
echo "Verify Qdrant collection:"
echo "  curl -s http://localhost:6333/collections/support_kb | python3 -m json.tool"
echo ""
echo "Or check in Qdrant dashboard: http://localhost:6333/dashboard"
echo ""

# Optional: check if collection exists
if curl -sf http://localhost:6333/collections/support_kb >/dev/null 2>&1; then
  POINTS=$(curl -sf http://localhost:6333/collections/support_kb | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('result',{}).get('points_count','?'))" 2>/dev/null || echo "?")
  echo "Collection support_kb exists — points: $POINTS"
else
  echo "Collection support_kb not found yet. Run ingestion workflow first."
fi
