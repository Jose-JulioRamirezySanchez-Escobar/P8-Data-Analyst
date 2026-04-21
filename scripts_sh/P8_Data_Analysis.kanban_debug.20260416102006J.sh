#!/usr/bin/env bash
# =============================================================================
# P8_Data_Analysis.kanban_debug.20260416102006J.sh
# Diagnóstico del acceso al proyecto GitHub
# =============================================================================

ORG="Bootcamp-IA-P6"
PROJECT_NUMBER="46"

echo "=== DIAGNÓSTICO KANBAN ==="
echo ""

echo "[1] Versión de gh CLI:"
gh --version
echo ""

echo "[2] Usuario autenticado:"
gh auth status
echo ""

echo "[3] Permisos del token actual:"
gh auth status --show-token 2>/dev/null | head -5 || echo "(no se puede mostrar el token)"
echo ""

echo "[4] Proyectos accesibles en la organización $ORG:"
gh project list --owner "$ORG" 2>&1
echo ""

echo "[5] Intentando listar ítems del proyecto #$PROJECT_NUMBER (CON errores visibles):"
gh project item-list "$PROJECT_NUMBER" \
    --owner "$ORG" \
    --format json \
    --limit 5 2>&1
echo ""

echo "[6] Intentando via API GraphQL directamente:"
gh api graphql -f query='
{
  organization(login: "Bootcamp-IA-P6") {
    projectV2(number: 46) {
      title
      items(first: 5) {
        nodes {
          id
          content {
            ... on Issue { title }
            ... on DraftIssue { title }
          }
        }
      }
    }
  }
}' 2>&1
echo ""

echo "=== FIN DIAGNÓSTICO ==="
