# Quick Testing Guide

## How to Test All Fixed Issues

### Prerequisites
1. Backend server running on configured port
2. Flutter app installed on device/emulator
3. Admin and customer accounts set up

---

## Test 1: Monthly Breakout Amount Fix

### Steps:
1. **Run the database fix script first:**
   ```bash
   cd backend
   node fix-delivery-amounts.js
   ```
   - Script should show number of deliveries fixed
   - Check output for any errors

2. **Create a new subscription:**
   - Login as customer
   - Go to "Create Subscription"
   - Add one or more products with quantities
   - Set frequency (daily/weekly/custom)
   - Submit subscription

3. **Verify Monthly Breakout:**
   - Navigate to subscription details
   - Tap "Monthly Breakout" button
   - **Expected**: Should show correct amounts (NOT ₹0)
   - Check that:
     - Total Amount shows correct sum
     - Each daily entry shows proper amount
     - Delivered/Pending amounts are accurate

### Success Criteria:
✅ All amounts display correctly (no ₹0 values)
✅ Amounts match product prices × quantities
✅ Summary totals are accurate

---

## Test 2: Admin Dashboard Card Overflow

### Steps:
1. Login as admin
2. Navigate to Dashboard (first tab)
3. Check all stat cards

### Test Scenarios:
- **Small numbers**: Should display normally
- **Large numbers**: Should scale/wrap properly (e.g., ₹999999)
- **Long text**: Should truncate with ellipsis
- **Different screen sizes**: Test on phone, tablet, desktop

### Success Criteria:
✅ No text extends beyond card boundaries
✅ Numbers are readable and properly formatted
✅ Subtitle text truncates with "..." if too long
✅ Cards maintain consistent height

---

## Test 3: Subscription Detail Popup Overflow

### Steps:
1. Login as admin or customer
2. Navigate to Customer Details (admin) or My Subscriptions (customer)
3. Tap "View Details" on any subscription

### Test Scenarios:
- **Single product**: Check layout is clean
- **Multiple products**: Verify all products display
- **Large amounts**: Test with ₹10,000+ subscriptions
- **Long product names**: Verify truncation works
- **Multiple delivery days**: Check "Delivery Days" field wraps properly

### What to Check:
- [ ] Header displays frequency without overflow
- [ ] Product list shows all items properly
- [ ] "Total per delivery" section fits in one row
- [ ] Large amounts scale down if needed
- [ ] Delivery days text wraps to multiple lines

### Success Criteria:
✅ Popup scrolls smoothly with no horizontal overflow
✅ All text is readable
✅ Amount displays prominently without overflow

---

## Test 4: Product Cards - Stock Display

### Steps:
1. **Admin Product List:**
   - Login as admin
   - Go to Products tab
   - Check each product card

2. **Customer Product Selection:**
   - Login as customer
   - Create/edit subscription
   - View product selection screen

### What to Check:

**Admin View:**
- [ ] Stock badge visible on product image (top-right)
- [ ] Badge colors:
  - Green = "In Stock" (stock ≥ 10)
  - Orange = "Stock: X" (stock < 10)
  - Red = "Out of Stock" (stock = 0)

**Customer View:**
- [ ] Stock text below product name
- [ ] Same color coding as admin
- [ ] Add button disabled for out-of-stock items
- [ ] Add button is grey when stock = 0

### Success Criteria:
✅ Stock information clearly visible
✅ Color coding helps quick identification
✅ Out-of-stock items cannot be added
✅ Stock count shown when low

---

## Test 5: Product Images Display

### Steps:
1. Ensure some products have images uploaded
2. Check images display in:
   - Product list (admin)
   - Product selection (customer)
   - Subscription cards
   - Monthly breakout

### What to Check:
- [ ] Images load properly (shows loading indicator)
- [ ] Fallback icon displays if image fails
- [ ] Icons match product type (milk, butter, etc.)
- [ ] Images are properly sized and not distorted
- [ ] Images display consistently across all screens

### Success Criteria:
✅ All product images load and display
✅ Graceful fallback to icons when needed
✅ Consistent sizing and aspect ratio

---

## Backend API Testing

### Test Delivery Amount Calculation:

**Endpoint:** `GET /api/customer/subscriptions/:id/monthly-breakout?year=2025&month=10`

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "subscriptionId": "uuid",
    "year": 2025,
    "month": 10,
    "monthName": "October 2025",
    "totalAmount": 450.00,  // NOT 0
    "deliveredAmount": 150.00,
    "pendingAmount": 300.00,
    "breakout": [
      {
        "id": "uuid",
        "date": "2025-10-23",
        "amount": 50.00,  // NOT 0
        "items": [
          {
            "productName": "Milk",
            "quantity": 1,
            "pricePerUnit": 50,
            "price": 50.00  // NOT 0
          }
        ]
      }
    ]
  }
}
```

### Test Using Postman/cURL:
```bash
# Get monthly breakout
curl -X GET \
  'http://localhost:5000/api/customer/subscriptions/SUBSCRIPTION_ID/monthly-breakout?year=2025&month=10' \
  -H 'Authorization: Bearer YOUR_TOKEN'
```

---

## Common Issues & Solutions

### Issue: Still seeing ₹0 in monthly breakout
**Solution:**
1. Run `node fix-delivery-amounts.js` again
2. Check backend logs for calculation errors
3. Verify products have valid pricePerUnit values
4. Ensure subscription_products table has quantities

### Issue: Stock not displaying
**Solution:**
1. Check Product model has stock field
2. Verify database has stock column
3. Check API returns stock in product JSON
4. Ensure `showStock` parameter is true (default)

### Issue: Images not loading
**Solution:**
1. Verify image URLs in database
2. Check ImageHelper configuration
3. Ensure backend serves static files
4. Test image URLs directly in browser

### Issue: Cards still overflowing
**Solution:**
1. Clear Flutter cache: `flutter clean`
2. Rebuild app: `flutter pub get && flutter run`
3. Check screen size constraints
4. Test on different devices

---

## Performance Checklist

After all fixes:
- [ ] App loads quickly
- [ ] No console errors in debug mode
- [ ] Backend responses are fast (< 500ms)
- [ ] Images load progressively
- [ ] UI is responsive and smooth
- [ ] No memory leaks

---

## Rollback Plan

If issues occur:

### Backend:
```bash
git checkout HEAD~1 backend/src/services/subscription.service.js
npm restart
```

### Frontend:
```bash
git checkout HEAD~1 ksheermitra/lib/widgets/
flutter clean && flutter pub get
flutter run
```

### Database:
Keep a backup before running fix script:
```bash
# PostgreSQL
pg_dump -U username -d ksheermitra > backup_before_fix.sql

# Restore if needed
psql -U username -d ksheermitra < backup_before_fix.sql
```

---

## Success Metrics

All tests pass when:
1. ✅ No ₹0 amounts in monthly breakout
2. ✅ No overflow in any UI component
3. ✅ Stock information visible on all product cards
4. ✅ Product images display consistently
5. ✅ Backend logs show no calculation errors
6. ✅ Users can complete full subscription flow

---

## Next Steps

After successful testing:
1. Deploy to staging environment
2. Perform UAT with real users
3. Monitor logs for 24-48 hours
4. Deploy to production
5. Update user documentation

**Test completed by:** _________________
**Date:** _________________
**All tests passed:** [ ] Yes [ ] No
**Notes:** _________________________________

