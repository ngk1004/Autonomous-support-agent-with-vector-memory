#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
cd "$PROJECT_DIR"

show_logo

echo "This wizard will:"
say "Generate secrets and create your .env file"
say "Start Docker (n8n + Postgres + Qdrant + Ollama)"
say "Wait for services and models to be ready"
say "Configure the demo form for you"
echo ""
warn "You will still need ~10 min in the n8n UI for credentials + Gmail."
echo ""

# --- Prerequisites ---
if ! command -v docker >/dev/null 2>&1; then
  err "Docker is not installed. Install Docker Desktop first."
  exit 1
fi
if ! docker info >/dev/null 2>&1; then
  err "Docker is not running. Start Docker Desktop and retry."
  exit 1
fi
ok "Docker is available"
echo ""

# --- Load existing .env or start fresh ---
if [ -f .env ] && prompt_yes_no "A .env file already exists. Reconfigure?" "n"; then
  load_env
  ok "Using existing .env"
else
  step_art 1 "Configure your environment"
  prompt POSTGRES_PASSWORD "PostgreSQL password (for local dev)" "$(rand_hex 8)"
  prompt WEBHOOK_AUTH_TOKEN "Webhook auth token (demo form uses this)" "demo_$(rand_hex 4)"
  prompt GMAIL_FROM_ADDRESS "Your Gmail address (for sending replies)" "you@gmail.com"
  prompt GENERIC_TIMEZONE "Timezone" "America/New_York"

  echo ""
  say "Where should Ollama run?"
  say "${BOLD}1${NC} Docker Ollama (default, slower first boot)"
  say "${BOLD}2${NC} Native Mac Ollama (faster — install from ollama.com first)"
  prompt OLLAMA_CHOICE "Choose [1/2]" "1"
  local_ollama_host="ollama:11434"
  if [ "$OLLAMA_CHOICE" = "2" ]; then
    local_ollama_host="host.docker.internal:11434"
    warn "Using native Ollama at host.docker.internal:11434"
    say "Make sure you ran: ollama pull llama3.2 && ollama pull nomic-embed-text"
  fi

  write_env_file "$POSTGRES_PASSWORD" "$WEBHOOK_AUTH_TOKEN" "$GMAIL_FROM_ADDRESS" "$GENERIC_TIMEZONE" "$local_ollama_host"
  ok "Created .env"
fi

# Sync dependent files
load_env
update_demo_config "$WEBHOOK_AUTH_TOKEN"
update_postgres_credential "$POSTGRES_PASSWORD"
ok "Updated demo/config.js and postgres credential template"

# --- Docker profile ---
echo ""
PROFILE="cpu"
if prompt_yes_no "Do you have an NVIDIA GPU for Ollama?" "n"; then
  PROFILE="gpu-nvidia"
  say "Using gpu-nvidia profile"
fi

step_art 2 "Start the Docker stack"
docker compose --profile "$PROFILE" up -d

step_art 3 "Wait for services"
wait_for_postgres 30 || true
wait_for_url "http://localhost:5678/healthz" "n8n" 90 || true
wait_for_url "http://localhost:6333/readyz" "Qdrant" 30 || true

if [ "${OLLAMA_HOST:-ollama:11434}" = "ollama:11434" ]; then
  wait_for_ollama_models 25 || true
else
  curl -sf http://localhost:11434/api/tags >/dev/null && ok "Native Ollama reachable" || warn "Start Ollama app on your Mac"
fi

show_complete_art
say "Open n8n:     http://localhost:5678"
say "Credentials:  docs/credentials-setup.md"
say "Run proof:    ./scripts/demo-proof.sh"
say "Full guide:   ./guide"
say "Webhook token: $WEBHOOK_AUTH_TOKEN"
echo ""

if prompt_yes_no "Open n8n in your browser now?" "y"; then
  open_url "http://localhost:5678"
fi
