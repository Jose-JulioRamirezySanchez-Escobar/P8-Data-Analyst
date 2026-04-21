#!/usr/bin/env bash
# =============================================================================
# P8_Data_Analysis.kanban_update.20260416044353J.sh
#
# Actualiza tareas del tablero Kanban de GitHub Projects desde la terminal.
#
# ACCIONES DISPONIBLES:
#   1. Cambiar el estado de una tarea (mover entre columnas)
#   2. Añadir un comentario a una tarea (desde archivo .txt)
#   3. Añadir un vínculo/referencia útil como comentario a una tarea
#   4. Ver el estado actual de tus tareas asignadas
#
# Todo lo que hagas aquí queda reflejado en la interfaz web de GitHub
# y es visible para el resto del equipo.
#
# REQUISITOS:
#   - gh CLI instalado y autenticado
#   - jq instalado: winget install --id jqlang.jq
#
# USO:
#   bash P8_Data_Analysis.kanban_update.20260416044353J.sh
#
# =============================================================================

set -e

# -----------------------------------------------------------------------------
# CONFIGURACIÓN
# -----------------------------------------------------------------------------
ORG="Bootcamp-IA-P6"
PROJECT_NUMBER="46"
CARPETA_KANBAN="$HOME/Proyectos/kanban"

# -----------------------------------------------------------------------------
# COLORES
# -----------------------------------------------------------------------------
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

# -----------------------------------------------------------------------------
# FUNCIÓN: timestamp con día de semana en español
# -----------------------------------------------------------------------------
timestamp_es() {
    local FECHA
    FECHA=$(date +%Y%m%d%H%M%S)
    local DIA_NUM
    DIA_NUM=$(date +%u)
    local DIAS=("" "L" "M" "X" "J" "V" "S" "D")
    echo "${FECHA}${DIAS[$DIA_NUM]}"
}

# -----------------------------------------------------------------------------
# FUNCIÓN: log de acciones realizadas
# -----------------------------------------------------------------------------
LOG_FILE="$CARPETA_KANBAN/kanban_update.log"
log_accion() {
    mkdir -p "$CARPETA_KANBAN"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# -----------------------------------------------------------------------------
# VERIFICACIONES
# -----------------------------------------------------------------------------
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Kanban Update — P8_Data_Analysis         ${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""

for cmd in gh jq; do
    if ! command -v "$cmd" &>/dev/null; then
        echo -e "${RED}ERROR: '$cmd' no encontrado.${NC}"
        if [ "$cmd" = "jq" ]; then
            echo "Instala con: winget install --id jqlang.jq"
        fi
        exit 1
    fi
done

if ! gh auth status &>/dev/null; then
    echo -e "${RED}ERROR: No autenticado. Ejecuta: gh auth login${NC}"
    exit 1
fi

GITHUB_USER=$(gh api user --jq '.login')
echo -e "${CYAN}Usuario: $GITHUB_USER${NC}"

# -----------------------------------------------------------------------------
# MENÚ PRINCIPAL
# -----------------------------------------------------------------------------
echo ""
echo -e "${BOLD}¿Qué quieres hacer?${NC}"
echo ""
echo "  1) Ver mis tareas asignadas"
echo "  2) Cambiar el estado de una tarea"
echo "  3) Añadir un comentario a una tarea (desde archivo .txt)"
echo "  4) Añadir un vínculo/referencia útil a una tarea"
echo "  5) Ver historial de acciones realizadas"
echo "  0) Salir"
echo ""
read -rp "Opción: " OPCION

# =============================================================================
# FUNCIÓN: obtener ítems del proyecto
# =============================================================================
obtener_items() {
    gh project item-list "$PROJECT_NUMBER" \
        --owner "$ORG" \
        --format json \
        --limit 200 2>/dev/null
}

# =============================================================================
# FUNCIÓN: mostrar mis tareas
# =============================================================================
mostrar_mis_tareas() {
    echo ""
    echo -e "${CYAN}Descargando tareas...${NC}"
    local ITEMS_JSON
    ITEMS_JSON=$(obtener_items)

    local COUNT
    COUNT=$(echo "$ITEMS_JSON" | jq --arg user "$GITHUB_USER" '
        [.items[] | select(
            .assignees != null and
            (.assignees | map(.login) | any(. == $user))
        )] | length')

    echo ""
    echo -e "${BOLD}Tareas asignadas a $GITHUB_USER ($COUNT):${NC}"
    echo ""

    # Guardar también en archivo con timestamp
    mkdir -p "$CARPETA_KANBAN"
    local TS
    TS=$(timestamp_es)
    local ARCHIVO="$CARPETA_KANBAN/MisTareas·P8_Data_Analysis.${TS}.md"

    echo "# Mis Tareas · P8_Data_Analysis" > "$ARCHIVO"
    echo "**Usuario:** $GITHUB_USER | **Fecha:** $(date '+%Y-%m-%d %H:%M:%S')" >> "$ARCHIVO"
    echo "" >> "$ARCHIVO"

    echo "$ITEMS_JSON" | jq -r --arg user "$GITHUB_USER" '
        .items[]
        | select(
            .assignees != null and
            (.assignees | map(.login) | any(. == $user))
          )
        | "[\(.status // "Sin estado")] \(.title // "(sin título)")\n  ID: \(.id)\n  URL: \(.url // "—")\n"
    '

    echo "$ITEMS_JSON" | jq -r --arg user "$GITHUB_USER" '
        .items[]
        | select(
            .assignees != null and
            (.assignees | map(.login) | any(. == $user))
          )
        | "### [\(.status // "Sin estado")] \(.title // "(sin título)")\n- **ID:** \(.id)\n- **URL:** \(.url // "—")\n"
    ' >> "$ARCHIVO"

    echo -e "\n${CYAN}Guardado en: $(basename "$ARCHIVO")${NC}"
}

# =============================================================================
# FUNCIÓN: seleccionar tarea
# =============================================================================
seleccionar_tarea() {
    echo ""
    echo -e "${CYAN}Descargando tus tareas...${NC}"
    local ITEMS_JSON
    ITEMS_JSON=$(obtener_items)

    # Mostrar lista numerada de mis tareas
    echo ""
    echo -e "${BOLD}Selecciona una tarea:${NC}"
    echo ""

    local TAREAS=()
    local IDS=()
    local URLS=()
    local ESTADOS=()
    local i=1

    while IFS= read -r linea; do
        local TITULO
        local ID
        local URL
        local ESTADO
        TITULO=$(echo "$linea" | jq -r '.title // "(sin título)"')
        ID=$(echo "$linea" | jq -r '.id')
        URL=$(echo "$linea" | jq -r '.url // ""')
        ESTADO=$(echo "$linea" | jq -r '.status // "Sin estado"')

        echo "  $i) [$ESTADO] $TITULO"
        TAREAS+=("$TITULO")
        IDS+=("$ID")
        URLS+=("$URL")
        ESTADOS+=("$ESTADO")
        ((i++))
    done < <(echo "$ITEMS_JSON" | jq -c --arg user "$GITHUB_USER" '
        .items[]
        | select(
            .assignees != null and
            (.assignees | map(.login) | any(. == $user))
          )
    ')

    if [ ${#TAREAS[@]} -eq 0 ]; then
        echo -e "  ${YELLOW}No tienes tareas asignadas en este momento.${NC}"
        return 1
    fi

    echo ""
    read -rp "Número de tarea: " NUM_TAREA
    local IDX=$((NUM_TAREA - 1))

    TAREA_SELECCIONADA="${TAREAS[$IDX]}"
    TAREA_ID="${IDS[$IDX]}"
    TAREA_URL="${URLS[$IDX]}"
    TAREA_ESTADO="${ESTADOS[$IDX]}"

    echo ""
    echo -e "${CYAN}Tarea seleccionada: ${BOLD}$TAREA_SELECCIONADA${NC}"
    echo -e "${CYAN}Estado actual: $TAREA_ESTADO${NC}"
    echo -e "${CYAN}ID: $TAREA_ID${NC}"
}

# =============================================================================
# OPCIÓN 1: Ver mis tareas
# =============================================================================
if [ "$OPCION" = "1" ]; then
    mostrar_mis_tareas

# =============================================================================
# OPCIÓN 2: Cambiar estado
# =============================================================================
elif [ "$OPCION" = "2" ]; then
    seleccionar_tarea || exit 0

    echo ""
    echo -e "${BOLD}Nuevo estado:${NC}"
    echo ""
    echo "  1) Backlog"
    echo "  2) Todo"
    echo "  3) In Progress"
    echo "  4) In Review"
    echo "  5) Done"
    echo ""
    read -rp "Opción: " NUM_ESTADO

    ESTADOS_DISPONIBLES=("" "Backlog" "Todo" "In Progress" "In Review" "Done")
    NUEVO_ESTADO="${ESTADOS_DISPONIBLES[$NUM_ESTADO]}"

    if [ -z "$NUEVO_ESTADO" ]; then
        echo -e "${RED}Estado no válido.${NC}"
        exit 1
    fi

    echo ""
    echo -e "${YELLOW}Cambiando estado a '$NUEVO_ESTADO'...${NC}"

    # Obtener el ID del campo Status y el ID de la opción
    FIELD_ID=$(gh project field-list "$PROJECT_NUMBER" \
        --owner "$ORG" \
        --format json 2>/dev/null | \
        jq -r '.fields[] | select(.name == "Status") | .id')

    OPTION_ID=$(gh project field-list "$PROJECT_NUMBER" \
        --owner "$ORG" \
        --format json 2>/dev/null | \
        jq -r --arg estado "$NUEVO_ESTADO" \
        '.fields[] | select(.name == "Status") | .options[] | select(.name == $estado) | .id')

    if [ -z "$FIELD_ID" ] || [ -z "$OPTION_ID" ]; then
        echo -e "${RED}No se pudo obtener el ID del campo Status o de la opción '$NUEVO_ESTADO'.${NC}"
        echo "Verifica los nombres de las columnas en el tablero."
        exit 1
    fi

    gh project item-edit \
        --project-id "$(gh project list --owner "$ORG" --format json | jq -r --arg num "$PROJECT_NUMBER" '.projects[] | select(.number == ($num | tonumber)) | .id')" \
        --id "$TAREA_ID" \
        --field-id "$FIELD_ID" \
        --single-select-option-id "$OPTION_ID" 2>/dev/null

    echo -e "  ${GREEN}✅ Estado actualizado: '$TAREA_ESTADO' → '$NUEVO_ESTADO'${NC}"
    echo -e "  ${CYAN}Visible en: https://github.com/orgs/$ORG/projects/$PROJECT_NUMBER/views/1${NC}"

    log_accion "ESTADO | $TAREA_SELECCIONADA | $TAREA_ESTADO → $NUEVO_ESTADO"

# =============================================================================
# OPCIÓN 3: Añadir comentario desde archivo .txt
# =============================================================================
elif [ "$OPCION" = "3" ]; then
    seleccionar_tarea || exit 0

    echo ""
    echo -e "${BOLD}Introduce la ruta del archivo .txt con el comentario:${NC}"
    echo "(puede ser ruta relativa desde ~/Proyectos/P8-Data-Analyst/)"
    echo ""
    read -rp "Archivo: " RUTA_COMENTARIO

    # Expandir ~ si es necesario
    RUTA_COMENTARIO="${RUTA_COMENTARIO/#\~/$HOME}"

    if [ ! -f "$RUTA_COMENTARIO" ]; then
        # Intentar relativa a P8-Data-Analyst
        RUTA_ALT="$HOME/Proyectos/P8-Data-Analyst/$RUTA_COMENTARIO"
        if [ -f "$RUTA_ALT" ]; then
            RUTA_COMENTARIO="$RUTA_ALT"
        else
            echo -e "${RED}ERROR: No se encuentra el archivo '$RUTA_COMENTARIO'${NC}"
            exit 1
        fi
    fi

    CONTENIDO=$(cat "$RUTA_COMENTARIO")

    echo ""
    echo -e "${CYAN}Previsualizando comentario (primeras 5 líneas):${NC}"
    head -5 "$RUTA_COMENTARIO"
    echo ""
    read -rp "¿Publicar este comentario? (s/n): " CONFIRMAR

    if [ "$CONFIRMAR" != "s" ]; then
        echo "Cancelado."
        exit 0
    fi

    # Extraer el número del issue/PR de la URL de la tarea
    # Las tareas de Projects que son Issues tienen URL tipo github.com/org/repo/issues/N
    if [[ "$TAREA_URL" =~ /issues/([0-9]+)$ ]]; then
        ISSUE_NUM="${BASH_REMATCH[1]}"
        REPO=$(echo "$TAREA_URL" | sed 's|https://github.com/||' | sed 's|/issues/.*||')

        gh issue comment "$ISSUE_NUM" \
            --repo "$REPO" \
            --body "$CONTENIDO"

        echo -e "  ${GREEN}✅ Comentario publicado en: $TAREA_URL${NC}"
        log_accion "COMENTARIO | $TAREA_SELECCIONADA | desde: $(basename "$RUTA_COMENTARIO")"
    else
        echo -e "${YELLOW}⚠️  Esta tarea no es un Issue de GitHub — es un ítem draft del proyecto.${NC}"
        echo "Los comentarios solo se pueden añadir a Issues vinculados, no a ítems draft."
        echo "Convierte la tarea en Issue desde GitHub web para poder comentar."
    fi

# =============================================================================
# OPCIÓN 4: Añadir vínculo/referencia útil
# =============================================================================
elif [ "$OPCION" = "4" ]; then
    seleccionar_tarea || exit 0

    echo ""
    echo -e "${BOLD}Introduce el vínculo o URL a añadir:${NC}"
    read -rp "URL: " VINCULO

    echo ""
    echo -e "${BOLD}Descripción del vínculo (una línea):${NC}"
    read -rp "Descripción: " DESC_VINCULO

    echo ""
    echo -e "${BOLD}Contexto opcional (para qué sirve, Enter para omitir):${NC}"
    read -rp "Contexto: " CONTEXTO_VINCULO

    # Construir el comentario
    TS_LEGIBLE=$(date '+%Y-%m-%d %H:%M:%S')
    BODY_VINCULO="### 🔗 Referencia añadida por $GITHUB_USER

**Descripción:** $DESC_VINCULO  
**URL:** $VINCULO  
**Fecha:** $TS_LEGIBLE"

    if [ -n "$CONTEXTO_VINCULO" ]; then
        BODY_VINCULO="$BODY_VINCULO  
**Contexto:** $CONTEXTO_VINCULO"
    fi

    echo ""
    echo -e "${CYAN}Previsualizando:${NC}"
    echo "$BODY_VINCULO"
    echo ""
    read -rp "¿Publicar? (s/n): " CONFIRMAR

    if [ "$CONFIRMAR" != "s" ]; then
        echo "Cancelado."
        exit 0
    fi

    if [[ "$TAREA_URL" =~ /issues/([0-9]+)$ ]]; then
        ISSUE_NUM="${BASH_REMATCH[1]}"
        REPO=$(echo "$TAREA_URL" | sed 's|https://github.com/||' | sed 's|/issues/.*||')

        gh issue comment "$ISSUE_NUM" \
            --repo "$REPO" \
            --body "$BODY_VINCULO"

        echo -e "  ${GREEN}✅ Vínculo publicado en: $TAREA_URL${NC}"
        log_accion "VÍNCULO | $TAREA_SELECCIONADA | $VINCULO"
    else
        echo -e "${YELLOW}⚠️  Esta tarea no es un Issue — es un ítem draft del proyecto.${NC}"
        echo "Convierte la tarea en Issue desde GitHub web para poder añadir vínculos como comentarios."
    fi

# =============================================================================
# OPCIÓN 5: Ver historial de acciones
# =============================================================================
elif [ "$OPCION" = "5" ]; then
    if [ ! -f "$LOG_FILE" ]; then
        echo ""
        echo -e "${YELLOW}No hay historial de acciones todavía.${NC}"
    else
        echo ""
        echo -e "${BOLD}Historial de acciones (más recientes primero):${NC}"
        echo ""
        tac "$LOG_FILE" | head -30
        echo ""
        echo -e "${CYAN}Log completo en: $LOG_FILE${NC}"
    fi

elif [ "$OPCION" = "0" ]; then
    echo "Saliendo."
    exit 0
else
    echo -e "${RED}Opción no válida.${NC}"
    exit 1
fi

echo ""
echo -e "${CYAN}Tablero web: https://github.com/orgs/$ORG/projects/$PROJECT_NUMBER/views/1${NC}"
