#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# SPA Personalization Installer
# - Pretty CLI with colors + ASCII art
# - Empty vs Complete install
# - Interactive prompts to fill spa/core.md, domains/your_first_domain.md,
#   areas/your_first_area.md, projects/your_first_project.md
# - Safe: creates timestamped backups before writing
# -----------------------------------------------------------------------------

set -euo pipefail

# ----------------------------- Styling & Helpers ------------------------------
# ANSI colors (fallback to no color if not a TTY)
if [ -t 1 ]; then
  BOLD="\033[1m"; DIM="\033[2m"; ITALIC="\033[3m"
  RED="\033[31m"; GREEN="\033[32m"; YELLOW="\033[33m"; BLUE="\033[34m"; MAGENTA="\033[35m"; CYAN="\033[36m"
  RESET="\033[0m"
else
  BOLD=""; DIM=""; ITALIC=""; RED=""; GREEN=""; YELLOW=""; BLUE=""; MAGENTA=""; CYAN=""; RESET=""
fi

hr() { printf "${DIM}%*s${RESET}\n" "$(tput cols 2>/dev/null || echo 80)" | tr ' ' '—'; }

banner() {
cat <<'ASCII'
   ____  ____    _     
  / ___||  _ \  / \    
  \___ \| |_) |/ _ \
   ___) |  __// ___ \
  |____/|_| /_/    \_\
ASCII
}

info()    { printf "${BLUE}ℹ${RESET} %s\n" "$*"; }
ok()      { printf "${GREEN}✓${RESET} %s\n" "$*"; }
warn()    { printf "${YELLOW}!${RESET} %s\n" "$*"; }
err()     { printf "${RED}✗${RESET} %s\n" "$*"; }
step()    { printf "\n${BOLD}%s${RESET}\n" "$*"; }
qnum()    { printf "${CYAN}Question (%d/%d)${RESET} %s" "$1" "$2" "${3:-}"; }

read_line() {
  # $1 prompt
  local _ans
  printf "%s" "$1"
  IFS= read -r _ans
  printf "%s" "$_ans"
}

read_multiline() {
  # Read multi-line until a single '.' line
  # $1 heading
  step "$1"
  printf "${DIM}Enter text. Finish with a single '.' on its own line.${RESET}\n"
  local lines=()
  while true; do
    IFS= read -r line
    if [ "$line" = "." ]; then break; fi
    lines+=("$line")
  done
  printf "%s\n" "${lines[@]}"
}

read_n_items() {
  # Read N items, prompt sequentially
  # $1 title, $2 count, $3 question_prefix
  local title="$1" count="$2" prefix="$3"
  local items=()
  for i in $(seq 1 "$count"); do
    printf "%s %s %d/%d: " "${DIM}${title}${RESET}" "$prefix" "$i" "$count"
    IFS= read -r v
    items+=("$v")
  done
  printf "%s\n" "${items[@]}"
}

timestamp() { date +"%Y%m%d-%H%M%S"; }

# ----------------------------- Paths & Checks --------------------------------
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPA_DIR="$REPO_ROOT/spa"
CORE_FILE="$SPA_DIR/core.md"
DOMAINS_DIR="$SPA_DIR/domains"
AREAS_DIR="$SPA_DIR/areas"
PROJECTS_DIR="$SPA_DIR/projects"
DOMAIN_FILE="$DOMAINS_DIR/your_first_domain.md"
AREA_FILE="$AREAS_DIR/your_first_area.md"
PROJECT_FILE="$PROJECTS_DIR/your_first_project.md"

BACKUP_DIR="$SPA_DIR/.install_backups/$(timestamp)"

require_layout() {
  local missing=0
  for path in "$SPA_DIR" "$DOMAINS_DIR" "$AREAS_DIR" "$PROJECTS_DIR"; do
    if [ ! -d "$path" ]; then
      warn "Missing directory: $path (creating)"
      mkdir -p "$path"
    fi
  done
  # If files are missing, create minimal templates from the prompt
  if [ ! -f "$CORE_FILE" ]; then
cat > "$CORE_FILE" <<'MD'
---
type: core
owner: `@leonardespi`
version: 0.1
---

# Mission (one-liner)
> Write the present-tense sentence that describes your ideal self and purpose.
- Example: “I build reliable AI testing systems and teach young creators to ship.”

## Mission (expanded)
Describe the  and yourself in 3–4 paragraphs. Keep it actionable, present-tense, and outcome-oriented.

## Guiding Principles
- Principle 1 — (short description)
- Principle 2 — (short description)
- Principle 3 — (short description)
MD
  fi

  if [ ! -f "$PROJECT_FILE" ]; then
cat > "$PROJECT_FILE" <<'MD'
> Parent domains: [[your_first_domain.md]]

**Project description:**

```

```

---

## Relevant information for project execution

## Purpose
The Projects exists to develop domains, think on how it advances your respective domain. *~ (Delete after reading)*
MD
  fi

  if [ ! -f "$DOMAIN_FILE" ]; then
cat > "$DOMAIN_FILE" <<'MD'
> Last node: [[your_first_area.md]]

**Domain description:**

```

```

> [!NOTE] Domains
> - 

> [!NOTE] Index
> 1.



## Purpose
The Domains exists to develop areas, think on how it advances your respective area main. *~ (Delete after reading)*
MD
  fi

  if [ ! -f "$AREA_FILE" ]; then
cat > "$AREA_FILE" <<'MD'
> Last node: [[core.md]]

**Area description:**

```

```

> [!NOTE] Domains
> - 

> [!NOTE] Index
> 1.

## Purpose
The Areas exists to develop your core mission and future self, think on how it advances your mission. *~ (Delete after reading)*
MD
  fi
}

backup_all() {
  mkdir -p "$BACKUP_DIR"
  cp -a "$CORE_FILE" "$DOMAIN_FILE" "$AREA_FILE" "$PROJECT_FILE" "$BACKUP_DIR"/
  ok "Backups created at ${BACKUP_DIR}"
}

# --------------------------- Interactive Flow --------------------------------
main_menu() {
  banner
  hr
  printf "${BOLD}SPA Installer — Personalization Script${RESET}\n"
  hr
  info "Repository root: $REPO_ROOT"
  info "Target folder    : $SPA_DIR"
  echo
  printf "${BOLD}Choose installation mode:${RESET}\n"
  printf "  [1] Complete install (answer questions and personalize documents)\n"
  printf "  [2] Empty install    (leave documents as-is and exit)\n"
  printf "Selection [1/2]: "
  read -r MODE
  case "${MODE:-1}" in
    1|"") MODE="complete" ;;
    2) MODE="empty" ;;
    *) warn "Unrecognized option, defaulting to Complete."; MODE="complete" ;;
  esac
  echo
}

compute_total_questions() {
  # We ask for counts first so we can compute a stable total
  # Static slots:
  #  1  : Mission one-liner
  #  2  : Mission expanded
  #  3  : Number of principles
  # 4.. : Each principle (N)
  # Next: Domain title, Domain description,
  #       Number Domain notes + notes (Dn),
  #       Number Domain index + items (Di),
  #       Area title, Area description,
  #       Number Area notes + items (An),
  #       Number Area index + items (Ai),
  #       Project title, Project description,
  #       Number Project “Relevant info” + items (Pr)
  TOTAL=$(( 2 + 1 + PRIN_N + 2 + 1 + DOM_NOTES_N + 1 + DOM_INDEX_N + 2 + 1 + AREA_NOTES_N + 1 + AREA_INDEX_N + 2 + 1 + PROJ_REL_N ))
}

write_core() {
  local mission_one="$1"
  local mission_expanded="$2"
  shift 2
  local -a principles=( "$@" )

  cat > "$CORE_FILE" <<MD
---
type: core
owner: \`@leonardespi\`
version: 0.1
---

# Mission (one-liner)
> ${mission_one}

## Mission (expanded)
${mission_expanded}

## Guiding Principles
$(for p in "${principles[@]}"; do echo "- ${p}"; done)
MD
  ok "Updated: spa/core.md"
}

write_domain() {
  local domain_title="$1"; shift
  local domain_desc="$1"; shift
  local -a dom_notes=( "$@" )
  # domain index is global array DOM_INDEX
  cat > "$DOMAIN_FILE" <<MD
# ${domain_title}

> Last node: [[your_first_area.md]]

**Domain description:**

\`\`\`
${domain_desc}
\`\`\`

> [!NOTE] Domains
$( if [ "${#dom_notes[@]}" -eq 0 ]; then echo "> -"; else for n in "${dom_notes[@]}"; do echo "> - ${n}"; done; fi )

> [!NOTE] Index
$( if [ "${#DOM_INDEX[@]}" -eq 0 ]; then echo "> 1."; else i=1; for it in "${DOM_INDEX[@]}"; do echo "> ${i}. ${it}"; i=$((i+1)); done; fi )

## Purpose
This domain advances its related Areas through deliberate, ongoing development linked to responsibilities and outcomes.
MD
  ok "Updated: spa/domains/your_first_domain.md"
}

write_area() {
  local area_title="$1"; shift
  local area_desc="$1"; shift
  local -a area_notes=( "$@" )
  cat > "$AREA_FILE" <<MD
# ${area_title}

> Last node: [[core.md]]

**Area description:**

\`\`\`
${area_desc}
\`\`\`

> [!NOTE] Domains
$( if [ "${#area_notes[@]}" -eq 0 ]; then echo "> -"; else for n in "${area_notes[@]}"; do echo "> - ${n}"; done; fi )

> [!NOTE] Index
$( if [ "${#AREA_INDEX[@]}" -eq 0 ]; then echo "> 1."; else i=1; for it in "${AREA_INDEX[@]}"; do echo "> ${i}. ${it}"; i=$((i+1)); done; fi )

## Purpose
This area operationalizes your core mission into sustained responsibilities and measurable health.
MD
  ok "Updated: spa/areas/your_first_area.md"
}

write_project() {
  local project_title="$1"; shift
  local project_desc="$1"; shift
  local -a proj_rel=( "$@" )
  cat > "$PROJECT_FILE" <<MD
# ${project_title}

> Parent domains: [[your_first_domain.md]]

**Project description:**

\`\`\`
${project_desc}
\`\`\`

---

## Relevant information for project execution
$( if [ "${#proj_rel[@]}" -eq 0 ]; then echo "-"; else for n in "${proj_rel[@]}"; do echo "- ${n}"; done; fi )

## Purpose
This project exists to materially advance its parent domain through a time-bounded outcome with a clear plan.
MD
  ok "Updated: spa/projects/your_first_project.md"
}

# ----------------------------- Program Start ---------------------------------
require_layout
main_menu

if [ "$MODE" = "empty" ]; then
  step "Empty install selected"
  backup_all
  ok "No changes applied. Documents left as-is."
  exit 0
fi

# ---------------- Collect counts first to compute a stable total --------------
backup_all
step "Setup — How many items will you provide for each section?"
printf "${DIM}(You can provide 0 for any list if you prefer to skip)${RESET}\n\n"

read -rp "Number of guiding principles: " PRIN_N
PRIN_N=${PRIN_N:-3}
read -rp "Number of DOMAIN notes: " DOM_NOTES_N
DOM_NOTES_N=${DOM_NOTES_N:-0}
read -rp "Number of DOMAIN index items: " DOM_INDEX_N
DOM_INDEX_N=${DOM_INDEX_N:-0}
read -rp "Number of AREA notes: " AREA_NOTES_N
AREA_NOTES_N=${AREA_NOTES_N:-0}
read -rp "Number of AREA index items: " AREA_INDEX_N
AREA_INDEX_N=${AREA_INDEX_N:-0}
read -rp "Number of PROJECT relevant info bullets: " PROJ_REL_N
PROJ_REL_N=${PROJ_REL_N:-0}

compute_total_questions

# ----------------------------- Interactive Q&A --------------------------------
Q=0

# CORE — Mission one-liner
Q=$((Q+1)); qnum "$Q" "$TOTAL" "Enter your ${BOLD}Mission (one-liner)${RESET}: "
MISSION_ONE="$(read_line "")"
echo

# CORE — Mission expanded (multiline)
Q=$((Q+1)); qnum "$Q" "$TOTAL" "Enter your ${BOLD}Mission (expanded, 3–4 short paragraphs)${RESET}\n"
MISSION_EXPANDED="$(read_multiline "Write below")"

# CORE — Principles count already asked (counts phase)
Q=$((Q+1)); qnum "$Q" "$TOTAL" "${BOLD}Guiding Principles count confirmed:${RESET} ${PRIN_N}\n"
sleep 0.2

# CORE — Principles items
PRINCIPLES=()
if [ "$PRIN_N" -gt 0 ]; then
  step "Guiding Principles"
  mapfile -t PRINCIPLES < <(read_n_items "Principles" "$PRIN_N" "enter principle")
fi

# DOMAIN — Title
Q=$((Q+1)); qnum "$Q" "$TOTAL" "Enter ${BOLD}Domain title${RESET} (e.g., Product Engineering): "
DOMAIN_TITLE="$(read_line "")"
echo

# DOMAIN — Description (multiline)
Q=$((Q+1)); qnum "$Q" "$TOTAL" "Enter ${BOLD}Domain description${RESET}\n"
DOMAIN_DESC="$(read_multiline "Write below")"

# DOMAIN — Notes count confirmed
Q=$((Q+1)); qnum "$Q" "$TOTAL" "${BOLD}Domain notes count confirmed:${RESET} ${DOM_NOTES_N}\n"
DOMAIN_NOTES=()
if [ "$DOM_NOTES_N" -gt 0 ]; then
  mapfile -t DOMAIN_NOTES < <(read_n_items "Domain notes" "$DOM_NOTES_N" "note")
fi

# DOMAIN — Index items
Q=$((Q+1)); qnum "$Q" "$TOTAL" "${BOLD}Domain index items count confirmed:${RESET} ${DOM_INDEX_N}\n"
DOM_INDEX=()
if [ "$DOM_INDEX_N" -gt 0 ]; then
  mapfile -t DOM_INDEX < <(read_n_items "Domain index" "$DOM_INDEX_N" "item")
fi

# AREA — Title
Q=$((Q+1)); qnum "$Q" "$TOTAL" "Enter ${BOLD}Area title${RESET} (e.g., QA & Reliability): "
AREA_TITLE="$(read_line "")"
echo

# AREA — Description (multiline)
Q=$((Q+1)); qnum "$Q" "$TOTAL" "Enter ${BOLD}Area description${RESET}\n"
AREA_DESC="$(read_multiline "Write below")"

# AREA — Notes count confirmed
Q=$((Q+1)); qnum "$Q" "$TOTAL" "${BOLD}Area notes count confirmed:${RESET} ${AREA_NOTES_N}\n"
AREA_NOTES=()
if [ "$AREA_NOTES_N" -gt 0 ]; then
  mapfile -t AREA_NOTES < <(read_n_items "Area notes" "$AREA_NOTES_N" "note")
fi

# AREA — Index items
Q=$((Q+1)); qnum "$Q" "$TOTAL" "${BOLD}Area index items count confirmed:${RESET} ${AREA_INDEX_N}\n"
AREA_INDEX=()
if [ "$AREA_INDEX_N" -gt 0 ]; then
  mapfile -t AREA_INDEX < <(read_n_items "Area index" "$AREA_INDEX_N" "item")
fi

# PROJECT — Title
Q=$((Q+1)); qnum "$Q" "$TOTAL" "Enter ${BOLD}Project title${RESET} (e.g., Ship SPA v0.1): "
PROJECT_TITLE="$(read_line "")"
echo

# PROJECT — Description (multiline)
Q=$((Q+1)); qnum "$Q" "$TOTAL" "Enter ${BOLD}Project description${RESET}\n"
PROJECT_DESC="$(read_multiline "Write below")"

# PROJECT — Relevant info confirmed + items
Q=$((Q+1)); qnum "$Q" "$TOTAL" "${BOLD}Project relevant-info bullets confirmed:${RESET} ${PROJ_REL_N}\n"
PROJ_REL_INFO=()
if [ "$PROJ_REL_N" -gt 0 ]; then
  mapfile -t PROJ_REL_INFO < <(read_n_items "Relevant info" "$PROJ_REL_N" "bullet")
fi

# ----------------------------- Write Documents --------------------------------
step "Composing documents…"
write_core   "$MISSION_ONE" "$MISSION_EXPANDED" "${PRINCIPLES[@]:-}"
write_domain "$DOMAIN_TITLE" "$DOMAIN_DESC" "${DOMAIN_NOTES[@]:-}"
write_area   "$AREA_TITLE" "$AREA_DESC" "${AREA_NOTES[@]:-}"
write_project "$PROJECT_TITLE" "$PROJECT_DESC" "${PROJ_REL_INFO[@]:-}"

hr
ok "Personalization complete."
info "Backups stored at: $BACKUP_DIR"
info "Edited files:"
printf "  - %s\n" "$CORE_FILE" "$DOMAIN_FILE" "$AREA_FILE" "$PROJECT_FILE"
hr
printf "${BOLD}Tip:${RESET} Re-run ${ITALIC}bash install.sh${RESET} anytime to update.\n"
echo
