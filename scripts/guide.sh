#!/usr/bin/env bash
# Interactive guided setup — walk through the full project step by step.
# Usage: ./scripts/guide.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
cd "$PROJECT_DIR"

TOTAL_STEPS=10

# ─── Progress detection ───────────────────────────────────────────────────────

detect_progress() {
  HAS_ENV=0; HAS_DOCKER=0; HAS_N8N=0; HAS_MODELS=0; HAS_KB=0; HAS_WEBHOOK=0
  [ -f .env ] && HAS_ENV=1
  check_docker && HAS_DOCKER=1 || true
  check_n8n && HAS_N8N=1 || true
  check_ollama_models && HAS_MODELS=1 || true
  check_qdrant_seeded && HAS_KB=1 || true
  check_webhook && HAS_WEBHOOK=1 || true
}

show_dashboard() {
  detect_progress
  show_progress_art

  local done_count=$((HAS_ENV + HAS_DOCKER + HAS_N8N + HAS_MODELS + HAS_KB + HAS_WEBHOOK))
  show_progress_bar "$done_count" 6
  echo ""

  status_line() {
    local label="$1" done="$2"
    if [ "$done" = "1" ]; then
      echo -e "  ${GREEN}(@)${NC} ${GREEN}+${NC} $label"
    else
      echo -e "  ${DIM}( )${NC} ${YELLOW}*${NC} $label"
    fi
  }
  status_line "Configuration (.env)" "$HAS_ENV"
  status_line "Docker stack running" "$HAS_DOCKER"
  status_line "n8n reachable" "$HAS_N8N"
  status_line "Ollama models ready" "$HAS_MODELS"
  status_line "Knowledge base ingested" "$HAS_KB"
  status_line "Support agent webhook active" "$HAS_WEBHOOK"
  echo ""
  if [ "$HAS_WEBHOOK" = "1" ]; then
    ok "You're ready to demo! Run proof or serve the demo form."
  elif [ "$HAS_ENV" = "1" ] && [ "$HAS_N8N" = "1" ]; then
    say "Almost there — finish n8n credentials, ingestion, and activation."
  else
    say "Let's get started — I'll guide you through each step."
  fi
  echo ""
}

first_incomplete_step() {
  detect_progress
  [ "$HAS_ENV" = "0" ] && { echo 1; return; }
  if [ "$HAS_DOCKER" = "0" ] || [ "$HAS_N8N" = "0" ]; then echo 2; return; fi
  [ "$HAS_MODELS" = "0" ] && { echo 3; return; }
  if [ "$HAS_WEBHOOK" = "1" ]; then echo 9; return; fi
  [ "$HAS_KB" = "0" ] && { echo 6; return; }
  echo 8
}

# ─── Steps ────────────────────────────────────────────────────────────────────

step_1_configure() {
  step_header 1 "Configure your environment"
  say "We'll create a .env file with passwords and secrets."
  say "Nothing is sent anywhere — everything runs locally on your machine."
  echo ""

  if [ -f .env ] && prompt_yes_no "A .env file already exists. Reconfigure?" "n"; then
    load_env
    ok "Using existing .env"
    press_enter
    return
  fi

  prompt POSTGRES_PASSWORD "PostgreSQL password" "$(rand_hex 8)"
  prompt WEBHOOK_AUTH_TOKEN "Webhook token (demo form sends this header)" "demo_$(rand_hex 4)"
  prompt GMAIL_FROM_ADDRESS "Gmail address for outbound replies" "you@gmail.com"
  prompt GENERIC_TIMEZONE "Timezone" "America/New_York"

  echo ""
  say "Where should Ollama run?"
  say "  ${BOLD}1${NC} Docker (default — slower first boot, fully self-contained)"
  say "  ${BOLD}2${NC} Native Mac app (faster — install from https://ollama.com first)"
  prompt OLLAMA_CHOICE "Choose 1 or 2" "1"

  local ollama_host="ollama:11434"
  if [ "$OLLAMA_CHOICE" = "2" ]; then
    ollama_host="host.docker.internal:11434"
    warn "Using native Ollama. Before continuing, run in another terminal:"
    say "  ollama pull llama3.2"
    say "  ollama pull nomic-embed-text"
    press_enter "Press Enter when native Ollama is installed (or skip if not using option 2)"
  fi

  write_env_file "$POSTGRES_PASSWORD" "$WEBHOOK_AUTH_TOKEN" "$GMAIL_FROM_ADDRESS" "$GENERIC_TIMEZONE" "$ollama_host"
  load_env
  update_demo_config "$WEBHOOK_AUTH_TOKEN"
  update_postgres_credential "$POSTGRES_PASSWORD"
  ok "Created .env, demo/config.js, and synced Postgres credential template"
  echo ""
  say "Your webhook token: ${BOLD}${WEBHOOK_AUTH_TOKEN}${NC}"
  press_enter
}

step_2_docker() {
  step_header 2 "Start the Docker stack"
  if check_n8n && check_docker; then
    ok "Docker stack already appears to be running"
    if ! prompt_yes_no "Restart containers anyway?" "n"; then
      press_enter
      return
    fi
  fi
  say "This starts: n8n, PostgreSQL, Qdrant, and Ollama."
  say "First boot downloads AI models — expect 10–20 minutes on CPU."
  echo ""

  if ! check_docker; then
    err "Docker is not running."
    say "Install Docker Desktop: https://www.docker.com/products/docker-desktop/"
    say "Start Docker Desktop, then press Enter."
    press_enter
    check_docker || { err "Docker still not available. Exiting."; exit 1; }
  fi
  ok "Docker is running"

  load_env || { err "No .env — run Step 1 first"; return 1; }

  local profile="cpu"
  if prompt_yes_no "Do you have an NVIDIA GPU?" "n"; then
    profile="gpu-nvidia"
    say "Using GPU profile for faster Ollama inference."
  fi

  echo ""
  say "Starting containers..."
  docker compose --profile "$profile" up -d
  ok "Docker stack started"
  press_enter
}

step_3_wait_services() {
  step_header 3 "Wait for services & AI models"
  say "I'll check Postgres, n8n, Qdrant, and Ollama for you."
  echo ""

  wait_for_postgres 45 || warn "Postgres slow — may still be starting"
  wait_for_url "http://localhost:5678/healthz" "n8n" 120 || warn "n8n slow — check: docker compose logs n8n"
  wait_for_url "http://localhost:6333/readyz" "Qdrant" 45 || true

  load_env
  if [ "${OLLAMA_HOST:-ollama:11434}" = "ollama:11434" ]; then
    say "Pulling llama3.2 and nomic-embed-text — grab coffee, this takes a while."
    say "Watch progress: docker compose logs -f ollama-init"
    wait_for_ollama_models 30 || warn "Models not ready yet — continue and check logs later"
  else
    if check_ollama_models; then ok "Native Ollama models ready"
    else warn "Pull models: ollama pull llama3.2 && ollama pull nomic-embed-text"
    fi
  fi

  echo ""
  ok "Service URLs:"
  say "  n8n:    http://localhost:5678"
  say "  Qdrant: http://localhost:6333/dashboard"
  press_enter
}

step_4_n8n_account() {
  step_header 4 "Create your n8n account"
  say "On first visit, n8n asks you to create an owner account."
  say "This is local only — stored in your Docker volume."
  echo ""

  if prompt_yes_no "Open n8n in your browser now?" "y"; then
    open_url "http://localhost:5678"
  else
    say "Open manually: http://localhost:5678"
  fi

  echo ""
  say "In the browser:"
  say "  1. Enter your name, email, and password"
  say "  2. Complete the setup wizard"
  say "  3. You should see the n8n workflow editor"
  echo ""
  press_enter "Press Enter when you can see the n8n workflow list"
}

step_5_credentials() {
  step_header 5 "Configure n8n credentials"
  load_env || { err "No .env"; return 1; }

  say "Credentials tell n8n how to reach Ollama, Qdrant, Postgres, and Gmail."
  say "In n8n: left sidebar → ${BOLD}Credentials${NC} → ${BOLD}Add credential${NC}"
  echo ""

  if prompt_yes_no "Open the credentials setup doc?" "y"; then
    if [ -f docs/credentials-setup.md ]; then
      less docs/credentials-setup.md 2>/dev/null || cat docs/credentials-setup.md
    fi
  fi

  echo ""
  echo -e "${BOLD}Create these 5 credentials:${NC}"
  echo ""
  say "${BOLD}① Ollama Local${NC} (type: Ollama)"
  say "   Base URL: http://ollama:11434"
  if [ "${OLLAMA_HOST:-}" = "host.docker.internal:11434" ]; then
    say "   (or http://host.docker.internal:11434 if using native Ollama)"
  fi
  echo ""
  say "${BOLD}② Ollama OpenAI Compatible${NC} (type: OpenAI)"
  say "   Base URL: http://ollama:11434/v1"
  say "   API Key: ollama"
  echo ""
  say "${BOLD}③ Qdrant Local${NC} (type: Qdrant)"
  say "   URL: http://qdrant:6333"
  echo ""
  say "${BOLD}④ Support Agent Postgres${NC} (type: Postgres)"
  say "   Host: postgres | Port: 5432 | DB: support_agent"
  say "   User: support_agent | Password: ${BOLD}${POSTGRES_PASSWORD}${NC}"
  echo ""
  say "${BOLD}⑤ Gmail OAuth2${NC} — we'll do this in Step 7"
  echo ""
  say "Then open each workflow and assign credentials to every node that shows a warning."
  echo ""
  press_enter "Press Enter when all 4 credentials are created (Gmail comes next)"
}

step_6_ingestion() {
  step_header 6 "Ingest the knowledge base"
  say "This embeds 15 support articles into Qdrant for RAG search."
  say "The AI agent uses these docs to answer technical & billing questions."
  echo ""

  if check_qdrant_seeded; then
    ok "Qdrant already has vectors — ingestion may already be done"
    if ! prompt_yes_no "Re-run ingestion anyway?" "n"; then
      press_enter
      return
    fi
  fi

  if prompt_yes_no "Open n8n workflows?" "y"; then
    open_url "http://localhost:5678"
  fi

  echo ""
  say "In n8n:"
  say "  1. Open workflow ${BOLD}01 - KB Ingestion${NC}"
  say "  2. Click each node with a ⚠️ and select the right credential:"
  say "     • Qdrant Insert → Qdrant Local"
  say "     • Embeddings OpenAI (Ollama) → Ollama OpenAI Compatible"
  say "  3. Click ${BOLD}Execute workflow${NC} (play button, top right)"
  say "  4. Wait 1–3 minutes for completion (green checkmarks)"
  echo ""

  if prompt_yes_no "Wait here while I check Qdrant for you?" "y"; then
    say "Checking every 10s (Ctrl+C to skip)..."
    for _ in $(seq 1 30); do
      if check_qdrant_seeded; then
        local pts
        pts=$(curl -sf http://localhost:6333/collections/support_kb | python3 -c "import sys,json; print(json.load(sys.stdin).get('result',{}).get('points_count',0))" 2>/dev/null)
        ok "Ingestion complete — $pts vectors in support_kb"
        press_enter
        return
      fi
      sleep 10
      echo -n "."
    done
    echo ""
    warn "Vectors not detected yet — finish executing the workflow in n8n"
  fi
  press_enter
}

step_7_gmail() {
  step_header 7 "Connect Gmail (OAuth)"
  say "Gmail sends the automated reply emails to customers."
  say "Google requires a one-time OAuth setup in their developer console."
  echo ""

  if [ -f docs/gmail-setup.md ]; then
    say "Full guide: docs/gmail-setup.md"
    if prompt_yes_no "Show Gmail setup instructions now?" "y"; then
      less docs/gmail-setup.md 2>/dev/null || cat docs/gmail-setup.md
    fi
  fi

  echo ""
  say "${BOLD}Quick version:${NC}"
  say "  1. Google Cloud Console → create project → enable Gmail API"
  say "  2. OAuth consent screen → add yourself as test user"
  say "  3. Create OAuth Client ID (Web) → redirect URI:"
  say "     http://localhost:5678/rest/oauth2-credential/callback"
  say "  4. In n8n Credentials → Gmail OAuth2 → paste Client ID/Secret → Sign in"
  say "  5. In workflow 02 → Gmail Send node → select Gmail OAuth2 credential"
  echo ""
  load_env
  say "Replies will be sent to the customer email in each inquiry."
  say "Your Gmail (${GMAIL_FROM_ADDRESS:-you@gmail.com}) is the sender."
  echo ""
  press_enter "Press Enter when Gmail is connected in n8n"
}

step_8_activate() {
  step_header 8 "Activate the Support Agent"
  say "Activating the workflow registers the webhook so the demo form can reach it."
  echo ""

  if prompt_yes_no "Open n8n?" "y"; then
    open_url "http://localhost:5678"
  fi

  echo ""
  say "In n8n:"
  say "  1. Open ${BOLD}02 - Support Agent${NC}"
  say "  2. Assign credentials on any node still showing ⚠️"
  say "  3. Toggle ${BOLD}Active${NC} (top right) — must turn green"
  say "  4. Open ${BOLD}03 - Error Handler${NC} → toggle Active"
  say "  5. Back in 02 → ⋯ menu → Settings → Error Workflow → 03 - Error Handler"
  echo ""
  say "Copy the production webhook URL (shown on the Webhook node):"
  say "  http://localhost:5678/webhook/support-inquiry"
  echo ""

  if prompt_yes_no "Test webhook now (sends a real inquiry — may take 60s on CPU)?" "y"; then
    load_env
    say "Sending test inquiry..."
    local code
    code=$(curl -s -o /tmp/guide-webhook.json -w "%{http_code}" \
      -X POST "http://localhost:5678/webhook/support-inquiry" \
      -H "Content-Type: application/json" \
      -H "X-Webhook-Token: ${WEBHOOK_AUTH_TOKEN:-}" \
      -d '{"customer_name":"Guide Test","customer_email":"'"${GMAIL_FROM_ADDRESS:-test@example.com}"'","subject":"Test","message":"API returns 401 invalid_api_key"}' \
      --max-time 300 || echo "000")
    if [ "$code" = "200" ]; then
      ok "Webhook returned 200 — it's working!"
      python3 -m json.tool /tmp/guide-webhook.json 2>/dev/null | head -15
    elif [ "$code" = "404" ]; then
      warn "404 — workflow not active yet. Toggle Active and retry."
    else
      warn "HTTP $code — check n8n Executions tab for errors"
    fi
  fi
  press_enter
}

step_9_proof() {
  step_header 9 "Prove it works"
  say "Running the full proof script — infra, RAG, webhook, and Postgres."
  echo ""
  press_enter "Press Enter to run demo-proof.sh"
  "$SCRIPT_DIR/demo-proof.sh" || true
  press_enter
}

step_10_demo() {
  step_header 10 "Run the live demo"
  say "You're ready to show this to someone!"
  echo ""
  say "${BOLD}Option A — Demo form (visual)${NC}"
  say "  ./scripts/serve-demo.sh"
  say "  Open http://localhost:8080 → click a preset → Submit"
  echo ""
  say "${BOLD}Option B — Terminal proof${NC}"
  say "  ./scripts/demo-proof.sh"
  echo ""
  say "${BOLD}Option C — Show the n8n graph${NC}"
  say "  http://localhost:5678 → Executions → click latest run"
  say "  Point out: Switch branches, AI Agent tool calls, Qdrant retrieval"
  echo ""
  say "Demo checklist: docs/demo-checklist.md"
  echo ""

  if prompt_yes_no "Start the demo web server now?" "y"; then
    say "Starting server on http://localhost:8080 (Ctrl+C to stop)"
  exec "$SCRIPT_DIR/serve-demo.sh"
  fi
}

run_step() {
  case "$1" in
    1) step_1_configure ;;
    2) step_2_docker ;;
    3) step_3_wait_services ;;
    4) step_4_n8n_account ;;
    5) step_5_credentials ;;
    6) step_6_ingestion ;;
    7) step_7_gmail ;;
    8) step_8_activate ;;
    9) step_9_proof ;;
    10) step_10_demo ;;
  esac
}

# ─── Main menu ────────────────────────────────────────────────────────────────

main_menu() {
  while true; do
    show_dashboard
    show_menu_art
    menu_item 1 "Guided setup — walk through all steps ${DIM}(recommended)${NC}"
    menu_item 2 "Jump to a specific step"
    menu_item 3 "Run proof — test that everything works"
    menu_item 4 "Start demo web server"
    menu_item 5 "Troubleshoot / view logs"
    menu_item 6 "Exit"
    echo ""
    prompt CHOICE "Choose" "1"

    case "$CHOICE" in
      1)
        local start
        start=$(first_incomplete_step)
        say "Starting from step $start..."
        for s in $(seq "$start" "$TOTAL_STEPS"); do
          run_step "$s" || true
        done
        show_complete_art
        say "Run ./scripts/demo-proof.sh anytime to verify."
        ;;
      2)
        echo ""
        echo "  1=Configure  2=Docker  3=Wait  4=n8n account  5=Credentials"
        echo "  6=Ingest KB  7=Gmail  8=Activate  9=Proof  10=Demo"
        prompt JUMP "Step number" "1"
        run_step "$JUMP" || true
        ;;
      3)
        "$SCRIPT_DIR/demo-proof.sh" || true
        press_enter
        ;;
      4)
        exec "$SCRIPT_DIR/serve-demo.sh"
        ;;
      5)
        echo ""
        say "Common fixes:"
        say "  docker compose logs -f ollama-init   # model pull progress"
        say "  docker compose logs -f n8n         # n8n errors"
        say "  ./scripts/verify-stack.sh          # health check"
        say "  docs/demo-checklist.md             # demo day checklist"
        echo ""
        if prompt_yes_no "Run verify-stack.sh now?" "y"; then
          "$SCRIPT_DIR/verify-stack.sh" || true
        fi
        press_enter
        ;;
      6|q|quit|exit)
        show_goodbye_art
        exit 0
        ;;
      *)
        warn "Invalid choice"
        ;;
    esac
  done
}

# ─── Entry ────────────────────────────────────────────────────────────────────

clear 2>/dev/null || true
show_logo
say "I'll walk you through setup step by step, like a pairing session."
say "You run the commands; I tell you what to do and check your progress."
say "github.com/ngk1004/Autonomous-support-agent-with-vector-memory"
echo ""

if ! command -v python3 >/dev/null 2>&1; then
  err "python3 is required. Install Python 3 and retry."
  exit 1
fi

main_menu
