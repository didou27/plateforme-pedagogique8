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

set "PORT=3000"
echo.
echo ============================================================
echo  Pedagogical Platform - Local Network
echo ============================================================
echo  Keep this terminal and this computer running.
echo  Share the "Network access" URL printed below with devices
echo  connected to the same Wi-Fi or local network.
echo.
echo  If Windows Firewall asks for permission, choose Allow access.
echo ============================================================
echo.

node server.js
pause