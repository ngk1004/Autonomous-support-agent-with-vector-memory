#!/usr/bin/env bash
# Interactive help — commands, troubleshooting, architecture, demo tips
# Usage: ./scripts/help.sh  or  ./help
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
cd "$PROJECT_DIR"

# ─── Help topics ───────────────────────────────────────────────────────────────

help_getting_started() {
  show_progress_art
  say "${BOLD}First time here?${NC} Follow this path:"
  echo ""
  say "${CYAN}1.${NC} ${BOLD}./guide${NC}          Interactive walkthrough (recommended)"
  say "${CYAN}2.${NC} Configure n8n credentials  ${DIM}docs/credentials-setup.md${NC}"
  say "${CYAN}3.${NC} Run KB Ingestion workflow  ${DIM}in n8n UI${NC}"
  say "${CYAN}4.${NC} Connect Gmail OAuth        ${DIM}docs/gmail-setup.md${NC}"
  say "${CYAN}5.${NC} Activate Support Agent     ${DIM}toggle in n8n${NC}"
  say "${CYAN}6.${NC} ${BOLD}./scripts/demo-proof.sh${NC}  Prove it works"
  echo ""
  warn "First boot pulls AI models — budget 15-25 minutes on CPU."
  echo ""
  if prompt_yes_no "Launch the interactive guide now?" "n"; then
    exec "$SCRIPT_DIR/guide.sh"
  fi
  press_enter
}

help_commands() {
  show_commands_art
  say "${BOLD}Main commands${NC}  ${DIM}(run from project root)${NC}"
  echo ""
  printf "  ${CYAN}%-28s${NC} %s\n" "./guide" "Interactive setup walkthrough"
  printf "  ${CYAN}%-28s${NC} %s\n" "./help" "This help menu"
  printf "  ${CYAN}%-28s${NC} %s\n" "make guide" "Same as ./guide"
  printf "  ${CYAN}%-28s${NC} %s\n" "make prove" "Test webhook + Postgres end-to-end"
  printf "  ${CYAN}%-28s${NC} %s\n" "make verify" "Health-check all services"
  printf "  ${CYAN}%-28s${NC} %s\n" "make demo" "Serve demo form at :8080"
  printf "  ${CYAN}%-28s${NC} %s\n" "make prewarm" "Warm Ollama models before a demo"
  printf "  ${CYAN}%-28s${NC} %s\n" "make psql" "Open Postgres shell"
  echo ""
  say "${BOLD}Docker${NC}"
  printf "  ${CYAN}%-28s${NC} %s\n" "make up" "Start stack"
  printf "  ${CYAN}%-28s${NC} %s\n" "make down" "Stop stack"
  printf "  ${CYAN}%-28s${NC} %s\n" "make logs" "Follow container logs"
  echo ""
  say "${BOLD}Useful logs${NC}"
  say "docker compose logs -f ollama-init   ${DIM}# model download progress${NC}"
  say "docker compose logs -f n8n         ${DIM}# workflow errors${NC}"
  echo ""
  say "${BOLD}URLs${NC}"
  say "n8n:     http://localhost:5678"
  say "Qdrant:  http://localhost:6333/dashboard"
  say "Demo:    http://localhost:8080  ${DIM}(after make demo)${NC}"
  echo ""
  press_enter
}

help_troubleshoot_pick() {
  show_troubleshoot_art
  menu_item 1 "Docker won't start / not installed"
  menu_item 2 "Ollama models slow or missing"
  menu_item 3 "Webhook returns 404"
  menu_item 4 "Webhook returns 401"
  menu_item 5 "Webhook times out (60s+)"
  menu_item 6 "Empty RAG / bad technical answers"
  menu_item 7 "Gmail not sending"
  menu_item 8 "Embedding / Qdrant errors"
  menu_item 0 "Back to main help menu"
  echo ""
  prompt PICK "Which issue?" "0"

  case "$PICK" in
    1)
      say "${BOLD}Docker not running${NC}"
      say "Install Docker Desktop: https://www.docker.com/products/docker-desktop/"
      say "Start the app, wait for the whale icon, then: ${CYAN}make up${NC}"
      ;;
    2)
      say "${BOLD}Ollama models${NC}"
      say "Watch pull progress: ${CYAN}docker compose logs -f ollama-init${NC}"
      say "Need llama3.2 + nomic-embed-text"
      say "Mac native (faster): set OLLAMA_HOST=host.docker.internal:11434 in .env"
      say "Then: ollama pull llama3.2 && ollama pull nomic-embed-text"
      ;;
    3)
      say "${BOLD}Webhook 404${NC}"
      say "Workflow '02 - Support Agent' must be ${BOLD}Active${NC} in n8n (green toggle)"
      say "URL must be: http://localhost:5678/webhook/support-inquiry"
      ;;
    4)
      say "${BOLD}Webhook 401${NC}"
      say "Token in demo/config.js must match WEBHOOK_AUTH_TOKEN in .env"
      say "Re-run ${CYAN}./guide${NC} step 1 or edit both files manually"
      ;;
    5)
      say "${BOLD}Webhook timeout${NC}"
      say "Normal on CPU — first request can take 60-90 seconds"
      say "Run ${CYAN}make prewarm${NC} before demos"
      say "Check n8n Executions tab for the running workflow"
      ;;
    6)
      say "${BOLD}Empty RAG${NC}"
      say "Run workflow '01 - KB Ingestion' in n8n"
      say "Verify: curl http://localhost:6333/collections/support_kb"
      say "Assign Qdrant + Embeddings credentials on ingestion workflow nodes"
      ;;
    7)
      say "${BOLD}Gmail${NC}"
      say "See docs/gmail-setup.md for OAuth setup"
      say "Re-auth in n8n Credentials if token expired"
      say "Check spam folder; verify Gmail node has credential assigned"
      ;;
    8)
      say "${BOLD}Embeddings / Qdrant${NC}"
      say "Use ${BOLD}Embeddings OpenAI${NC} node pointed at http://ollama:11434/v1"
      say "Set dimensions to ${BOLD}768${NC} for nomic-embed-text"
      say "Do NOT use native Embeddings Ollama node (known bug)"
      ;;
    *)
      return
      ;;
  esac
  echo ""
  if prompt_yes_no "Run health check now?" "y"; then
    "$SCRIPT_DIR/verify-stack.sh" || true
  fi
  press_enter
}

help_architecture() {
  show_architecture_art
  say "${BOLD}Flow${NC}"
  echo ""
  say "  Demo form  -->  Webhook  -->  Intent LLM  -->  Switch"
  say "                                    |"
  say "                    +---------------+---------------+"
  say "                    v               v               v"
  say "               Billing Agent   Technical Agent   Feature LLM"
  say "               + Qdrant RAG    + Qdrant RAG"
  say "                    |               |               |"
  say "                    +-------+-------+-------+---------+"
  say "                            v"
  say "                      Gmail send"
  say "                            v"
  say "                   Postgres audit log"
  echo ""
  say "${BOLD}Stack${NC}"
  say "  n8n        workflow orchestration"
  say "  Ollama     llama3.2 (chat) + nomic-embed-text (embeddings)"
  say "  Qdrant     vector store for RAG"
  say "  Postgres   n8n data + support_interactions audit table"
  say "  Gmail      outbound customer replies"
  echo ""
  say "${BOLD}Workflows${NC}"
  say "  01 - KB Ingestion     seed Qdrant from knowledge-base/"
  say "  02 - Support Agent    main webhook pipeline"
  say "  03 - Error Handler    logs failures to Postgres"
  echo ""
  press_enter
}

help_demo() {
  show_demo_art
  say "${BOLD}5-minute demo script${NC}"
  echo ""
  say "${CYAN}1.${NC} ${BOLD}make prewarm${NC}              Warm models before the call"
  say "${CYAN}2.${NC} ${BOLD}make demo${NC}                 Open http://localhost:8080"
  say "${CYAN}3.${NC} Click ${BOLD}Technical Support${NC} preset → Submit"
  say "${CYAN}4.${NC} Show n8n ${BOLD}Executions${NC} tab → AI Agent + Qdrant tool"
  say "${CYAN}5.${NC} Show Gmail inbox → HTML reply"
  say "${CYAN}6.${NC} ${BOLD}make psql${NC} → SELECT * FROM support_interactions LIMIT 3;"
  echo ""
  say "Full checklist: ${DIM}docs/demo-checklist.md${NC}"
  echo ""
  if prompt_yes_no "Run demo proof test now?" "n"; then
    "$SCRIPT_DIR/demo-proof.sh" || true
  fi
  if prompt_yes_no "Start demo web server?" "n"; then
    exec "$SCRIPT_DIR/serve-demo.sh"
  fi
  press_enter
}

help_docs() {
  echo ""
  echo -e "${BLUE}${BOLD}"
  cat <<'ART'
      ____  ___  ____ ____
     |  _ \|_ _|/ ___| __ )
     | | | || || |   |  _ \
     | |_| || || |___| |_) |
     |____/|___|\____|____/
ART
  echo -e "${NC}"
  menu_item 1 "README.md"
  menu_item 2 "docs/credentials-setup.md"
  menu_item 3 "docs/gmail-setup.md"
  menu_item 4 "docs/demo-checklist.md"
  menu_item 0 "Back"
  echo ""
  prompt DOC "Which doc to open?" "0"
  local f=""
  case "$DOC" in
    1) f="README.md" ;;
    2) f="docs/credentials-setup.md" ;;
    3) f="docs/gmail-setup.md" ;;
    4) f="docs/demo-checklist.md" ;;
    *) return ;;
  esac
  if [ -f "$f" ]; then
    echo ""
    less "$f" 2>/dev/null || cat "$f"
  fi
  press_enter
}

help_status() {
  show_progress_art
  detect_progress() {
    HAS_ENV=0; HAS_DOCKER=0; HAS_N8N=0; HAS_MODELS=0; HAS_KB=0; HAS_WEBHOOK=0
    [ -f .env ] && HAS_ENV=1
    check_docker && HAS_DOCKER=1 || true
    check_n8n && HAS_N8N=1 || true
    check_ollama_models && HAS_MODELS=1 || true
    check_qdrant_seeded && HAS_KB=1 || true
    check_webhook && HAS_WEBHOOK=1 || true
  }
  detect_progress
  local done_count=$((HAS_ENV + HAS_DOCKER + HAS_N8N + HAS_MODELS + HAS_KB + HAS_WEBHOOK))
  show_progress_bar "$done_count" 6
  echo ""
  [ "$HAS_ENV" = "1" ] && ok ".env configured" || warn ".env missing — run ./guide"
  [ "$HAS_DOCKER" = "1" ] && ok "Docker running" || warn "Docker not running"
  [ "$HAS_N8N" = "1" ] && ok "n8n reachable" || warn "n8n not up"
  [ "$HAS_MODELS" = "1" ] && ok "Ollama models ready" || warn "Ollama models not ready"
  [ "$HAS_KB" = "1" ] && ok "Knowledge base ingested" || warn "KB not ingested"
  [ "$HAS_WEBHOOK" = "1" ] && ok "Webhook active" || warn "Webhook not active"
  echo ""
  press_enter
}

# ─── Main menu ────────────────────────────────────────────────────────────────

main_help_menu() {
  while true; do
    clear 2>/dev/null || true
    show_logo
    show_help_art
    menu_item 1 "Getting started          ${DIM}first-time setup path${NC}"
    menu_item 2 "Commands reference       ${DIM}all terminal commands${NC}"
    menu_item 3 "Troubleshooting          ${DIM}fix common issues${NC}"
    menu_item 4 "Architecture             ${DIM}how it works${NC}"
    menu_item 5 "Demo tips                ${DIM}show this to someone${NC}"
    menu_item 6 "Check my status          ${DIM}what's done vs missing${NC}"
    menu_item 7 "Read documentation       ${DIM}open project docs${NC}"
    menu_item 8 "Launch setup guide       ${DIM}./guide${NC}"
    menu_item 9 "Run proof test           ${DIM}demo-proof.sh${NC}"
    menu_item 0 "Exit"
    echo ""
    prompt CHOICE "What do you need help with?" "1"

    case "$CHOICE" in
      1) help_getting_started ;;
      2) help_commands ;;
      3) help_troubleshoot_pick ;;
      4) help_architecture ;;
      5) help_demo ;;
      6) help_status ;;
      7) help_docs ;;
      8) exec "$SCRIPT_DIR/guide.sh" ;;
      9) "$SCRIPT_DIR/demo-proof.sh" || true; press_enter ;;
      0|q|quit|exit) show_goodbye_art; exit 0 ;;
      *) warn "Pick a number from the menu"; sleep 1 ;;
    esac
  done
}

# ─── Entry ────────────────────────────────────────────────────────────────────

# Quick mode: ./help commands | ./help troubleshoot | ./help status
if [ "${1:-}" != "" ]; then
  case "$1" in
    start|getting-started) help_getting_started; exit 0 ;;
    commands|cmds)         help_commands; exit 0 ;;
    troubleshoot|fix)      help_troubleshoot_pick; exit 0 ;;
    architecture|arch)     help_architecture; exit 0 ;;
    demo)                  help_demo; exit 0 ;;
    status)                help_status; exit 0 ;;
    docs)                  help_docs; exit 0 ;;
    guide)                 exec "$SCRIPT_DIR/guide.sh" ;;
    prove|proof)           exec "$SCRIPT_DIR/demo-proof.sh" ;;
    *)
      show_help_art
      say "Unknown topic: $1"
      say "Topics: start, commands, troubleshoot, architecture, demo, status, docs, guide, prove"
      exit 1
      ;;
  esac
fi

main_help_menu
