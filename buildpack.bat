@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
title EndrekPack Builder

cd /d "%~dp0"

:: ============================================================
:: GET REAL ANSI ESCAPE CHARACTER
:: ============================================================

for /F "delims=" %%A in ('echo prompt $E^| cmd') do set "ESC=%%A"

set "RESET=!ESC![0m"
set "RED=!ESC![91m"
set "GREEN=!ESC![92m"
set "YELLOW=!ESC![93m"
set "CYAN=!ESC![96m"
set "WHITE=!ESC![97m"
set "GRAY=!ESC![90m"
set "MAGENTA=!ESC![95m"

:: ============================================================
:: HEADER
:: ============================================================

cls

echo.
echo !CYAN!    ███████╗███╗   ██╗██████╗ ██████╗ ███████╗██╗  ██╗
echo !CYAN!    ██╔════╝████╗  ██║██╔══██╗██╔══██╗██╔════╝██║ ██╔╝
echo !CYAN!    █████╗  ██╔██╗ ██║██║  ██║██████╔╝█████╗  █████╔╝
echo !CYAN!    ██╔══╝  ██║╚██╗██║██║  ██║██╔══██╗██╔══╝  ██╔═██╗
echo !CYAN!    ███████╗██║ ╚████║██████╔╝██║  ██║███████╗██║  ██╗
echo !CYAN!    ╚══════╝╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝!RESET!
echo.
echo !MAGENTA!                    P A C K   B U I L D E R!RESET!
echo.
echo !GRAY!    ──────────────────────────────────────────────────────────────!RESET!
echo.

:: ============================================================
:: CHECK FILES
:: ============================================================

echo !WHITE![ !CYAN!01!WHITE! ] Checking files...!RESET!
echo.

if not exist "assets\" (
    echo !RED!    [ERROR] assets folder not found.!RESET!
    echo.
    pause
    exit /b 1
)

echo !GREEN!    [ OK ] !WHITE!assets\ found!RESET!

if not exist "pack.mcmeta" (
    echo !RED!    [ERROR] pack.mcmeta not found.!RESET!
    echo.
    pause
    exit /b 1
)

echo !GREEN!    [ OK ] !WHITE!pack.mcmeta found!RESET!
echo.

:: ============================================================
:: CHECK GIT REPOSITORY
:: ============================================================

echo !WHITE![ !CYAN!02!WHITE! ] Checking Git repository...!RESET!
echo.

git rev-parse --is-inside-work-tree >nul 2>&1

if errorlevel 1 (
    echo !RED!    ╔══════════════════════════════════════════════════════╗
    echo !RED!    ║  ERROR: This folder is not a Git repository.       ║
    echo !RED!    ║                                                      ║
    echo !RED!    ║  Run "git init" here or place build.bat inside     ║
    echo !RED!    ║  your existing Git repository.                     ║
    echo !RED!    ╚══════════════════════════════════════════════════════╝!RESET!
    echo.
    pause
    exit /b 1
)

echo !GREEN!    [ OK ] !WHITE!Git repository detected!RESET!
echo.

:: ============================================================
:: REMOVE OLD ZIP
:: ============================================================

echo !WHITE![ !CYAN!03!WHITE! ] Preparing package...!RESET!
echo.

if exist "EndrekPack.zip" (
    echo !YELLOW!    [ ... ] Removing previous EndrekPack.zip!RESET!
    del /f /q "EndrekPack.zip"
)

echo !GREEN!    [ OK ] !WHITE!Workspace ready!RESET!
echo.

:: ============================================================
:: CREATE ZIP
:: ============================================================

echo !WHITE![ !CYAN!04!WHITE! ] Building EndrekPack.zip...!RESET!
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "Compress-Archive -Path 'assets','pack.mcmeta' -DestinationPath 'EndrekPack.zip' -Force"

if errorlevel 1 (
    echo.
    echo !RED!    ╔══════════════════════════════════════════════════════╗
    echo !RED!    ║  ERROR: Failed to create EndrekPack.zip             ║
    echo !RED!    ╚══════════════════════════════════════════════════════╝!RESET!
    echo.
    pause
    exit /b 1
)

echo !GREEN!    [ OK ] !WHITE!EndrekPack.zip created!RESET!
echo.

:: ============================================================
:: GIT
:: ============================================================

echo !WHITE![ !CYAN!05!WHITE! ] Publishing to GitHub...!RESET!
echo.

git add "EndrekPack.zip"

if errorlevel 1 (
    echo !RED!    [ERROR] git add failed.!RESET!
    echo.
    pause
    exit /b 1
)

echo !GREEN!    [ OK ] !WHITE!Package staged!RESET!

git commit -m "Update EndrekPack.zip"

if errorlevel 1 (
    echo !YELLOW!    [WARN] !WHITE!Nothing new to commit.!RESET!
)

git push

if errorlevel 1 (
    echo.
    echo !RED!    ╔══════════════════════════════════════════════════════╗
    echo !RED!    ║  ERROR: Git push failed                             ║
    echo !RED!    ╚══════════════════════════════════════════════════════╝!RESET!
    echo.
    pause
    exit /b 1
)

echo !GREEN!    [ OK ] !WHITE!GitHub updated!RESET!
echo.

:: ============================================================
:: SHA-1
:: ============================================================

echo !WHITE![ !CYAN!06!WHITE! ] Generating SHA-1...!RESET!
echo.

set "SHA1="

for /f "tokens=*" %%A in ('powershell -NoProfile -Command "(Get-FileHash -Algorithm SHA1 -LiteralPath 'EndrekPack.zip').Hash"') do (
    set "SHA1=%%A"
)

if not defined SHA1 (
    echo !RED!    [ERROR] Failed to calculate SHA-1.!RESET!
    echo.
    pause
    exit /b 1
)

echo !GREEN!    [ OK ] !WHITE!SHA-1 generated!RESET!
echo.

:: ============================================================
:: SHA-1 DISPLAY
:: ============================================================

echo !GRAY!    ┌──────────────────────────────────────────────────────────┐!RESET!
echo !GRAY!    │!RESET! !MAGENTA!SHA-1!RESET!                                                    !GRAY!│!RESET!
echo !GRAY!    ├──────────────────────────────────────────────────────────┤!RESET!
echo !GRAY!    │!RESET! !WHITE!!SHA1!!RESET!                                  !GRAY!│!RESET!
echo !GRAY!    └──────────────────────────────────────────────────────────┘!RESET!
echo.

:: ============================================================
:: COPY SHA-1 TO CLIPBOARD
:: ============================================================

echo !WHITE![ !CYAN!07!WHITE! ] Copying SHA-1 to clipboard...!RESET!
echo.

powershell -NoProfile -Command "Set-Clipboard -Value '!SHA1!'"

if errorlevel 1 (
    echo !RED!    [ERROR] Failed to copy SHA-1 to clipboard.!RESET!
    echo.
    pause
    exit /b 1
)

echo !GREEN!    [ OK ] !WHITE!SHA-1 copied to clipboard!RESET!
echo.

:: ============================================================
:: COMPLETE
:: ============================================================

echo !GRAY!    ──────────────────────────────────────────────────────────────!RESET!
echo.
echo !GREEN!    ╔══════════════════════════════════════════════════════════╗
echo !GREEN!    ║                                                          ║
echo !GREEN!    ║              ✓  BUILD COMPLETED SUCCESSFULLY             ║
echo !GREEN!    ║                                                          ║
echo !GREEN!    ╚══════════════════════════════════════════════════════════╝!RESET!
echo.
echo !WHITE!    Package : !CYAN!EndrekPack.zip!RESET!
echo !WHITE!    GitHub  : !GREEN!Pushed successfully!RESET!
echo !WHITE!    SHA-1   : !MAGENTA!!SHA1!!RESET!
echo !WHITE!    Copy    : !GREEN!Clipboard ready!RESET!
echo.
echo !GRAY!    ──────────────────────────────────────────────────────────────!RESET!
echo.
echo !GRAY!    Press any key to close...!RESET!

pause >nul