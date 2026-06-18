#!/usr/bin/env bash
set -euo pipefail

echo "=== Pre-warm Demo ==="
echo ""

# Check Ollama models
if curl -sf http://localhost:11434/api/tags >/dev/null 2>&1; then
  echo "Warming Ollama models..."
  curl -sf http://localhost:11434/api/generate -d '{"model":"llama3.2","prompt":"hi","stream":false}' >/dev/null && echo "  llama3.2: warm"
  curl -sf http://localhost:11434/api/embeddings -d '{"model":"nomic-embed-text","prompt":"warmup"}' >/dev/null && echo "  nomic-embed-text: warm"
else
  echo "Ollama not reachable at localhost:11434"
  echo "  If using Docker: docker compose logs ollama"
  echo "  If using native Mac Ollama: ensure it is running"
fi

echo ""
echo "Checking services..."
curl -sf http://localhost:5678/healthz >/dev/null && echo "  n8n: OK" || echo "  n8n: NOT READY"
curl -sf http://localhost:6333/collections >/dev/null && echo "  Qdrant: OK" || echo "  Qdrant: NOT READY"

if curl -sf http://localhost:6333/collections/support_kb >/dev/null 2>&1; then
  echo "  support_kb collection: EXISTS"
else
  echo "  support_kb collection: MISSING — run KB Ingestion workflow"
fi

echo ""
echo "Pre-warm complete. Run demo scenarios from demo/index.html"
