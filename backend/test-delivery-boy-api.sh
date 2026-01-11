#!/bin/bash

# Delivery Boy API Test Script
# This script tests all delivery boy endpoints

echo "🚚 Testing Delivery Boy API Endpoints"
echo "======================================="
echo ""

# Configuration
BASE_URL="http://localhost:3000/api"
TOKEN="" # Set your JWT token here

if [ -z "$TOKEN" ]; then
  echo "⚠️  Warning: No JWT token set. Please update the TOKEN variable."
  echo "   Get a token by authenticating first:"
  echo "   1. POST /api/auth/send-otp"
  echo "   2. POST /api/auth/verify-otp"
  echo ""
  exit 1
fi

echo "1️⃣  Testing GET /api/delivery-boy/delivery-map"
curl -s -X GET "$BASE_URL/delivery-boy/delivery-map" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" | json_pp
echo ""
echo ""

echo "2️⃣  Testing GET /api/delivery-boy/stats"
curl -s -X GET "$BASE_URL/delivery-boy/stats?period=today" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" | json_pp
echo ""
echo ""

echo "3️⃣  Testing GET /api/delivery-boy/history"
curl -s -X GET "$BASE_URL/delivery-boy/history?page=1&limit=5" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" | json_pp
echo ""
echo ""

echo "4️⃣  Testing GET /api/delivery-boy/profile"
curl -s -X GET "$BASE_URL/delivery-boy/profile" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" | json_pp
echo ""
echo ""

echo "5️⃣  Testing POST /api/delivery-boy/generate-invoice"
TODAY=$(date +%Y-%m-%d)
curl -s -X POST "$BASE_URL/delivery-boy/generate-invoice" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"date\": \"$TODAY\"}" | json_pp
echo ""
echo ""

echo "✅ Testing complete!"
echo ""
echo "📝 Note: Some endpoints may return empty data if:"
echo "   - No deliveries are assigned to this delivery boy"
echo "   - No completed deliveries for invoice generation"
echo "   - Database is empty"

