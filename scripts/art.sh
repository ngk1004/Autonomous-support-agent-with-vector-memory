#!/usr/bin/env bash
# ASCII character art + colors for the interactive guide
# shellcheck shell=bash

# Colors
BOLD='\033[1m'
DIM='\033[2m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
WHITE='\033[1;37m'
PURPLE='\033[0;35m'
NC='\033[0m'

show_logo() {
  echo ""
  echo -e "${CYAN}${BOLD}"
  cat <<'ART'
       ___         _                         _
      / _ \       | |                       | |
     / /_\ \ _   _| |_ ___  _ __   ___ _ __ | |_
     |  _  || | | | __/ _ \| '_ \ / _ \ '_ \| __|
     | | | || |_| | || (_) | | | |  __/ | | | |_
     \_| |_/ \__,_|\__\___/|_| |_|\___|_| |_|\__|
ART
  echo -e "${NC}"
  echo -e "  ${MAGENTA}*${NC} ${WHITE}${BOLD}AUTONOMOUS SUPPORT AGENT${NC}  ${DIM}with${NC}  ${CYAN}VECTOR MEMORY${NC}"
  echo -e "  ${DIM}n8n  +  Ollama  +  Qdrant  +  Postgres  +  Gmail${NC}"
  echo ""
  echo -e "  ${YELLOW}@${NC} ${DIM}Interactive setup guide — I'll walk you through every step${NC}"
  echo ""
}

show_progress_art() {
  echo ""
  echo -e "${BLUE}${BOLD}"
  cat <<'ART'
      ____  ____   ___  ____  _____ ____ _____
     |  _ \|  _ \ / _ \|  _ \| ____/ ___|_   _|
     | |_) | |_) | | | | | | |  _| \___ \ | |
     |  __/|  __/| |_| | |_| | |___ ___) || |
     |_|   |_|    \___/|____/|_____|____/ |_|
ART
  echo -e "${NC}${DIM}     your setup checklist${NC}"
  echo ""
}

show_menu_art() {
  echo ""
  echo -e "${MAGENTA}${BOLD}"
  cat <<'ART'
     __  __
    |  \/  | ___ _ __  _   _
    | |\/| |/ _ \ '_ \| | | |
    | |  | |  __/ | | | |_| |
    |_|  |_|\___|_| |_|\__,_|
ART
  echo -e "${NC}${DIM}     what would you like to do?${NC}"
  echo ""
}

show_complete_art() {
  echo ""
  echo -e "${GREEN}${BOLD}"
  cat <<'ART'
      ____ ___  __  __ ____   ___  _   _  ____
     / ___/ _ \|  \/  |  _ \ / _ \| | | |/ ___|
    | |  | | | | |\/| | |_) | | | | | | | |
    | |__| |_| | |  | |  __/| |_| | |_| | |___
     \____\___/|_|  |_|_|    \___/ \___/ \____|
ART
  echo -e "${NC}"
  echo -e "  ${GREEN}*${NC} ${BOLD}You're ready to demo this project.${NC}"
  echo ""
}

show_goodbye_art() {
  echo ""
  echo -e "${CYAN}"
  cat <<'ART'
      ____                 _ _ 
     / ___| ___  ___ _   _| | |
    | |  _ / _ \/ __| | | | | |
    | |_| |  __/\__ \ |_| | | |
     \____|\___||___/\__,_|_|_|
ART
  echo -e "${NC}"
  echo -e "  ${DIM}Need help later?${NC}  ${CYAN}./help${NC}  ${DIM}|${NC}  ${CYAN}./guide${NC}"
  echo ""
}

show_help_art() {
  echo ""
  echo -e "${YELLOW}${BOLD}"
  cat <<'ART'
      _   _      _ _     
     | | | | ___| | | ___
     | |_| |/ _ \ | |/ _ \
     |  _  |  __/ | | (_) |
     |_| |_|\___|_|_|\___/
ART
  echo -e "${NC}${DIM}     interactive help center${NC}"
  echo ""
}

show_commands_art() {
  echo ""
  echo -e "${BLUE}${BOLD}"
  cat <<'ART'
       ____                                          _
      / ___|___  _ __ ___  _ __ ___   __ _ ___  ___| |_
     | |   / _ \| '__/ _ \| '_ ` _ \ / _` / __|/ _ \ __|
     | |__| (_) | | | (_) | | | | | | (_| \__ \  __/ |_
      \____\___/|_|  \___/|_| |_| |_|\__,_|___/\___|\__|
ART
  echo -e "${NC}${DIM}     terminal commands${NC}"
  echo ""
}

show_troubleshoot_art() {
  echo ""
  echo -e "${RED}${BOLD}"
  cat <<'ART'
      _____ ____  _   _ _   _ _   _ ____  _   _ ____ _____
     |_   _|  _ \| | | | | | | | | |  _ \| | | / ___| ____|
       | | | |_) | | | | | | | |_| | |_) | | | \___ \  _|
       | | |  _ <| |_| | |_| |  _  |  __/| |_| |___) | |___
       |_| |_| \_\\___/ \___/|_| |_|_|    \___/|____/|_____|
ART
  echo -e "${NC}${DIM}     fix common issues${NC}"
  echo ""
}

show_architecture_art() {
  echo ""
  echo -e "${MAGENTA}${BOLD}"
  cat <<'ART'
        _   _   _    _  _    ___ _   _  ____ _____
       / \ | | | |  / \| |  |_ _| \ | |/ ___| ____|
      / _ \| |_| | / _ \ |   | ||  \| | |  _|  _|
     / ___ \  _  |/ ___ \ |___| || |\  | |_| | |___
    /_/   \_\_| |_/_/   \_\____|___|_| \_|\____|_____|
ART
  echo -e "${NC}${DIM}     how the system fits together${NC}"
  echo ""
}

show_demo_art() {
  echo ""
  echo -e "${GREEN}${BOLD}"
  cat <<'ART'
      ____  _____ __  __  ___ 
     |  _ \| ____|  \/  |/ _ \
     | | | |  _| | |\/| | | | |
     | |_| | |___| |  | | |_| |
     |____/|_____|_|  |_|\___/
ART
  echo -e "${NC}${DIM}     show this to someone${NC}"
  echo ""
}

# Step-specific mini art (character figures, not box lines)
step_art() {
  local num="$1"
  local title="$2"
  echo ""
  case "$num" in
    1)
      echo -e "${YELLOW}${BOLD}"
      cat <<'ART'
       _____      _ ____
      / ____|    | |___ \
     | |    _   _| | __) |
     | |   | | | | ||__ <
     | |___| |_| | |___) |
      \_____\__,_|_|____/
ART
      ;;
    2)
      echo -e "${BLUE}${BOLD}"
      cat <<'ART'
      ____            _
     |  _ \  ___   __| | _____      __
     | | | |/ _ \ / _` |/ _ \ \ /\ / /
     | |_| | (_) | (_| | (_) \ V  V /
     |____/ \___/ \__,_|\___/ \_/\_/
ART
      ;;
    3)
      echo -e "${CYAN}${BOLD}"
      cat <<'ART'
      __        __         _     _
      \ \      / /__  _ __| | __| |
       \ \ /\ / / _ \| '__| |/ _` |
        \ V  V / (_) | |  | | (_| |
         \_/\_/ \___/|_|  |_|\__,_|
ART
      ;;
    4)
      echo -e "${MAGENTA}${BOLD}"
      cat <<'ART'
      _   _  ____    _    _
     | \ | |/ ___|  / \  | |
     |  \| | |  _  / _ \ | |
     | |\  | |_| |/ ___ \| |___
     |_| \_|\____/_/   \_\_____|
ART
      ;;
    5)
      echo -e "${GREEN}${BOLD}"
      cat <<'ART'
       ____            _       _   _
      / ___|___  _ __ | |_ ___| |_(_) ___  _ __
     | |   / _ \| '_ \| __/ _ \ __| |/ _ \| '_ \
     | |__| (_) | | | | ||  __/ |_| | (_) | | | |
      \____\___/|_| |_|\__\___|\__|_|\___/|_| |_|
ART
      ;;
    6)
      echo -e "${PURPLE}${BOLD}"
      cat <<'ART'
      _  ___    _    ____
     | |/ / |  / \  | __ )
     | ' /| | / _ \ |  _ \
     | . \| |_| ___ \| |_) |
     |_|\_\__/_/   \_\____/
ART
      ;;
    7)
      echo -e "${RED}${BOLD}"
      cat <<'ART'
      ____                 _
     / ___|_ __ ___  __ _| | ___
    | |  _| '__/ _ \/ _` | |/ _ \
    | |_| | | |  __/ (_| | |  __/
     \____|_|  \___|\__,_|_|\___|
ART
      ;;
    8)
      echo -e "${GREEN}${BOLD}"
      cat <<'ART'
      __        __   _     _
      \ \      / /__| |__ | | _____
       \ \ /\ / / _ \ '_ \| |/ / __|
        \ V  V /  __/ |_) |   <\__ \
         \_/\_/ \___|_.__/|_|\_\___/
ART
      ;;
    9)
      echo -e "${CYAN}${BOLD}"
      cat <<'ART'
      ____  ____   ___  ____  _____
     |  _ \|  _ \ / _ \|  _ \| ____|
     | |_) | |_) | | | | | | |  _|
     |  __/|  __/| |_| | |_| | |___
     |_|   |_|    \___/|____/|_____|
ART
      ;;
    10)
      echo -e "${MAGENTA}${BOLD}"
      cat <<'ART'
      ____                  _
     |  _ \  _____   ____ _| |_ ___
     | | | |/ _ \ \ / / _` | __/ _ \
     | |_| |  __/\ V / (_| | ||  __/
     |____/ \___| \_/ \__,_|\__\___|
ART
      ;;
  esac
  echo -e "${NC}"
  printf "  ${WHITE}${BOLD}STEP %02d${NC}  ${DIM}%s${NC}\n" "$num" "$title"
  echo ""
}

# Legacy aliases
banner() { show_progress_art; }
step_header() { step_art "$1" "$2"; }

say()  { echo -e "  ${DIM}.${NC} $*"; }
ok()   { echo -e "  ${GREEN}+${NC} ${GREEN}$*${NC}"; }
warn() { echo -e "  ${YELLOW}*${NC} ${YELLOW}$*${NC}"; }
err()  { echo -e "  ${RED}x${NC} ${RED}$*${NC}"; }

press_enter() {
  local msg="${1:-Press Enter when ready to continue...}"
  echo ""
  read -r -p "$(echo -e "  ${MAGENTA}>${NC} ${msg} ")" _
}

menu_item() {
  local num="$1"
  local text="$2"
  echo -e "  ${CYAN}${BOLD}${num})${NC} ${text}"
}

progress_dot() {
  local done="$1"
  if [ "$done" = "1" ]; then
    echo -ne "${GREEN}(@)${NC}"
  else
    echo -ne "${DIM}( )${NC}"
  fi
}

show_progress_bar() {
  local done="$1"
  local total="$2"
  local width=20
  local filled=$(( done * width / total ))
  local empty=$(( width - filled ))
  echo -ne "  ${CYAN}"
  printf '[%*s' "$filled" '' | tr ' ' '#'
  printf '%*s]' "$empty" '' | tr ' ' '.'
  echo -e "${NC} ${BOLD}${done}/${total}${NC}"
}
