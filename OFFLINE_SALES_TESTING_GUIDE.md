# 🚀 Quick Start: Testing Offline Sales Feature

## Prerequisites

- ✅ PostgreSQL database running
- ✅ Node.js installed
- ✅ Flutter SDK installed (for mobile app)
- ✅ Backend dependencies installed

---

## Backend Quick Test (5 minutes)

### Step 1: Navigate to Backend
```powershell
cd C:\Users\MAHESH\Downloads\Ksheer_Mitra-main\Ksheer_Mitra-main\backend
```

### Step 2: Run Comprehensive Test
```powershell
node test-offline-sales-complete.js
```

### Expected Output:
```
🚀 Starting Offline Sales Complete Test...

✅ Database connected successfully
✅ Admin user found: Test Admin
✅ Created/Updated products: 3
✅ Offline sale created successfully!
✅ Stock reduced correctly for all products
✅ Invoice found and updated
✅ Insufficient stock validation working
✅ Sales listing working
✅ Statistics calculated correctly
✅ Daily invoice retrieved

═══════════════════════════════════════════════════════════
✅ ALL TESTS PASSED SUCCESSFULLY!
═══════════════════════════════════════════════════════════
```

---

## Backend API Test (Using curl/Postman)

### Step 1: Start Backend Server
```powershell
cd backend
npm start
```

### Step 2: Get Admin Token

Login as admin:
```powershell
curl -X POST http://localhost:5000/api/auth/login `
  -H "Content-Type: application/json" `
  -d '{\"phone\": \"+919876543210\", \"password\": \"admin123\"}'
```

Save the returned token.

### Step 3: Get Products
```powershell
$token = "YOUR_JWT_TOKEN_HERE"

curl -X GET http://localhost:5000/api/admin/products `
  -H "Authorization: Bearer $token"
```

Note product IDs for next step.

### Step 4: Create Offline Sale
```powershell
curl -X POST http://localhost:5000/api/admin/offline-sales `
  -H "Authorization: Bearer $token" `
  -H "Content-Type: application/json" `
  -d '{
    \"items\": [
      {
        \"productId\": \"PRODUCT_UUID_HERE\",
        \"quantity\": 2
      }
    ],
    \"customerName\": \"Test Customer\",
    \"paymentMethod\": \"cash\",
    \"notes\": \"Test sale\"
  }'
```

### Step 5: View Sales
```powershell
curl -X GET http://localhost:5000/api/admin/offline-sales `
  -H "Authorization: Bearer $token"
```

### Step 6: Get Statistics
```powershell
$today = Get-Date -Format "yyyy-MM-dd"

curl -X GET "http://localhost:5000/api/admin/offline-sales/stats?startDate=$today&endDate=$today" `
  -H "Authorization: Bearer $token"
```

---

## Frontend (Flutter) Quick Test

### Step 1: Ensure Backend is Running
```powershell
cd backend
npm start
```

### Step 2: Update API Configuration

Edit `ksheermitra/lib/config/api_config.dart`:
```dart
class ApiConfig {
  static const String baseUrl = 'http://YOUR_IP:5000/api';
  // Use your computer's IP address, not localhost
}
```

### Step 3: Install Dependencies
```powershell
cd ksheermitra
flutter pub get
```

### Step 4: Run Flutter App
```powershell
flutter run
```

Or for specific device:
```powershell
flutter devices  # List available devices
flutter run -d DEVICE_ID
```

### Step 5: Test in App

1. **Login** as admin:
   - Phone: +919876543210
   - Password: admin123

2. **Navigate** to:
   - Tap "More" tab (bottom navigation)
   - Tap "In-Store Sales"

3. **Create Sale**:
   - Tap "New Sale" button (FAB)
   - Select products
   - Adjust quantities
   - Fill customer info (optional)
   - Select payment method
   - Tap "Create Sale"

4. **Verify**:
   - See success message
   - Sale appears in list
   - Check statistics card
   - Tap sale to view details

---

## Using Postman Collection

### Step 1: Import Collection
1. Open Postman
2. Click **Import**
3. Select: `Offline_Sales_API.postman_collection.json`

### Step 2: Set Environment Variables
1. Click collection → Variables tab
2. Set:
   - `baseUrl`: http://localhost:5000/api
   - `adminToken`: (Get from login response)
   - `productId1`: (Get from products list)
   - `productId2`: (Get from products list)

### Step 3: Run Requests
Execute in order:
1. Admin Login
2. Get All Products
3. Create Offline Sale
4. Get All Offline Sales
5. Get Sales Stats
6. Get Admin Daily Invoice

---

## Verification Checklist

### Backend Verification
- [ ] Server starts without errors
- [ ] Database connection successful
- [ ] Migration completed (tables exist)
- [ ] Test script passes all checks
- [ ] API endpoints respond correctly
- [ ] Stock reduces after sale
- [ ] Invoice creates/updates
- [ ] Error handling works (insufficient stock)

### Frontend Verification
- [ ] App builds successfully
- [ ] Admin can login
- [ ] In-Store Sales menu appears
- [ ] Sales list loads
- [ ] Create sale screen works
- [ ] Products load correctly
- [ ] Stock validation shows
- [ ] Sale creation succeeds
- [ ] Success message displays
- [ ] Sales list refreshes

---

## Troubleshooting

### Backend Issues

#### Server won't start
```powershell
# Check if port 5000 is in use
netstat -ano | findstr :5000

# Kill process if needed
taskkill /PID <PID> /F

# Restart server
npm start
```

#### Database connection error
```powershell
# Check .env file
cat .env

# Verify PostgreSQL is running
psql -U postgres -l
```

#### Migration errors
```powershell
# Tables already exist - this is OK
# Verify tables:
psql -U postgres -d ksheermitra -c "\dt OfflineSales"
```

### Frontend Issues

#### Cannot connect to backend
```dart
// Update api_config.dart with your IP:
static const String baseUrl = 'http://192.168.1.100:5000/api';
```

#### Products not loading
```dart
// Check network permissions in AndroidManifest.xml:
<uses-permission android:name="android.permission.INTERNET"/>
```

#### Build errors
```powershell
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

---

## Database Direct Check

### Check if tables exist
```sql
-- Connect to database
psql -U postgres -d ksheermitra

-- List tables
\dt

-- Check OfflineSales table
SELECT * FROM "OfflineSales" LIMIT 5;

-- Check recent sales
SELECT 
  "saleNumber",
  "saleDate",
  "totalAmount",
  "paymentMethod"
FROM "OfflineSales"
ORDER BY "createdAt" DESC
LIMIT 10;

-- Check invoice types
SELECT DISTINCT "invoiceType" FROM "Invoices";
```

---

## Performance Monitoring

### Backend Metrics
```javascript
// Check logs for timing
grep "Offline sale created" backend/logs/combined.log

// Monitor database connections
SELECT count(*) FROM pg_stat_activity WHERE datname = 'ksheermitra';
```

### Frontend Performance
```powershell
# Profile app
flutter run --profile

# Check bundle size
flutter build apk --analyze-size
```

---

## Next Steps After Testing

1. ✅ Verify all tests pass
2. ✅ Test on real device
3. ✅ Test concurrent sales
4. ✅ Test with low stock scenarios
5. ✅ Test error scenarios
6. ✅ Review logs for issues
7. ✅ Performance testing
8. ✅ Security review
9. ✅ User acceptance testing
10. ✅ Deploy to production

---

## Quick Commands Reference

```powershell
# Backend
cd backend
npm start                                    # Start server
node test-offline-sales-complete.js         # Run tests
npm run dev                                  # Dev mode with auto-reload

# Frontend
cd ksheermitra
flutter run                                  # Run app
flutter build apk                            # Build Android
flutter clean                                # Clean build
flutter pub get                              # Install dependencies

# Database
psql -U postgres -d ksheermitra             # Connect to DB
node run-migration-offline-sales.js          # Run migration
```

---

## Success Criteria

✅ **Backend**:
- All tests pass
- API responds in < 500ms
- Stock updates atomically
- Invoices generate correctly
- Error handling works

✅ **Frontend**:
- App loads without crashes
- Sales creation works smoothly
- UI is responsive
- Error messages are clear
- Data refreshes properly

✅ **Integration**:
- Backend and frontend communicate
- Data syncs correctly
- Real-time updates work
- Concurrent operations handled

---

## Support

If you encounter issues:

1. **Check logs**: `backend/logs/combined.log`
2. **Verify database**: Run SQL queries above
3. **Test API directly**: Use Postman
4. **Check network**: Ensure backend is accessible
5. **Review documentation**: See OFFLINE_SALES_COMPLETE_IMPLEMENTATION.md

---

**Testing Time**: ~10 minutes
**Status**: Ready for Testing ✅
**Last Updated**: January 10, 2026

