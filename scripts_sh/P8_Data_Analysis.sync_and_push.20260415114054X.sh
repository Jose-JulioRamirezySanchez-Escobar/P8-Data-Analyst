#!/usr/bin/env bash
# =============================================================================
# P8_Data_Analysis.sync_and_push.sh
#
# Workflow periódico de trabajo:
#
#   PASO 1 — Commitear cambios en el repo personal (P8-Data-Analyst)
#   PASO 2 — Promocionar archivos listos al repo del equipo (rama v_01)
#
# REPOSITORIOS:
#   Personal:  ~/Proyectos/P8-Data-Analyst
#   Equipo:    ~/Proyectos/P8_Data_Analysis  (rama v_01)
#
# CONVENCIONES DE COMMITS (Conventional Commits):
#   feat:     nueva funcionalidad o archivo de código
#   fix:      corrección de error
#   docs:     documentación (README, guiones, PDFs, markdown)
#   style:    formato, espaciado (sin cambios de lógica)
#   refactor: reestructuración de código sin cambiar comportamiento
#   test:     añadir o modificar tests
#   chore:    dependencias, configuración, mantenimiento
#   perf:     mejora de rendimiento
#   ci:       pipelines, GitHub Actions
#   build:    Dockerfile, pyproject.toml
#   revert:   revertir un commit anterior
#
# USO:
#   bash P8_Data_Analysis.sync_and_push.sh
#
# =============================================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

REPO_PERSONAL="$HOME/Proyectos/P8-Data-Analyst"
REPO_EQUIPO="$HOME/Proyectos/P8_Data_Analysis"
RAMA_PERSONAL="v_01"

# =============================================================================
# FUNCIONES AUXILIARES
# =============================================================================

titulo() {
    echo ""
    echo -e "${GREEN}============================================${NC}"
    echo -e "${GREEN}  $1${NC}"
    echo -e "${GREEN}============================================${NC}"
    echo ""
}

paso() {
    echo -e "${YELLOW}[$1] $2${NC}"
}

ok() {
    echo -e "  ${GREEN}✅ $1${NC}"
}

info() {
    echo -e "  ${CYAN}ℹ️  $1${NC}"
}

error() {
    echo -e "  ${RED}❌ $1${NC}"
    exit 1
}

confirmar() {
    echo -e "${YELLOW}$1 (s/n)${NC}"
    read -r resp
    [ "$resp" = "s" ]
}

# =============================================================================
# VERIFICACIONES PREVIAS
# =============================================================================

titulo "P8_Data_Analysis — Workflow periódico"

paso "0/3" "Verificando entorno..."

[ -d "$REPO_PERSONAL" ] || error "No se encuentra el repo personal: $REPO_PERSONAL"
[ -d "$REPO_EQUIPO"   ] || error "No se encuentra el repo del equipo: $REPO_EQUIPO
  Ejecuta primero: bash P8_Data_Analysis.clone_and_branch.20260415113031X.sh"

cd "$REPO_PERSONAL"
RAMA_ACTUAL_PERSONAL=$(git branch --show-current)
info "Repo personal — rama actual: $RAMA_ACTUAL_PERSONAL"

cd "$REPO_EQUIPO"
RAMA_ACTUAL_EQUIPO=$(git branch --show-current)
info "Repo equipo   — rama actual: $RAMA_ACTUAL_EQUIPO"

if [ "$RAMA_ACTUAL_EQUIPO" != "$RAMA_PERSONAL" ]; then
    echo -e "  ${YELLOW}⚠️  El repo del equipo no está en '$RAMA_PERSONAL'. Cambiando...${NC}"
    git checkout "$RAMA_PERSONAL" 2>/dev/null || git checkout -b "$RAMA_PERSONAL"
fi

# =============================================================================
# PASO 1 — COMMITEAR EN EL REPO PERSONAL
# =============================================================================

titulo "PASO 1 — Commitear en repo personal"
cd "$REPO_PERSONAL"

echo -e "${CYAN}Estado actual del repo personal:${NC}"
git status --short

# Comprobar si hay cambios
if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
    info "No hay cambios pendientes en el repo personal."
    CAMBIOS_PERSONAL=false
else
    CAMBIOS_PERSONAL=true
    echo ""

    if confirmar "¿Quieres añadir todos los cambios al staging? (git add -A)"; then
        git add -A
        ok "Cambios añadidos al staging"
    else
        echo "  Introduce los archivos a añadir (uno por línea, línea vacía para terminar):"
        while IFS= read -r archivo; do
            [ -z "$archivo" ] && break
            git add "$archivo"
            ok "Añadido: $archivo"
        done
    fi

    echo ""
    echo -e "${CYAN}Archivos en staging:${NC}"
    git diff --cached --name-status

    echo ""
    echo -e "${CYAN}¿Usar archivo de mensaje de commit existente o escribir uno nuevo?${NC}"
    echo "  a) Escribir mensaje ahora"
    echo "  b) Usar archivo commit.*.txt existente"
    read -r opcion_commit

    if [ "$opcion_commit" = "b" ]; then
        echo "  Archivos de commit disponibles:"
        ls commit.*.txt 2>/dev/null || echo "  (ninguno encontrado)"
        echo "  Introduce el nombre del archivo:"
        read -r archivo_commit
        git commit -F "$archivo_commit"
    else
        echo "  Introduce el prefijo del commit (feat/fix/docs/chore/refactor/...):"
        read -r prefijo
        echo "  Introduce la descripción breve:"
        read -r descripcion
        echo "  Introduce descripción larga (opcional, Enter para omitir):"
        read -r descripcion_larga

        if [ -n "$descripcion_larga" ]; then
            git commit -m "${prefijo}: ${descripcion}" -m "$descripcion_larga"
        else
            git commit -m "${prefijo}: ${descripcion}"
        fi
    fi

    ok "Commit realizado en repo personal"

    echo ""
    if confirmar "¿Hacer push al repo personal ahora?"; then
        git push origin "$RAMA_ACTUAL_PERSONAL"
        ok "Push realizado al repo personal"
    fi
fi

# =============================================================================
# PASO 2 — ACTUALIZAR DESDE EL EQUIPO (pull)
# =============================================================================

titulo "PASO 2 — Sincronizar con el repo del equipo"
cd "$REPO_EQUIPO"

echo -e "${CYAN}Actualizando desde origin/$RAMA_PERSONAL...${NC}"
git fetch origin
git pull origin "$RAMA_PERSONAL" --rebase 2>/dev/null || {
    echo -e "  ${YELLOW}⚠️  No hay rama remota aún o no hay cambios del equipo.${NC}"
}
ok "Repo del equipo sincronizado"

# También sincronizar con la rama base del equipo
RAMA_BASE=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null \
    | sed 's@^refs/remotes/origin/@@' || echo "main")
echo ""
info "Actualizando referencia a origin/$RAMA_BASE..."
git fetch origin "$RAMA_BASE" 2>/dev/null || true

# =============================================================================
# PASO 3 — PROMOCIONAR ARCHIVOS AL REPO DEL EQUIPO
# =============================================================================

titulo "PASO 3 — Promocionar archivos al repo del equipo"
cd "$REPO_EQUIPO"

echo -e "${CYAN}¿Qué archivos quieres promocionar desde tu repo personal?${NC}"
echo ""
echo "  Introduce las rutas relativas al repo personal, una por línea."
echo "  Ejemplo: notebooks/01_eda_airbnb.ipynb"
echo "  Ejemplo: docs/guion_P8_Data_Analyst_v2.md"
echo "  (línea vacía para terminar)"
echo ""

ARCHIVOS_A_PROMOVER=()
while IFS= read -r archivo; do
    [ -z "$archivo" ] && break
    ORIGEN="$REPO_PERSONAL/$archivo"
    if [ ! -f "$ORIGEN" ]; then
        echo -e "  ${RED}No encontrado: $ORIGEN${NC}"
    else
        ARCHIVOS_A_PROMOVER+=("$archivo")
        echo -e "  ${GREEN}✅ Encontrado: $archivo${NC}"
    fi
done

if [ ${#ARCHIVOS_A_PROMOVER[@]} -eq 0 ]; then
    info "No se seleccionaron archivos para promocionar. Saliendo del paso 3."
else
    echo ""
    echo -e "${CYAN}Copiando archivos...${NC}"
    for archivo in "${ARCHIVOS_A_PROMOVER[@]}"; do
        ORIGEN="$REPO_PERSONAL/$archivo"
        DESTINO="$REPO_EQUIPO/$archivo"
        DESTINO_DIR=$(dirname "$DESTINO")
        mkdir -p "$DESTINO_DIR"
        cp "$ORIGEN" "$DESTINO"
        ok "Copiado: $archivo"
    done

    echo ""
    echo -e "${CYAN}Estado del repo del equipo tras la copia:${NC}"
    git status --short

    echo ""
    git add "${ARCHIVOS_A_PROMOVER[@]}"

    echo "  Introduce el prefijo del commit (feat/fix/docs/chore/...):"
    read -r prefijo_eq
    echo "  Introduce la descripción:"
    read -r desc_eq

    # Buscar archivo de commit en repo personal
    ARCHIVO_COMMIT_SUGERIDO=""
    for archivo in "${ARCHIVOS_A_PROMOVER[@]}"; do
        NOMBRE=$(basename "$archivo")
        POSIBLE="$REPO_PERSONAL/commit.${NOMBRE}.txt"
        if [ -f "$POSIBLE" ]; then
            ARCHIVO_COMMIT_SUGERIDO="$POSIBLE"
            break
        fi
    done

    if [ -n "$ARCHIVO_COMMIT_SUGERIDO" ] && \
       confirmar "¿Usar mensaje de commit desde '$ARCHIVO_COMMIT_SUGERIDO'?"; then
        git commit -F "$ARCHIVO_COMMIT_SUGERIDO"
    else
        git commit -m "${prefijo_eq}: ${desc_eq}"
    fi

    ok "Commit realizado en repo del equipo"

    echo ""
    if confirmar "¿Hacer push a origin/$RAMA_PERSONAL?"; then
        git push origin "$RAMA_PERSONAL"
        ok "Push realizado al repo del equipo"
        echo ""
        info "Recuerda abrir un Pull Request cuando el trabajo esté listo para revisión:"
        echo "  https://github.com/Bootcamp-IA-P6/P8_Data_Analysis/compare/v_01"
    fi
fi

# =============================================================================
# RESUMEN FINAL
# =============================================================================

titulo "RESUMEN"

echo -e "${CYAN}Repo personal:${NC}"
cd "$REPO_PERSONAL"
git log --oneline -3

echo ""
echo -e "${CYAN}Repo equipo (rama $RAMA_PERSONAL):${NC}"
cd "$REPO_EQUIPO"
git log --oneline -3

echo ""
ok "Workflow completado"
