@echo off
echo ========================================
echo WhatsApp Fresh Start - Baileys Edition
echo ========================================
echo.
echo [NEW] Using Baileys instead of Puppeteer
echo        - More stable connection
echo        - No browser automation
echo        - Lighter resource usage
echo.

echo Step 1: Checking for duplicate processes...
taskkill /F /IM node.exe >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo Found and killed duplicate node processes
    timeout /t 3 /nobreak >nul
) else (
    echo No duplicate processes found - Good!
)

echo.
echo Step 2: Clearing ALL WhatsApp sessions and caches...
node fix-whatsapp-session.js

echo.
echo ========================================
echo BEFORE YOU CONTINUE:
echo ========================================
echo.
echo 1. Open WhatsApp on your PHONE
echo 2. Go to: Settings ^> Linked Devices
echo 3. REMOVE ALL linked devices
echo.
echo ========================================
echo.
set /p CONFIRM="Have you removed all linked devices? (y/n): "

if /i NOT "%CONFIRM%"=="y" (
    echo.
    echo Please complete the steps above first, then run this script again.
    echo.
    pause
    exit /b
)

echo.
echo Step 3: Waiting 3 seconds for systems to clear...
timeout /t 3 /nobreak >nul

echo.
echo Step 4: Starting server...
echo.
echo ========================================
echo SCAN QR CODE WHEN IT APPEARS
echo ========================================
echo.

npm run dev

