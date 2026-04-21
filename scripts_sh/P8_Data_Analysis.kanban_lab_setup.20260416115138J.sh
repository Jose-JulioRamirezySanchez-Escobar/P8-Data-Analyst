#!/usr/bin/env bash
# P8_Data_Analysis.kanban_lab_setup.20260416115138J.sh — v2
# Ver comentario completo en la versión anterior

REPO_LAB="Jose-JulioRamirezySanchez-Escobar/P8-Data-Analyst"
ORG_EQUIPO="Bootcamp-IA-P6"
PROJECT_EQUIPO="46"
CARPETA_KANBAN="$HOME/Proyectos/kanban"
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RED='\033[0;31m'; NC='\033[0m'

timestamp_es() {
    local FECHA DIA_NUM; FECHA=$(date +%Y%m%d%H%M%S); DIA_NUM=$(date +%u)
    local DIAS=("" "L" "M" "X" "J" "V" "S" "D"); echo "${FECHA}${DIAS[$DIA_NUM]}"
}

TS=$(timestamp_es)
mkdir -p "$CARPETA_KANBAN"
LOG_FILE="$CARPETA_KANBAN/kanban_lab_setup.${TS}.log"

tl() { echo -e "$1" | tee -a "$LOG_FILE"; }  # tee_log abreviado

tl "${GREEN}============================================${NC}"
tl "${GREEN}  Kanban LAB Setup — P8-Data-Analyst  v2   ${NC}"
tl "${GREEN}============================================${NC}"
tl ""
tl "${CYAN}Log: $LOG_FILE${NC}"

for cmd in gh jq; do
    command -v "$cmd" &>/dev/null || { tl "${RED}ERROR: $cmd no encontrado.${NC}"; exit 1; }
done
gh auth status &>/dev/null || { tl "${RED}ERROR: gh no autenticado.${NC}"; exit 1; }

GITHUB_USER=$(gh api user --jq '.login')
tl "${CYAN}Usuario: $GITHUB_USER | Repo: $REPO_LAB${NC}"

# --- PASO 1: Leer proyecto del equipo ---
tl ""; tl "${YELLOW}[1/4] Leyendo proyecto del equipo...${NC}"
ITEMS_JSON=$(gh project item-list "$PROJECT_EQUIPO" --owner "$ORG_EQUIPO" --format json --limit 200 2>&1)
if ! echo "$ITEMS_JSON" | jq -e '.items' &>/dev/null; then
    tl "${RED}ERROR: $ITEMS_JSON${NC}"; exit 1
fi
TOTAL=$(echo "$ITEMS_JSON" | jq '.items | length')
tl "  ✅ $TOTAL ítems leídos"

# --- PASO 2: Crear proyecto LAB ---
tl ""; tl "${YELLOW}[2/4] Creando proyecto LAB...${NC}"

PROYECTO_EXISTENTE=$(gh project list --owner "$GITHUB_USER" --format json 2>/dev/null | \
    jq -r '.projects[] | select(.title == "P8_Data_Analysis_LAB") | .number // empty' 2>/dev/null || echo "")

if [ -n "$PROYECTO_EXISTENTE" ]; then
    tl "  ${YELLOW}Ya existe #$PROYECTO_EXISTENTE. Usando el existente.${NC}"
    LAB_PROJECT_NUMBER="$PROYECTO_EXISTENTE"
else
    # --format json evita el prompt interactivo
    NUEVO=$(gh project create --owner "$GITHUB_USER" --title "P8_Data_Analysis_LAB" --format json 2>&1)
    LAB_PROJECT_NUMBER=$(echo "$NUEVO" | jq -r '.number // empty' 2>/dev/null || echo "")
    if [ -z "$LAB_PROJECT_NUMBER" ]; then
        LAB_PROJECT_NUMBER=$(echo "$NUEVO" | grep -o '/projects/[0-9]*' | grep -o '[0-9]*' | head -1)
    fi
    if [ -z "$LAB_PROJECT_NUMBER" ]; then
        tl "${RED}ERROR al crear proyecto: $NUEVO${NC}"; exit 1
    fi
    tl "  ✅ Proyecto creado: #$LAB_PROJECT_NUMBER"
fi

LAB_URL="https://github.com/users/$GITHUB_USER/projects/$LAB_PROJECT_NUMBER"
tl "  ${CYAN}$LAB_URL${NC}"

# --- PASO 3: Crear Issues ---
tl ""; tl "${YELLOW}[3/4] Creando Issues en tu repo LAB...${NC}"; tl ""
ERRORES=0; CREADOS=0

while IFS= read -r ITEM; do
    TITULO=$(echo "$ITEM" | jq -r '.title')
    BODY=$(echo "$ITEM" | jq -r '.content.body // "Sin descripción."')
    STATUS=$(echo "$ITEM" | jq -r '.status // "Backlog"')
    URL_ORIG=$(echo "$ITEM" | jq -r '.content.url // "—"')
    tl "  ${CYAN}→ $TITULO${NC}"

    BODY_LAB="> ⚠️ **LABORATORIO** — Copia del equipo (solo práctica)
> Original: $URL_ORIG | Estado: \`$STATUS\`
---
$BODY"

    ISSUE_OUT=$(gh issue create --repo "$REPO_LAB" --title "$TITULO" \
        --body "$BODY_LAB" --assignee "$GITHUB_USER" 2>&1)
    ISSUE_URL=$(echo "$ISSUE_OUT" | grep -o 'https://github.com[^ ]*' | head -1)
    ISSUE_NUM=$(echo "$ISSUE_URL" | grep -o '[0-9]*$')

    if [ -z "$ISSUE_NUM" ]; then
        tl "    ${RED}❌ Error: $ISSUE_OUT${NC}"; ((ERRORES++)); continue
    fi
    tl "    ✅ Issue #$ISSUE_NUM: $ISSUE_URL"; ((CREADOS++))

    ADD_OUT=$(gh project item-add "$LAB_PROJECT_NUMBER" --owner "$GITHUB_USER" --url "$ISSUE_URL" 2>&1)
    if echo "$ADD_OUT" | grep -qi "error\|failed"; then
        tl "    ${YELLOW}⚠️  No añadido al tablero: $ADD_OUT${NC}"
    else
        tl "    ✅ Añadido al tablero"
    fi
    echo "[$TS] CREADO | $TITULO | #$ISSUE_NUM | $STATUS" >> "$LOG_FILE"

done < <(echo "$ITEMS_JSON" | jq -c '.items[]')

# --- PASO 4: Snapshot ---
tl ""; tl "${YELLOW}[4/4] Generando snapshot...${NC}"
ARCHIVO_LAB="$CARPETA_KANBAN/Backlog·P8_Data_Analysis_LAB.${TS}.md"
{
echo "# Backlog · P8_Data_Analysis_LAB"
echo "**Repo:** https://github.com/$REPO_LAB | **Proyecto:** #$LAB_PROJECT_NUMBER"
echo "**Creado:** $(date '+%Y-%m-%d %H:%M:%S') | **Basado en:** $ORG_EQUIPO/#$PROJECT_EQUIPO"
echo "**URL:** $LAB_URL"
echo ""; echo "---"; echo ""
echo "| Issue | Estado original |"; echo "|---|---|"
echo "$ITEMS_JSON" | jq -r '.items[] | "| \(.title) | \(.status // "Backlog") |"'
echo ""; echo "_Generado por kanban_lab_setup.sh v2_"
} > "$ARCHIVO_LAB"
tl "  ✅ $(basename "$ARCHIVO_LAB")"

# --- Resumen ---
tl ""; tl "${GREEN}✅ COMPLETADO — Issues: $CREADOS | Errores: $ERRORES${NC}"
tl "Tablero: $LAB_URL"
tl "Issues:  https://github.com/$REPO_LAB/issues"
tl "Log:     $LOG_FILE"
