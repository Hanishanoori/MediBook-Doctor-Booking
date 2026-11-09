@echo off
cd /d "%~dp0"
start "MediBook Backend" cmd /k call "%~dp0start-backend.bat"
start "MediBook Frontend" cmd /k call "%~dp0start-frontend.bat"
echo Two windows were opened: the backend and the frontend.
echo Wait until the backend window shows "Started MediBookApplication",
echo then open http://localhost:5173 in your browser.
pause
