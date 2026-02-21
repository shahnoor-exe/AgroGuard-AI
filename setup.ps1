# ============================================================
#  AgroGuard AI — ONE-TIME SETUP SCRIPT
#  Run this ONCE to install all dependencies.
#  After this, use  .\start.ps1  every time you want to run.
# ============================================================

$Root    = Split-Path -Parent $MyInvocation.MyCommand.Path
$Backend = Join-Path $Root "smartcrop_backend"
$Mobile  = Join-Path $Root "smartcrop_mobile"

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  AgroGuard AI - Setup" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# -- 1. Check Python -----------------------------------------------
Write-Host "`n[1/4] Checking Python..." -ForegroundColor Yellow
$pyCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pyCmd) {
    Write-Host "  ERROR: Python not found. Install Python 3.10+ from https://python.org" -ForegroundColor Red
    exit 1
}
python --version
Write-Host "  Python OK" -ForegroundColor Green

# -- 2. Backend venv & packages ------------------------------------
Write-Host "`n[2/4] Setting up Python virtual environment..." -ForegroundColor Yellow
$venvPath = Join-Path $Backend "venv"

if (Test-Path $venvPath) {
    # Validate existing venv points to an accessible python
    $venvPython = Join-Path $venvPath "Scripts\python.exe"
    $ok = & $venvPython -c "print('ok')" 2>&1
    if ($ok -notmatch "ok") {
        Write-Host "  Existing venv is broken - recreating..." -ForegroundColor Yellow
        Remove-Item -Recurse -Force $venvPath
    }
}

if (-not (Test-Path $venvPath)) {
    Write-Host "  Creating virtual environment..." -ForegroundColor Yellow
    python -m venv (Join-Path $Backend "venv")
}
Write-Host "  Virtual environment OK" -ForegroundColor Green

# -- 3. Install / upgrade Python packages --------------------------
Write-Host "`n[3/4] Installing Python packages (this may take a few minutes)..." -ForegroundColor Yellow
$pip = Join-Path $Backend "venv\Scripts\pip.exe"
& $pip install --upgrade pip --quiet
& $pip install -r (Join-Path $Backend "requirements.txt")
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ERROR: pip install failed. Check the output above." -ForegroundColor Red
    exit 1
}
Write-Host "  Python packages OK" -ForegroundColor Green

# -- 4. Flutter pub get --------------------------------------------
Write-Host "`n[4/4] Installing Flutter dependencies..." -ForegroundColor Yellow
$flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterCmd) {
    Write-Host "  WARNING: Flutter not found in PATH. Skipping Flutter setup." -ForegroundColor Yellow
    Write-Host "  Install Flutter from https://flutter.dev and re-run this script." -ForegroundColor Yellow
} else {
    Push-Location $Mobile
    flutter pub get
    Pop-Location
    Write-Host "  Flutter dependencies OK" -ForegroundColor Green
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  Setup complete!" -ForegroundColor Green
Write-Host "  Run  .\start.ps1  to launch the app" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
