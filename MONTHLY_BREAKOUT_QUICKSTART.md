# 🚀 Monthly Breakout — Quick Start Guide

## Step 1: Run Database Migration

```bash
# Navigate to backend directory
cd backend

# Run the migration (if using PostgreSQL)
psql -U postgres -d ksheer_mitra -f migrations/create-delivery-items-table.sql

# Or if you're using migrations programmatically
npm run migrate
```

## Step 2: Verify Cron Jobs Are Running

The cron service should start automatically when your server starts. Check your logs:

```bash
# Check if cron jobs are initialized
tail -f logs/combined.log | grep "Cron"

# You should see:
# "Monthly invoice cron job scheduled: 0 7 1 * *"
# "Monthly breakout cron job scheduled: 0 23 28-31 * *"
# "Delivery cleanup cron job scheduled: 0 2 * * *"
```

## Step 3: Test the API Endpoints

### Get Monthly Breakout for a Subscription
```bash
curl -X GET "http://localhost:3000/api/customer/subscriptions/{subscription-id}/monthly-breakout?year=2025&month=10" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Get All Subscriptions Monthly Breakout
```bash
curl -X GET "http://localhost:3000/api/customer/monthly-breakout/2025/10" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Modify Delivery Products (Future Date Only)
```bash
curl -X PUT "http://localhost:3000/api/customer/deliveries/{delivery-id}/products" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "products": [
      {
        "productId": "product-uuid-1",
        "quantity": 2,
        "isOneTime": false
      },
      {
        "productId": "product-uuid-2",
        "quantity": 1,
        "isOneTime": true
      }
    ]
  }'
```

### Generate Monthly Invoice
```bash
curl -X POST "http://localhost:3000/api/customer/monthly-invoice/2025/10" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Get Monthly Invoice
```bash
curl -X GET "http://localhost:3000/api/customer/monthly-invoice/2025/10" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Step 4: Test Frontend Integration

### Add to your Flutter app's navigation
```dart
// Navigate to Monthly Breakout screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => MonthlyBreakoutScreen(
      subscriptionId: subscription.id,
    ),
  ),
);
```

## Step 5: Manual Testing Scenarios

### Scenario 1: View Current Month Breakout
1. Login as customer
2. Navigate to "My Subscriptions"
3. Tap on a subscription
4. View "Monthly Breakout"
5. Verify all delivery days are listed with amounts

### Scenario 2: Modify Future Delivery
1. In monthly breakout view
2. Find a future delivery (marked as editable)
3. Tap to modify
4. Change product quantities
5. Save changes
6. Verify amount recalculates immediately

### Scenario 3: Generate Invoice
1. Navigate to monthly breakout
2. Tap "Generate Invoice" button
3. Wait for confirmation
4. Invoice should be sent via WhatsApp
5. Download and verify PDF

## Troubleshooting

### Issue: Cron jobs not running
**Solution**: Ensure `cronService.start()` is called in your `server.js`:
```javascript
const cronService = require('./services/cron.service');
cronService.start();
```

### Issue: Cannot modify delivery
**Error**: "Cannot modify past deliveries"
**Solution**: Ensure you're selecting a future date (after today)

### Issue: Invoice already exists
**Error**: "Invoice already exists for this month"
**Solution**: This is expected. Delete existing invoice or use GET endpoint to retrieve it

### Issue: No deliveries in breakout
**Solution**: 
- Check if subscription has deliveries generated
- Verify subscription is active
- Check subscription frequency matches the dates

## Environment Variables

Add to your `.env` file if you want custom cron schedules:

```env
# Monthly invoice generation (default: 1st of month at 7 AM)
MONTHLY_INVOICE_CRON=0 7 1 * *

# Timezone for cron jobs
TZ=Asia/Kolkata
```

## Success Indicators

✅ Logs show: "Cron jobs initialized"
✅ API returns monthly breakout data
✅ Future deliveries show edit icon
✅ Amount recalculates on product change
✅ Invoice generated successfully
✅ PDF downloaded successfully

## Next Steps

1. ✅ Integrate into your existing customer dashboard
2. ✅ Add product selection UI for modifications
3. ✅ Implement invoice download feature
4. ✅ Add push notifications for invoice generation
5. ✅ Create admin panel to manage invoices

---

**You're all set! 🎉** The Monthly Breakout feature is now fully functional.

