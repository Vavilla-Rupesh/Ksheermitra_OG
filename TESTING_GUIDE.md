Customer Map Test:
[ ] Map loads
[ ] Markers display
[ ] Colors correct (blue/red)
[ ] Info windows work
[ ] Refresh works

Monthly Breakout Test:
[ ] Total amount > Rs. 0.00
[ ] Delivered amount correct
[ ] Pending amount correct
[ ] Subscriptions list properly
[ ] Daily breakout shows amounts
[ ] Month navigation works

Invoice Test:
[ ] Invoice generates
[ ] Amounts match breakout
[ ] All deliveries listed
[ ] Details correct

Issues Found:
[List any issues]

Notes:
[Additional observations]
```

---

## 🆘 Need Help?

If issues persist after following this guide:
1. Check backend logs: `backend/logs/error.log`
2. Check Flutter console for errors
3. Review `FIXES_APPLIED.md` for technical details
4. Verify database has proper data
# Testing Guide - After Fixes

## 🚀 Quick Start

### 1. Start Backend Server

#### Option A: Using the batch file (Recommended)
Double-click: `START_BACKEND.bat`

#### Option B: Manual
```bash
cd backend
npm start
```

The server should start on: `http://localhost:5000`

---

## 🧪 Testing Steps

### Test 1: Customer Map Feature

#### Objective
Verify that the admin can view customers on Google Maps with proper location markers.

#### Steps
1. **Start the Flutter app**
   ```bash
   cd ksheermitra
   flutter run
   ```

2. **Login as Admin**
   - Use admin credentials

3. **Navigate to Customer Map**
   - Go to: `Customers` → `View on Map`
   - Or navigate to the customer map screen

4. **Verify Results:**
   - ✅ Map loads successfully
   - ✅ Customer markers appear on the map
   - ✅ Blue markers = Active customers
   - ✅ Red markers = Inactive customers
   - ✅ Tap on a marker shows customer info window
   - ✅ Customer name, phone, and address display correctly
   - ✅ No "No customers with valid locations found" error

5. **Test Refresh**
   - Pull down to refresh or use refresh button
   - Verify markers update correctly

#### Expected Behavior
- All customers with latitude/longitude coordinates should be visible
- Map centers on all markers with appropriate zoom
- Customer details accessible via marker tap

---

### Test 2: Monthly Breakout Feature

#### Objective
Verify that customers can view their monthly subscription breakout with correct amounts.

#### Steps
1. **Login as Customer**
   - Use customer credentials who has active subscriptions

2. **Navigate to Monthly Breakout**
   - Find "Monthly Breakout" in the menu
   - Or navigate from subscriptions screen

3. **Verify Current Month:**
   - ✅ Month/Year displays correctly (e.g., "November 2025")
   - ✅ **Total Amount** shows a value > Rs. 0.00
   - ✅ **Delivered Amount** shows delivered deliveries total
   - ✅ **Pending Amount** shows pending deliveries total
   - ✅ Summary card displays at top

4. **Verify Subscription List:**
   - ✅ Each subscription shows as an expandable card
   - ✅ Subscription title shows (e.g., "Subscription 1")
   - ✅ Subscription total amount displays
   - ✅ Tap to expand shows daily breakout

5. **Verify Daily Breakout:**
   For each expanded subscription:
   - ✅ Each delivery date listed (e.g., "01 Nov", "02 Nov")
   - ✅ Product names displayed
   - ✅ Individual delivery amounts shown
   - ✅ Amounts are > Rs. 0.00 (not zero)

6. **Test Month Navigation:**
   - Tap left arrow (previous month)
   - Verify data updates
   - Tap right arrow (next month)
   - Verify data updates
   - Return to current month

#### Expected Behavior
- All amounts should be calculated correctly
- No Rs. 0.00 values unless legitimately zero
- Navigation between months works smoothly
- Loading states display properly

---

### Test 3: Monthly Invoice Generation

#### Objective
Verify that monthly invoice generation calculates correct totals.

#### Steps
1. **As Customer, navigate to Invoices**

2. **Generate Monthly Invoice:**
   - Select a month with deliveries
   - Click "Generate Invoice"

3. **Verify Invoice:**
   - ✅ Invoice number generated
   - ✅ **Total Amount** is correct (matches monthly breakout)
   - ✅ All deliveries listed
   - ✅ Each delivery shows:
     - Date
     - Products
     - Quantity
     - Amount
   - ✅ Payment status shown correctly

4. **Download/View Invoice:**
   - Test PDF generation (if implemented)
   - Verify all details print correctly

---

### Test 4: Delivery Boy Map (Bonus)

#### Objective
Verify delivery boy can see assigned area and customers.

#### Steps
1. **Login as Delivery Boy**

2. **Navigate to Map View**
   - Should show delivery map screen

3. **Verify:**
   - ✅ Area boundary displays (polygon)
   - ✅ Customer markers visible
   - ✅ Marker colors indicate delivery status:
     - 🔵 Blue = Pending delivery
     - 🟢 Green = Delivered
     - 🔴 Red = Missed
   - ✅ Tap marker shows customer details
   - ✅ Can mark delivery as completed from detail view
   - ✅ Auto-refresh works (every 30 seconds)

---

## 🔍 Backend API Testing

### Test API Endpoints Directly

#### 1. Test Customer Map Endpoint
```bash
# Using curl (requires admin token)
curl -X GET http://localhost:5000/api/admin/customers/map \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

**Expected Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "customer-uuid",
      "name": "Customer Name",
      "phone": "+1234567890",
      "address": "Customer Address",
      "latitude": "12.345678",
      "longitude": "78.901234",
      "areaId": "area-uuid",
      "isActive": true,  // ← This field should be present
      "area": {
        "id": "area-uuid",
        "name": "Area Name"
      }
    }
  ]
}
```

#### 2. Test Monthly Breakout Endpoint
```bash
# Using curl (requires customer token)
curl -X GET http://localhost:5000/api/customer/monthly-breakout/2025/11 \
  -H "Authorization: Bearer YOUR_CUSTOMER_TOKEN"
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "customerId": "customer-uuid",
    "year": 2025,
    "month": 11,
    "monthName": "November 2025",
    "totalAmount": 1500.00,  // ← Should NOT be 0
    "deliveredAmount": 800.00,
    "pendingAmount": 700.00,
    "subscriptionCount": 2,
    "subscriptions": [
      {
        "subscriptionId": "sub-uuid",
        "totalAmount": 750.00,  // ← Should NOT be 0
        "breakout": [
          {
            "id": "delivery-uuid",
            "date": "2025-11-01",
            "amount": 50.00,  // ← Should NOT be 0
            "items": [...]
          }
        ]
      }
    ]
  }
}
```

---

## 🐛 Troubleshooting

### Issue: Still showing Rs. 0.00 in monthly breakout

**Possible Causes:**
1. No deliveries exist for the selected month
2. Deliveries exist but have no items
3. Products don't have pricePerUnit set

**Solutions:**
1. Check database for deliveries:
   ```sql
   SELECT * FROM deliveries 
   WHERE customerId = 'customer-uuid' 
   AND deliveryDate BETWEEN '2025-11-01' AND '2025-11-30';
   ```

2. Check delivery items:
   ```sql
   SELECT di.*, p.pricePerUnit 
   FROM delivery_items di
   JOIN products p ON di.productId = p.id
   WHERE di.deliveryId = 'delivery-uuid';
   ```

3. Verify product prices:
   ```sql
   SELECT id, name, pricePerUnit FROM products;
   ```

### Issue: Customer map still showing "no customers" error

**Possible Causes:**
1. Backend not restarted after fix
2. Customers don't have latitude/longitude
3. Network error

**Solutions:**
1. Restart backend server
2. Add location to customers:
   ```sql
   UPDATE users 
   SET latitude = 12.345678, longitude = 78.901234 
   WHERE id = 'customer-uuid';
   ```
3. Check Flutter app logs for API errors

### Issue: Backend won't start

**Solutions:**
1. Check if port 5000 is in use:
   ```bash
   netstat -ano | findstr :5000
   ```

2. Kill process if needed:
   ```bash
   taskkill /PID <process-id> /F
   ```

3. Check environment variables:
   - Ensure `.env` file exists in backend folder
   - Verify database connection string

4. Reinstall dependencies:
   ```bash
   cd backend
   npm install
   ```

---

## ✅ Success Criteria

All tests pass if:
- ✅ Customer map displays all customers with locations
- ✅ Monthly breakout shows correct amounts (not Rs. 0.00)
- ✅ Invoice generation calculates proper totals
- ✅ All navigation and UI interactions work smoothly
- ✅ Backend API returns expected data structures
- ✅ No console errors in Flutter or Node.js

---

## 📝 Test Results Template

```
=================================
Test Results - [Date]
=================================

Backend Server:
[ ] Started successfully
[ ] No errors in logs


