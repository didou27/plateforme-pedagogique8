@echo off
setlocal
cd /d "%~dp0"

where node >nul 2>nul
if errorlevel 1 (
  echo ERROR: Node.js is not installed.
  echo Install it from https://nodejs.org and run this file again.
  pause
  exit /b 1
)

where cloudflared >nul 2>nul
if errorlevel 1 (
  echo Cloudflared is required to create a secure public HTTPS link.
  echo.
  where winget >nul 2>nul
  if errorlevel 1 (
    echo Install Cloudflared, then run this file again:
    echo https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/
    pause
    exit /b 1
  )
  echo Installing Cloudflared...
  winget install --id Cloudflare.cloudflared --exact --accept-package-agreements --accept-source-agreements
  if errorlevel 1 (
    echo ERROR: Cloudflared installation failed.
    pause
    exit /b 1
  )
  set "PATH=%PATH%;%LOCALAPPDATA%\Microsoft\WinGet\Links"
)

set "PORT=3000"
echo.
echo ============================================================
echo  Pedagogical Platform - Public HTTPS Link
echo ============================================================
echo  A trycloudflare.com URL will appear below.
echo  Open or copy that HTTPS URL from any computer or browser.
echo  Keep this terminal and this computer running.
echo  Press Ctrl+C to stop public access.
echo ============================================================
echo.

start "Pedagogical Platform Server" /min cmd /c "cd /d ""%~dp0"" && set PORT=3000 && node server.js"

powershell -NoProfile -Command ^
  "$ok=$false; for($i=0;$i -lt 30;$i++){try{$r=Invoke-WebRequest -UseBasicParsing http://127.0.0.1:3000/api/health -TimeoutSec 1;if($r.StatusCode -eq 200){$ok=$true;break}}catch{};Start-Sleep -Milliseconds 500};if(-not $ok){exit 1}"
if errorlevel 1 (
  echo ERROR: The platform server did not start on port 3000.
  pause
  exit /b 1
)

if defined CLOUDFLARE_TUNNEL_TOKEN (
  echo Starting configured Cloudflare Tunnel...
  cloudflared tunnel --no-autoupdate run --token "%CLOUDFLARE_TUNNEL_TOKEN%"
) else (
  echo Starting temporary Cloudflare Quick Tunnel...
  cloudflared tunnel --no-autoupdate --url http://127.0.0.1:3000
)

echo.
echo Public access stopped.
pause