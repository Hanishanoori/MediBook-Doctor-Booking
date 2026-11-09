@echo off
title MediBook Backend - Spring Boot
cd /d "%~dp0backend"

where java >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Java was not found on PATH.
  echo Install a JDK 17 or newer - Java 25 is fine - then open a NEW Command Prompt.
  pause
  exit /b 1
)

echo Starting the MediBook backend on http://localhost:8080
echo First run only: Maven and all dependencies are downloaded - internet needed, may take a few minutes.
echo Wait for the line "Started MediBookApplication". Press Ctrl+C to stop.
echo.
call mvnw.cmd spring-boot:run
echo.
echo The backend has stopped.
pause
