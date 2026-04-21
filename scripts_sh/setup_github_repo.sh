#!/usr/bin/env bash
# =============================================================================
# setup_github_repo.sh
# Crea un repo público en GitHub y sube únicamente los datasets de data/raw/
#
# REQUISITOS:
#   - Git instalado y configurado (git config user.name / user.email)
#   - GitHub CLI instalado: https://cli.github.com/
#     Instalar en Windows: winget install --id GitHub.cli
#   - Autenticado en GitHub CLI: gh auth login
#
# USO:
#   bash setup_github_repo.sh
# =============================================================================

set -e  # Detener el script si cualquier comando falla

# -----------------------------------------------------------------------------
# CONFIGURACIÓN — edita estos valores
# -----------------------------------------------------------------------------
REPO_NAME="P8-Data-Analyst"
GITHUB_USER=""           # Déjalo vacío para autodetectarlo desde gh CLI
REPO_DESCRIPTION="Datasets AirBnB para el Proyecto IX — Data Analyst · Bootcamp IA P4 Factoría F5"
REPO_VISIBILITY="public" # public o private

# -----------------------------------------------------------------------------
# COLORES para la salida
# -----------------------------------------------------------------------------
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # Sin color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Setup GitHub Repo — P8-Data-Analyst  ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# -----------------------------------------------------------------------------
# 1. Verificar que gh CLI está instalado
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[1/7] Verificando GitHub CLI...${NC}"
if ! command -v gh &> /dev/null; then
    echo -e "${RED}ERROR: GitHub CLI no está instalado.${NC}"
    echo "Instálalo con: winget install --id GitHub.cli"
    echo "Después ejecuta: gh auth login"
    exit 1
fi
echo "✅ GitHub CLI encontrado: $(gh --version | head -1)"

# -----------------------------------------------------------------------------
# 2. Verificar autenticación
# -----------------------------------------------------------------------------
echo ""
echo -e "${YELLOW}[2/7] Verificando autenticación en GitHub...${NC}"
if ! gh auth status &> /dev/null; then
    echo -e "${RED}ERROR: No estás autenticado en GitHub CLI.${NC}"
    echo "Ejecuta: gh auth login"
    exit 1
fi
echo "✅ Autenticado correctamente"

# Autodetectar usuario si no se especificó
if [ -z "$GITHUB_USER" ]; then
    GITHUB_USER=$(gh api user --jq '.login')
    echo "   Usuario detectado: $GITHUB_USER"
fi

# -----------------------------------------------------------------------------
# 3. Verificar que el .gitignore protege los archivos sensibles
# -----------------------------------------------------------------------------
echo ""
echo -e "${YELLOW}[3/7] Verificando .gitignore (seguridad)...${NC}"

GITIGNORE_FILE=".gitignore"
SENSITIVE_FILES=("credentials.json" "token.json" "client_secret*.json")
GITIGNORE_UPDATED=false

# Crear .gitignore si no existe
if [ ! -f "$GITIGNORE_FILE" ]; then
    touch "$GITIGNORE_FILE"
    echo "   Creado .gitignore"
fi

for pattern in "${SENSITIVE_FILES[@]}"; do
    if ! grep -qF "$pattern" "$GITIGNORE_FILE" 2>/dev/null; then
        echo "$pattern" >> "$GITIGNORE_FILE"
        echo -e "   ${YELLOW}Añadido a .gitignore: $pattern${NC}"
        GITIGNORE_UPDATED=true
    fi
done

# Añadir también otros patrones recomendados si no están
RECOMMENDED=(
    ".venv/"
    "__pycache__/"
    "*.pyc"
    "*.log"
    ".ipynb_checkpoints/"
    "drive_links.json"
    "docs/tmp/"
    "main.py"
)

for pattern in "${RECOMMENDED[@]}"; do
    if ! grep -qF "$pattern" "$GITIGNORE_FILE" 2>/dev/null; then
        echo "$pattern" >> "$GITIGNORE_FILE"
        GITIGNORE_UPDATED=true
    fi
done

if [ "$GITIGNORE_UPDATED" = true ]; then
    echo "   ✅ .gitignore actualizado con patrones de seguridad"
else
    echo "   ✅ .gitignore ya estaba correctamente configurado"
fi

# Verificar que credentials.json no está siendo rastreado por git
if git ls-files --error-unmatch credentials.json &>/dev/null 2>&1; then
    echo -e "${RED}   ⚠️  credentials.json ya está rastreado por git. Eliminándolo del índice...${NC}"
    git rm --cached credentials.json
    echo "   ✅ Eliminado del índice git (el archivo local no se borra)"
fi

if git ls-files --error-unmatch token.json &>/dev/null 2>&1; then
    echo -e "${RED}   ⚠️  token.json ya está rastreado por git. Eliminándolo del índice...${NC}"
    git rm --cached token.json
fi

# -----------------------------------------------------------------------------
# 4. Verificar que data/raw/ existe y tiene los datasets
# -----------------------------------------------------------------------------
echo ""
echo -e "${YELLOW}[4/7] Verificando datasets en data/raw/...${NC}"

if [ ! -d "data/raw" ]; then
    echo -e "${RED}ERROR: No se encuentra la carpeta data/raw/${NC}"
    exit 1
fi

NUM_FILES=$(ls data/raw/ | wc -l)
echo "   ✅ Encontrados $NUM_FILES archivos en data/raw/"
ls data/raw/ | sed 's/^/      /'

# -----------------------------------------------------------------------------
# 5. Crear el repositorio en GitHub
# -----------------------------------------------------------------------------
echo ""
echo -e "${YELLOW}[5/7] Creando repositorio en GitHub...${NC}"

# Comprobar si el repo ya existe
if gh repo view "$GITHUB_USER/$REPO_NAME" &>/dev/null 2>&1; then
    echo -e "   ${YELLOW}El repositorio $GITHUB_USER/$REPO_NAME ya existe. Usando el existente.${NC}"
else
    gh repo create "$REPO_NAME" \
        --description "$REPO_DESCRIPTION" \
        --"$REPO_VISIBILITY" \
        --source=. \
        --remote=origin \
        --push=false
    echo "   ✅ Repositorio creado: https://github.com/$GITHUB_USER/$REPO_NAME"
fi

# Asegurarse de que el remote origin apunta al repo correcto
REMOTE_URL="https://github.com/$GITHUB_USER/$REPO_NAME.git"
if git remote get-url origin &>/dev/null 2>&1; then
    git remote set-url origin "$REMOTE_URL"
    echo "   ✅ Remote origin actualizado: $REMOTE_URL"
else
    git remote add origin "$REMOTE_URL"
    echo "   ✅ Remote origin añadido: $REMOTE_URL"
fi

# -----------------------------------------------------------------------------
# 6. Commit y push de los datasets
# -----------------------------------------------------------------------------
echo ""
echo -e "${YELLOW}[6/7] Haciendo commit y push de los datasets...${NC}"

# Asegurarse de que estamos en la rama main
git checkout -b main 2>/dev/null || git checkout main

# Añadir solo los archivos que queremos
git add .gitignore
git add data/raw/
git add pyproject.toml
git add uv.lock
git add .python-version

# README mínimo si no existe
if [ ! -f "README.md" ] || [ ! -s "README.md" ]; then
cat > README.md << 'EOF'
# P8-Data-Analyst

Datasets AirBnB para el Proyecto IX — Data Analyst  
Bootcamp IA P4 · Factoría F5 Madrid

## Datasets disponibles

| Archivo | Ciudad |
|---|---|
| madrid_airbnb.xlsx | Madrid |
| london_airbnb.xlsx | Londres |
| milan_airbnb.xlsx | Milán |
| london_airbnb.csv | Londres (histórico) |
| milan_airbnb.csv | Milán (histórico) |
| madrid_airbnb.csv | Madrid (histórico) |
| sydney_airbnb.csv | Sydney |
| NY_airbnb.csv | Nueva York |
| tokyo_airbnb.csv | Tokio |

## Fuente
[Inside AirBnB](http://insideairbnb.com)
EOF
fi
git add README.md

# Commit
git commit -m "feat: añadir datasets AirBnB en data/raw

- madrid, london, milan, sydney, NY, tokyo
- formatos csv y xlsx según disponibilidad
- fuente: Inside AirBnB / Google Drive Factoría F5"

# Push
git push -u origin main

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ COMPLETADO${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Repositorio disponible en:"
echo "  https://github.com/$GITHUB_USER/$REPO_NAME"
echo ""
echo "URLs raw de los datasets (para usar en notebooks):"
for f in data/raw/*.csv data/raw/*.xlsx; do
    fname=$(basename "$f")
    echo "  https://raw.githubusercontent.com/$GITHUB_USER/$REPO_NAME/main/data/raw/$fname"
done
