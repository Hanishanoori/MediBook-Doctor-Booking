@echo off
title MediBook Frontend - React and Vite
cd /d "%~dp0frontend"

where node >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Node.js was not found on PATH.
  echo Install Node.js 18 or newer from https://nodejs.org then open a NEW Command Prompt.
  pause
  exit /b 1
)

if not exist node_modules (
  echo Installing frontend dependencies - first run only...
  call npm install
  if errorlevel 1 (
    echo [ERROR] npm install failed. Check your internet connection and try again.
    pause
    exit /b 1
  )
)

echo Starting the MediBook frontend on http://localhost:5173
echo Press Ctrl+C to stop.
echo.
call npm run dev
echo.
echo The frontend has stopped.
pause
