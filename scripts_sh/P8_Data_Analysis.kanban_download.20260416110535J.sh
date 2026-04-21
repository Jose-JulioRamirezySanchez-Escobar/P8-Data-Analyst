#!/usr/bin/env bash
# =============================================================================
# P8_Data_Analysis.kanban_download.20260416110535J.sh  — v2 CORREGIDO
#
# Correcciones respecto a v1:
#   - assignees es array de strings, no de objetos (no usar .login)
#   - Nombres de columnas ajustados al valor real de la API:
#     "Backlog", "Ready", "In progress", "In review", "Done"
#
# REQUISITOS:
#   - gh CLI autenticado con scope read:project
#     (gh auth refresh -s read:project)
#   - jq instalado: winget install --id jqlang.jq
#
# USO:
#   bash P8_Data_Analysis.kanban_download.20260416110535J.sh
# =============================================================================

set -e

ORG="Bootcamp-IA-P6"
PROJECT_NUMBER="46"
CARPETA_KANBAN="$HOME/Proyectos/kanban"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

timestamp_es() {
    local FECHA DIA_NUM
    FECHA=$(date +%Y%m%d%H%M%S)
    DIA_NUM=$(date +%u)
    local DIAS=("" "L" "M" "X" "J" "V" "S" "D")
    echo "${FECHA}${DIAS[$DIA_NUM]}"
}

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Kanban Download — P8_Data_Analysis  v2   ${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""

for cmd in gh jq; do
    if ! command -v "$cmd" &>/dev/null; then
        echo -e "${RED}ERROR: '$cmd' no encontrado.${NC}"
        [ "$cmd" = "jq" ] && echo "Instala con: winget install --id jqlang.jq"
        exit 1
    fi
done

if ! gh auth status &>/dev/null; then
    echo -e "${RED}ERROR: No autenticado. Ejecuta: gh auth login${NC}"
    exit 1
fi

if ! gh auth status 2>&1 | grep -q "read:project"; then
    echo -e "${RED}ERROR: Falta el scope 'read:project'.${NC}"
    echo "Ejecuta: gh auth refresh -s read:project"
    exit 1
fi

GITHUB_USER=$(gh api user --jq '.login')
echo -e "${CYAN}Usuario: $GITHUB_USER${NC}"

mkdir -p "$CARPETA_KANBAN"
TS=$(timestamp_es)
echo -e "${CYAN}Timestamp: $TS${NC}"

ARCHIVO_GLOBAL="$CARPETA_KANBAN/Backlog·P8_Data_Analysis.${TS}.md"
ARCHIVO_PERSONAL="$CARPETA_KANBAN/MisTareas·P8_Data_Analysis.${TS}.md"

# -----------------------------------------------------------------------------
echo ""
echo -e "${YELLOW}[1/3] Descargando ítems del proyecto...${NC}"

ITEMS_JSON=$(gh project item-list "$PROJECT_NUMBER" \
    --owner "$ORG" \
    --format json \
    --limit 200 2>&1)

if ! echo "$ITEMS_JSON" | jq -e '.items' &>/dev/null; then
    echo -e "${RED}ERROR al descargar el proyecto:${NC}"
    echo "$ITEMS_JSON"
    exit 1
fi

TOTAL=$(echo "$ITEMS_JSON" | jq '.items | length')
echo -e "  ✅ Ítems descargados: $TOTAL"

# -----------------------------------------------------------------------------
echo ""
echo -e "${YELLOW}[2/3] Generando vista global del tablero...${NC}"

{
echo "# Backlog · P8_Data_Analysis"
echo "**Organización:** $ORG  "
echo "**Proyecto:** #$PROJECT_NUMBER  "
echo "**Descargado:** $(date '+%Y-%m-%d %H:%M:%S') por $GITHUB_USER  "
echo "**URL:** https://github.com/orgs/$ORG/projects/$PROJECT_NUMBER/views/1  "
echo ""
echo "---"
echo ""
} > "$ARCHIVO_GLOBAL"

escribir_columna() {
    local COL="$1"
    local COUNT
    COUNT=$(echo "$ITEMS_JSON" | jq --arg col "$COL" \
        '[.items[] | select(.status == $col)] | length')
    [ "$COUNT" -eq 0 ] && return

    echo "## 📋 $COL ($COUNT)" >> "$ARCHIVO_GLOBAL"
    echo "" >> "$ARCHIVO_GLOBAL"

    echo "$ITEMS_JSON" | jq -r --arg col "$COL" '
        .items[]
        | select(.status == $col)
        | "### \(.title)\n" +
          "- **URL:** \(.content.url // "—")\n" +
          "- **Asignado a:** \(if (.assignees | length) > 0 then (.assignees | join(", ")) else "Sin asignar" end)\n" +
          "- **ID:** \(.id)\n" +
          "\n> \(.content.body // "—" | split("\n") | .[0:3] | join(" "))\n"
    ' >> "$ARCHIVO_GLOBAL"
    echo "" >> "$ARCHIVO_GLOBAL"
}

for COL in "Backlog" "Ready" "In progress" "In review" "Done"; do
    escribir_columna "$COL"
done

# Columnas extra no previstas
while IFS= read -r COL; do
    case "$COL" in
        "Backlog"|"Ready"|"In progress"|"In review"|"Done") ;;
        *) [ -n "$COL" ] && escribir_columna "$COL" ;;
    esac
done < <(echo "$ITEMS_JSON" | jq -r '[.items[].status] | unique[]')

{
echo "---"
echo ""
echo "## Resumen"
echo ""
echo "| Columna | Ítems |"
echo "|---|---|"
} >> "$ARCHIVO_GLOBAL"

while IFS= read -r COL; do
    COUNT=$(echo "$ITEMS_JSON" | jq --arg col "$COL" \
        '[.items[] | select(.status == $col)] | length')
    echo "| $COL | $COUNT |" >> "$ARCHIVO_GLOBAL"
done < <(echo "$ITEMS_JSON" | jq -r '[.items[].status] | unique[]')

echo "" >> "$ARCHIVO_GLOBAL"
echo "_Generado automáticamente — P8_Data_Analysis.kanban_download.20260416110535J.sh v2_" >> "$ARCHIVO_GLOBAL"
echo -e "  ✅ Vista global: $(basename "$ARCHIVO_GLOBAL")"

# -----------------------------------------------------------------------------
echo ""
echo -e "${YELLOW}[3/3] Generando vista personal ($GITHUB_USER)...${NC}"

# FIX: assignees es array de strings — index($user) en lugar de map(.login)
MIS_TAREAS_COUNT=$(echo "$ITEMS_JSON" | jq --arg user "$GITHUB_USER" \
    '[.items[] | select(.assignees | index($user) != null)] | length')

{
echo "# Mis Tareas · P8_Data_Analysis"
echo "**Usuario:** $GITHUB_USER  "
echo "**Proyecto:** $ORG / #$PROJECT_NUMBER  "
echo "**Descargado:** $(date '+%Y-%m-%d %H:%M:%S')  "
echo "**Tareas asignadas:** $MIS_TAREAS_COUNT  "
echo ""
echo "---"
echo ""
} > "$ARCHIVO_PERSONAL"

if [ "$MIS_TAREAS_COUNT" -eq 0 ]; then
    echo "_No hay tareas asignadas a $GITHUB_USER en este momento._" >> "$ARCHIVO_PERSONAL"
else
    echo "$ITEMS_JSON" | jq -r --arg user "$GITHUB_USER" '
        .items[]
        | select(.assignees | index($user) != null)
        | "### [\(.status)] \(.title)\n" +
          "- **URL:** \(.content.url // "—")\n" +
          "- **Compañeros asignados:** \(if (.assignees | length) > 1 then (.assignees | map(select(. != $user)) | join(", ")) else "Solo tú" end)\n" +
          "- **ID:** \(.id)\n" +
          "\n**Descripción completa:**\n\(.content.body // "—")\n"
    ' >> "$ARCHIVO_PERSONAL"
fi

{
echo ""
echo "---"
echo ""
echo "## Checklist de trabajo"
echo ""
echo "> Marca las tareas conforme avances."
echo ""
} >> "$ARCHIVO_PERSONAL"

echo "$ITEMS_JSON" | jq -r --arg user "$GITHUB_USER" '
    .items[]
    | select(.assignees | index($user) != null)
    | "- [ ] [\(.status)] \(.title)"
' >> "$ARCHIVO_PERSONAL"

echo "" >> "$ARCHIVO_PERSONAL"
echo "_Generado automáticamente — P8_Data_Analysis.kanban_download.20260416110535J.sh v2_" >> "$ARCHIVO_PERSONAL"
echo -e "  ✅ Vista personal: $(basename "$ARCHIVO_PERSONAL")"

# -----------------------------------------------------------------------------
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  ✅ COMPLETADO                            ${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "${CYAN}Archivos en: $CARPETA_KANBAN${NC}"
echo "  📋 Global:   $(basename "$ARCHIVO_GLOBAL")"
echo "  👤 Personal: $(basename "$ARCHIVO_PERSONAL")"
echo ""
echo -e "${CYAN}Total ítems: $TOTAL | Tus tareas: $MIS_TAREAS_COUNT${NC}"
echo ""
echo "Historial: ls -lt $CARPETA_KANBAN/"
