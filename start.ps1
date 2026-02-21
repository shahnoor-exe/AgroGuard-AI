# ============================================================
#  AgroGuard AI — START SCRIPT
#  Run this every time you want to launch the app.
#  Opens:
#    • Flask backend on  http://localhost:5000
#    • Flutter web app  (auto-opens in browser)
# ============================================================

$Root    = Split-Path -Parent $MyInvocation.MyCommand.Path
$Backend = Join-Path $Root "smartcrop_backend"
$Mobile  = Join-Path $Root "smartcrop_mobile"
$venvPython = Join-Path $Backend "venv\Scripts\python.exe"

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  AgroGuard AI - Starting..." -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# ── Guard: check venv exists ─────────────────────────────────
if (-not (Test-Path $venvPython)) {
    Write-Host ""
    Write-Host "  ERROR: Virtual environment not found." -ForegroundColor Red
    Write-Host "  Please run  .\setup.ps1  first." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# ── Guard: check Flutter ─────────────────────────────────────
$flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterCmd) {
    Write-Host ""
    Write-Host "  ERROR: Flutter not found in PATH." -ForegroundColor Red
    Write-Host "  Install Flutter from https://flutter.dev" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# ── 1. Kill any old instances on port 5000 ───────────────────
$old = netstat -ano | Select-String "0.0.0.0:5000" | ForEach-Object {
    ($_ -split "\s+")[-1]
} | Select-Object -Unique
foreach ($pid in $old) {
    if ($pid -match '^\d+$') {
        Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
    }
}

# ── 2. Start Flask backend in a new window ───────────────────
Write-Host "`n[1/2] Starting Flask backend on http://localhost:5000 ..." -ForegroundColor Yellow
$backendCmd = "`$host.UI.RawUI.WindowTitle='AgroGuard Backend'; & '$venvPython' '$Backend\app.py'"
Start-Process powershell -ArgumentList "-NoExit", "-Command", $backendCmd

# Give Flask a moment to start
Write-Host "  Waiting for backend to start..." -ForegroundColor Gray
$timeout = 15
$started = $false
for ($i = 0; $i -lt $timeout; $i++) {
    Start-Sleep -Seconds 1
    $listening = netstat -an | Select-String "0.0.0.0:5000"
    if ($listening) {
        $started = $true
        break
    }
}

if ($started) {
    Write-Host "  Backend is UP at http://localhost:5000" -ForegroundColor Green
} else {
    Write-Host "  WARNING: Backend may still be starting..." -ForegroundColor Yellow
}

# ── 3. Start Flutter web app ─────────────────────────────────
Write-Host "`n[2/2] Starting Flutter web app..." -ForegroundColor Yellow
Push-Location $Mobile
Start-Process powershell -ArgumentList "-NoExit", "-Command", `
    "`$host.UI.RawUI.WindowTitle='AgroGuard Flutter'; Set-Location '$Mobile'; flutter run -d edge"
Pop-Location

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  Both services launched!" -ForegroundColor Green
Write-Host "  Backend : http://localhost:5000" -ForegroundColor White
Write-Host "  Flutter : opens in Microsoft Edge" -ForegroundColor White
Write-Host ""
Write-Host "  Close the two new terminal windows" -ForegroundColor Gray
Write-Host "  to stop the app." -ForegroundColor Gray
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
