#!/usr/bin/env bash
# Despliega la app "Largada de Regata" a GitHub Pages en un solo comando.
#
# REQUISITOS (una sola vez):
#   1. Tener git instalado.
#   2. Tener GitHub CLI instalado: https://cli.github.com
#   3. Ejecutar una vez: gh auth login   (y seguir los pasos para loguearte)
#
# USO:
#   Parate dentro de la carpeta con los archivos de la app (index.html, manifest.json, etc.)
#   y corré:  bash deploy.sh
#
# También podés pasarle un nombre de repo distinto:
#   bash deploy.sh mi-nombre-de-repo

set -e

REPO_NAME="${1:-largada-regata}"

if ! command -v git &> /dev/null; then
  echo "❌ No encontré 'git'. Instalalo primero: https://git-scm.com/downloads"
  exit 1
fi
if ! command -v gh &> /dev/null; then
  echo "❌ No encontré 'gh' (GitHub CLI). Instalalo primero: https://cli.github.com"
  exit 1
fi
if [ ! -f "index.html" ]; then
  echo "❌ No veo un index.html en esta carpeta. Parate dentro de la carpeta de la app y volvé a correr el script."
  exit 1
fi

echo "🚀 Desplegando '$REPO_NAME' a GitHub Pages..."

# Inicializa el repo local si hace falta
if [ ! -d ".git" ]; then
  git init -q
  git branch -M main
fi

git add -A
git commit -q -m "Deploy $(date '+%Y-%m-%d %H:%M')" || echo "ℹ️  Nada nuevo para commitear, sigo con lo que ya hay."

# Crea el repo en GitHub (si no existe) y sube el código
if gh repo view "$REPO_NAME" &> /dev/null; then
  echo "ℹ️  El repo '$REPO_NAME' ya existe, actualizando..."
  git remote add origin "$(gh repo view "$REPO_NAME" --json url -q .url).git" 2>/dev/null || true
  git push -u origin main --force
else
  gh repo create "$REPO_NAME" --public --source=. --remote=origin --push
fi

# Habilita GitHub Pages sirviendo desde la rama main, carpeta raíz
gh api --method POST "repos/{owner}/$REPO_NAME/pages" \
  -f "source[branch]=main" -f "source[path]=/" &> /dev/null || \
gh api --method PUT "repos/{owner}/$REPO_NAME/pages" \
  -f "source[branch]=main" -f "source[path]=/" &> /dev/null || true

USER=$(gh api user -q .login)
echo ""
echo "✅ Listo. En 1-2 minutos vas a poder abrir:"
echo "   https://${USER}.github.io/${REPO_NAME}/"
