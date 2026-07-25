# Despliega la app "Largada de Regata" a GitHub Pages en un solo comando (Windows / PowerShell).
#
# REQUISITOS (una sola vez):
#   1. Tener Git instalado: https://git-scm.com/downloads
#   2. Tener GitHub CLI instalado: https://cli.github.com
#   3. Ejecutar una vez en PowerShell:  gh auth login   (y seguir los pasos para loguearte)
#
# USO:
#   Abrí PowerShell dentro de la carpeta con los archivos de la app (index.html, manifest.json, etc.)
#   y corré:   .\deploy.ps1
#
# También podés pasarle un nombre de repo distinto:
#   .\deploy.ps1 -RepoName "mi-nombre-de-repo"
#
# Si Windows bloquea la ejecución de scripts la primera vez, corré antes (una sola vez):
#   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

param(
    [string]$RepoName = "largada-regata"
)

$ErrorActionPreference = "Stop"

function Test-Command($name) {
    return $null -ne (Get-Command $name -ErrorAction SilentlyContinue)
}

if (-not (Test-Command "git")) {
    Write-Host "❌ No encontré 'git'. Instalalo primero: https://git-scm.com/downloads" -ForegroundColor Red
    exit 1
}
if (-not (Test-Command "gh")) {
    Write-Host "❌ No encontré 'gh' (GitHub CLI). Instalalo primero: https://cli.github.com" -ForegroundColor Red
    exit 1
}
if (-not (Test-Path "index.html")) {
    Write-Host "❌ No veo un index.html en esta carpeta. Parate dentro de la carpeta de la app y volvé a correr el script." -ForegroundColor Red
    exit 1
}

Write-Host "🚀 Desplegando '$RepoName' a GitHub Pages..." -ForegroundColor Cyan

# Inicializa el repo local si hace falta
if (-not (Test-Path ".git")) {
    git init -q
    git branch -M main
}

git add -A
$fecha = Get-Date -Format "yyyy-MM-dd HH:mm"
git commit -q -m "Deploy $fecha" 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ℹ️  Nada nuevo para commitear, sigo con lo que ya hay." -ForegroundColor Yellow
}

# Crea el repo en GitHub (si no existe) y sube el código
$existe = $true
try {
    gh repo view $RepoName | Out-Null
} catch {
    $existe = $false
}

if ($existe) {
    Write-Host "ℹ️  El repo '$RepoName' ya existe, actualizando..." -ForegroundColor Yellow
    $url = gh repo view $RepoName --json url -q ".url"
    git remote add origin "$url.git" 2>$null
    git push -u origin main --force
} else {
    gh repo create $RepoName --public --source=. --remote=origin --push
}

# Habilita GitHub Pages sirviendo desde la rama main, carpeta raíz
try {
    gh api --method POST "repos/{owner}/$RepoName/pages" -f "source[branch]=main" -f "source[path]=/" | Out-Null
} catch {
    try {
        gh api --method PUT "repos/{owner}/$RepoName/pages" -f "source[branch]=main" -f "source[path]=/" | Out-Null
    } catch { }
}

$user = gh api user -q ".login"
Write-Host ""
Write-Host "✅ Listo. En 1-2 minutos vas a poder abrir:" -ForegroundColor Green
Write-Host "   https://$user.github.io/$RepoName/" -ForegroundColor Green
