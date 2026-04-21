#!/usr/bin/env bash
# =============================================================================
# push_docs_v2.sh
# Añade, commitea y sube los tres archivos de documentación al repo GitHub.
#
# Archivos a subir:
#   - docs/P8-Data-Analyst.pp39-44.20260414134628M.pdf
#   - notebooks/01_eda_airbnb.ipynb
#   - docs/guion_P8_Data_Analyst_v2.md
#
# Archivos de mensaje de commit (deben estar en la raíz del proyecto):
#   - commit.P8-Data-Analyst.pp39-44.20260414134628M.pdf.txt
#   - commit.01_eda_airbnb.ipynb.txt
#   - commit.guion_P8_Data_Analyst_v2.md.txt
#
# CONVENCIONES DE COMMITS (Conventional Commits):
#   feat:     nueva funcionalidad o archivo de código
#   fix:      corrección de error
#   docs:     documentación (README, guiones, PDFs, markdown)
#   style:    formato, espaciado (sin cambios de lógica)
#   refactor: reestructuración de código sin cambiar comportamiento
#   test:     añadir o modificar tests
#   chore:    tareas de mantenimiento (dependencias, configuración)
#   perf:     mejora de rendimiento
#   ci:       cambios en integración continua / pipelines
#   build:    cambios en el sistema de build (Dockerfile, pyproject.toml)
#   revert:   revertir un commit anterior
#
# USO:
#   bash push_docs_v2.sh
# =============================================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Push documentación — P8-Data-Analyst  ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# -----------------------------------------------------------------------------
# Verificar que estamos en la rama correcta
# -----------------------------------------------------------------------------
RAMA_ACTUAL=$(git branch --show-current)
echo -e "${YELLOW}Rama actual: $RAMA_ACTUAL${NC}"

if [ "$RAMA_ACTUAL" != "main" ] && [ "$RAMA_ACTUAL" != "develop" ]; then
    echo -e "${YELLOW}⚠️  No estás en main ni develop. ¿Continuar en '$RAMA_ACTUAL'? (s/n)${NC}"
    read -r respuesta
    if [ "$respuesta" != "s" ]; then
        echo "Cancelado."
        exit 0
    fi
fi

# -----------------------------------------------------------------------------
# Crear carpetas si no existen
# -----------------------------------------------------------------------------
mkdir -p docs notebooks

# -----------------------------------------------------------------------------
# Verificar que los archivos fuente existen
# -----------------------------------------------------------------------------
echo ""
echo -e "${YELLOW}[1/4] Verificando archivos fuente...${NC}"

FILES_NEEDED=(
    "P8-Data-Analyst.pp39-44.20260414134628M.pdf"
    "01_eda_airbnb.ipynb"
    "guion_P8_Data_Analyst_v2.md"
)

COMMIT_FILES=(
    "commit.P8-Data-Analyst.pp39-44.20260414134628M.pdf.txt"
    "commit.01_eda_airbnb.ipynb.txt"
    "commit.guion_P8_Data_Analyst_v2.md.txt"
)

for f in "${FILES_NEEDED[@]}" "${COMMIT_FILES[@]}"; do
    if [ ! -f "$f" ]; then
        echo -e "${RED}ERROR: No se encuentra '$f' en la raíz del proyecto.${NC}"
        echo "Asegúrate de copiar los archivos antes de ejecutar este script."
        exit 1
    fi
    echo "  ✅ $f"
done

# -----------------------------------------------------------------------------
# Mover archivos a sus carpetas definitivas
# -----------------------------------------------------------------------------
echo ""
echo -e "${YELLOW}[2/4] Organizando archivos...${NC}"

# PDF y guión → docs/
cp "P8-Data-Analyst.pp39-44.20260414134628M.pdf" "docs/"
cp "guion_P8_Data_Analyst_v2.md" "docs/"

# Notebook → notebooks/
cp "01_eda_airbnb.ipynb" "notebooks/"

echo "  ✅ docs/P8-Data-Analyst.pp39-44.20260414134628M.pdf"
echo "  ✅ docs/guion_P8_Data_Analyst_v2.md"
echo "  ✅ notebooks/01_eda_airbnb.ipynb"

# -----------------------------------------------------------------------------
# Commit 1: PDF del guión
# -----------------------------------------------------------------------------
echo ""
echo -e "${YELLOW}[3/4] Commiteando archivos...${NC}"

echo ""
echo "--- Commit 1/3: PDF guión ---"
git add "docs/P8-Data-Analyst.pp39-44.20260414134628M.pdf"
git commit -F "commit.P8-Data-Analyst.pp39-44.20260414134628M.pdf.txt"
echo "  ✅ Commit 1 realizado"

# Commit 2: Notebook EDA
echo ""
echo "--- Commit 2/3: Notebook EDA ---"
git add "notebooks/01_eda_airbnb.ipynb"
git commit -F "commit.01_eda_airbnb.ipynb.txt"
echo "  ✅ Commit 2 realizado"

# Commit 3: Guión Markdown
echo ""
echo "--- Commit 3/3: Guión Markdown ---"
git add "docs/guion_P8_Data_Analyst_v2.md"
git commit -F "commit.guion_P8_Data_Analyst_v2.md.txt"
echo "  ✅ Commit 3 realizado"

# -----------------------------------------------------------------------------
# Push
# -----------------------------------------------------------------------------
echo ""
echo -e "${YELLOW}[4/4] Haciendo push a origin/$RAMA_ACTUAL...${NC}"
git push origin "$RAMA_ACTUAL"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ COMPLETADO${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Repositorio: https://github.com/Jose-JulioRamirezySanchez-Escobar/P8-Data-Analyst"
echo ""
echo "Commits realizados:"
git log --oneline -3
