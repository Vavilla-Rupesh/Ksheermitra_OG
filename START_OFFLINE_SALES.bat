@echo off
REM Batch script to run offline sales migration and tests
REM Usage: START_OFFLINE_SALES.bat

echo ================================================
echo   Offline Sales Feature - Setup and Test
echo ================================================
echo.

cd backend

echo Step 1: Running database migration...
echo ================================================
node migrations/20260104_add_offline_sales.js
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Migration failed!
    pause
    exit /b 1
)
echo [SUCCESS] Migration completed!
echo.

echo Step 2: Running automated tests...
echo ================================================
node test-offline-sales.js
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Tests failed!
    pause
    exit /b 1
)
echo.

echo ================================================
echo   Setup Complete!
echo ================================================
echo.
echo The Offline Sales feature is now ready to use.
echo.
echo Next steps:
echo   1. Import Postman collection: Offline_Sales_API.postman_collection.json
echo   2. Update your admin token in Postman variables
echo   3. Test the API endpoints
echo   4. Integrate with Flutter frontend
echo.
echo Documentation:
echo   - Full Guide: OFFLINE_SALES_FEATURE.md
echo   - Quick Start: OFFLINE_SALES_QUICKSTART.md
echo   - Implementation: OFFLINE_SALES_IMPLEMENTATION.md
echo.
pause

