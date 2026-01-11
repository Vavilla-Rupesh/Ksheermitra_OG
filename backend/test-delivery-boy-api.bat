@echo off
REM Delivery Boy API Test Script for Windows
REM This script tests all delivery boy endpoints

echo.
echo ==========================================
echo   Testing Delivery Boy API Endpoints
echo ==========================================
echo.

REM Configuration
set BASE_URL=http://localhost:3000/api
set TOKEN=

if "%TOKEN%"=="" (
  echo [WARNING] No JWT token set.
  echo Please update the TOKEN variable in this script.
  echo.
  echo Get a token by authenticating first:
  echo   1. POST /api/auth/send-otp
  echo   2. POST /api/auth/verify-otp
  echo.
  pause
  exit /b 1
)

echo [1] Testing GET /api/delivery-boy/delivery-map
curl -X GET "%BASE_URL%/delivery-boy/delivery-map" -H "Authorization: Bearer %TOKEN%" -H "Content-Type: application/json"
echo.
echo.

echo [2] Testing GET /api/delivery-boy/stats
curl -X GET "%BASE_URL%/delivery-boy/stats?period=today" -H "Authorization: Bearer %TOKEN%" -H "Content-Type: application/json"
echo.
echo.

echo [3] Testing GET /api/delivery-boy/history
curl -X GET "%BASE_URL%/delivery-boy/history?page=1&limit=5" -H "Authorization: Bearer %TOKEN%" -H "Content-Type: application/json"
echo.
echo.

echo [4] Testing GET /api/delivery-boy/profile
curl -X GET "%BASE_URL%/delivery-boy/profile" -H "Authorization: Bearer %TOKEN%" -H "Content-Type: application/json"
echo.
echo.

echo [5] Testing POST /api/delivery-boy/generate-invoice
curl -X POST "%BASE_URL%/delivery-boy/generate-invoice" -H "Authorization: Bearer %TOKEN%" -H "Content-Type: application/json" -d "{\"date\": \"2025-11-02\"}"
echo.
echo.

echo ==========================================
echo   Testing Complete!
echo ==========================================
echo.
echo NOTE: Some endpoints may return empty data if:
echo   - No deliveries are assigned to this delivery boy
echo   - No completed deliveries for invoice generation
echo   - Database is empty
echo.
pause

