# Offline Sales - Quick Start Guide

## 🚀 Getting Started in 5 Minutes

### Step 1: Run Database Migration
```bash
cd backend
node migrations/20260104_add_offline_sales.js
```

Or if using Sequelize CLI:
```bash
npx sequelize-cli db:migrate
```

### Step 2: Start the Backend
```bash
cd backend
npm start
```

### Step 3: Test the API

#### A. Get Admin Token
First, login as admin to get your JWT token:
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone": "+919876543210", "otp": "123456"}'
```

Save the `token` from the response.

#### B. Get Product IDs
```bash
curl -X GET http://localhost:5000/api/admin/products \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

Note down some product IDs.

#### C. Create Your First Offline Sale
```bash
curl -X POST http://localhost:5000/api/admin/offline-sales \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "items": [
      {
        "productId": "PRODUCT_UUID_1",
        "quantity": 2
      },
      {
        "productId": "PRODUCT_UUID_2",
        "quantity": 3
      }
    ],
    "customerName": "Walk-in Customer",
    "paymentMethod": "cash",
    "notes": "Test sale"
  }'
```

#### D. View Your Sales
```bash
curl -X GET http://localhost:5000/api/admin/offline-sales \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

#### E. Get Today's Invoice
```bash
curl -X GET "http://localhost:5000/api/admin/invoices/admin-daily?date=2026-01-04" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```
*(Replace date with today's date in YYYY-MM-DD format)*

---

## 📱 Using Postman

1. Import the collection:
   - Open Postman
   - Click **Import**
   - Select `Offline_Sales_API.postman_collection.json`

2. Set variables:
   - Click on the collection
   - Go to **Variables** tab
   - Update:
     - `adminToken` - Your JWT token
     - `productId1` - A valid product UUID
     - `productId2` - Another product UUID

3. Run requests in order:
   - Start with "Get All Products" to find product IDs
   - Then try "1. Create Offline Sale"
   - Check results with "4. Get All Offline Sales"

---

## ✅ What Gets Created

When you create an offline sale:

1. **OfflineSale Record**
   - Unique sale number (e.g., `SALE-20260104-143022-abc123`)
   - Sale date
   - Items sold with quantities and amounts
   - Total amount
   - Optional customer info

2. **Stock Reduction**
   - Each product's stock is reduced immediately
   - Example: Milk stock 100 → 98 (if you sold 2 liters)

3. **Daily Invoice Update**
   - Invoice number: `INV-ADMIN-YYYYMMDD`
   - Total amount increases by sale amount
   - Sale details added to invoice metadata

---

## 🔍 Quick Verification

### Check Stock Was Reduced
```bash
# Before sale
curl http://localhost:5000/api/admin/products | grep -A 5 "Milk"
# Note the stock value

# After sale
# Stock should be reduced by the quantity sold
```

### Check Invoice Was Updated
```bash
curl "http://localhost:5000/api/admin/invoices/admin-daily?date=2026-01-04" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
  
# Look for:
# - totalAmount increased
# - offlineSales array contains your sale
```

---

## ⚠️ Error Testing

### Test Insufficient Stock
```bash
curl -X POST http://localhost:5000/api/admin/offline-sales \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "items": [
      {
        "productId": "PRODUCT_UUID",
        "quantity": 99999
      }
    ],
    "paymentMethod": "cash"
  }'
  
# Expected: 400 error with message about insufficient stock
```

### Test Invalid Product
```bash
curl -X POST http://localhost:5000/api/admin/offline-sales \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "items": [
      {
        "productId": "invalid-uuid-12345",
        "quantity": 1
      }
    ],
    "paymentMethod": "cash"
  }'
  
# Expected: 400/500 error with validation message
```

---

## 📊 Quick Stats Check

Get sales statistics for today:
```bash
TODAY=$(date +%Y-%m-%d)

curl -X GET "http://localhost:5000/api/admin/offline-sales/stats?startDate=$TODAY&endDate=$TODAY" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

Get this month's stats:
```bash
START_DATE=$(date +%Y-%m-01)
END_DATE=$(date +%Y-%m-%d)

curl -X GET "http://localhost:5000/api/admin/offline-sales/stats?startDate=$START_DATE&endDate=$END_DATE" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

---

## 🎯 Common Use Cases

### 1. Simple Cash Sale
```json
{
  "items": [
    {"productId": "product-uuid", "quantity": 1}
  ],
  "paymentMethod": "cash"
}
```

### 2. Sale with Customer Info
```json
{
  "items": [
    {"productId": "product-uuid-1", "quantity": 2}
  ],
  "customerName": "John Doe",
  "customerPhone": "+919876543210",
  "paymentMethod": "upi"
}
```

### 3. Multi-Product Sale
```json
{
  "items": [
    {"productId": "milk-uuid", "quantity": 5},
    {"productId": "curd-uuid", "quantity": 3},
    {"productId": "butter-uuid", "quantity": 1}
  ],
  "customerName": "Jane Smith",
  "paymentMethod": "card",
  "notes": "Regular customer, bulk purchase"
}
```

---

## 🐛 Troubleshooting

### Migration Fails
```bash
# Check if table already exists
psql -d your_database -c "\dt OfflineSales"

# If exists, drop and recreate
psql -d your_database -c "DROP TABLE IF EXISTS OfflineSales CASCADE"
node migrations/20260104_add_offline_sales.js
```

### Authentication Errors
- Ensure you have a valid admin token
- Token format: `Bearer YOUR_JWT_TOKEN`
- Check token expiry

### Stock Not Reducing
- Check if transaction is being committed
- Look for errors in backend logs
- Verify product ID is correct

### Invoice Not Creating
- Check date format (must be YYYY-MM-DD)
- Ensure enum value 'admin_daily' exists in database
- Run migration if enum update failed

---

## 📝 Next Steps

1. ✅ Test basic sale creation
2. ✅ Verify stock reduction
3. ✅ Check invoice updates
4. ✅ Test error scenarios
5. ✅ Review sales statistics
6. 🔄 Integrate with Flutter frontend
7. 🔄 Add receipt printing
8. 🔄 Create dashboard widgets

---

## 🔗 Related Documentation

- Full API Documentation: `OFFLINE_SALES_FEATURE.md`
- Postman Collection: `Offline_Sales_API.postman_collection.json`
- Migration Script: `backend/migrations/20260104_add_offline_sales.js`
- Service Implementation: `backend/src/services/offlineSale.service.js`

---

**Need Help?** Check the main documentation file or backend logs for detailed error messages.

**Ready to Integrate?** See the Flutter integration example in `OFFLINE_SALES_FEATURE.md`.

