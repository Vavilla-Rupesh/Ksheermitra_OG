# 🛒 Offline Sales Feature - READ ME FIRST

## ⚡ Quick Start (3 Steps)

### Windows Users
```bash
# Simply run:
START_OFFLINE_SALES.bat
```

### Linux/Mac Users
```bash
cd backend
node migrations/20260104_add_offline_sales.js
node test-offline-sales.js
```

---

## 📚 What's This Feature?

**In-Store (Offline) Sales** allows administrators to:
- ✅ Sell products directly to walk-in customers
- ✅ Automatically reduce stock inventory
- ✅ Add sales to the daily admin invoice
- ✅ Track payment methods (cash, card, UPI, other)
- ✅ Record optional customer details
- ✅ View sales statistics and reports

---

## 📂 Documentation Files

| File | Purpose | Start Here |
|------|---------|------------|
| **OFFLINE_SALES_QUICKSTART.md** | 5-minute setup guide | ⭐ Start here! |
| **OFFLINE_SALES_FEATURE.md** | Complete API documentation | For developers |
| **OFFLINE_SALES_IMPLEMENTATION.md** | Technical summary | For project overview |
| **Offline_Sales_API.postman_collection.json** | API test collection | For testing |

---

## 🎯 Core Features

### ✅ What Works Now

1. **Multi-Product Sales**
   - Sell multiple products in one transaction
   - Automatic price calculation

2. **Stock Management**
   - Real-time inventory reduction
   - Stock validation before sale

3. **Invoice Integration**
   - Auto-creates daily admin invoice
   - Accumulates all daily sales

4. **Payment Tracking**
   - Support for: Cash, Card, UPI, Other
   - Optional customer name & phone

5. **Reporting**
   - Daily/monthly sales reports
   - Revenue statistics
   - Sales count and averages

6. **Error Handling**
   - Insufficient stock detection
   - Product validation
   - Transaction rollback on errors

---

## 🚀 API Endpoints

```
POST   /api/admin/offline-sales           Create new sale
GET    /api/admin/offline-sales           List all sales
GET    /api/admin/offline-sales/stats     Get statistics
GET    /api/admin/offline-sales/:id       Get sale details
GET    /api/admin/invoices/admin-daily    Get daily invoice
```

---

## 💡 Example: Create a Sale

```bash
curl -X POST http://localhost:5000/api/admin/offline-sales \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "items": [
      {"productId": "product-uuid-1", "quantity": 5},
      {"productId": "product-uuid-2", "quantity": 2}
    ],
    "customerName": "John Doe",
    "paymentMethod": "cash"
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "Offline sale created successfully",
  "data": {
    "saleNumber": "SALE-20260104-143022-abc123",
    "totalAmount": "235.00",
    "items": [...],
    "invoice": {
      "invoiceNumber": "INV-ADMIN-20260104",
      "totalAmount": "235.00"
    }
  }
}
```

---

## 📊 Database Changes

### New Table: `OfflineSales`
Stores all offline sale records with:
- Sale number (unique)
- Items sold (JSONB)
- Total amount
- Customer details (optional)
- Payment method
- Link to daily invoice

### Updated Table: `Invoices`
Added new invoice type: `admin_daily`

---

## 🧪 Testing

### Option 1: Automated Test
```bash
cd backend
node test-offline-sales.js
```

### Option 2: Postman
1. Import: `Offline_Sales_API.postman_collection.json`
2. Set variables: `adminToken`, `productId1`, `productId2`
3. Run requests

### Option 3: Manual cURL
See examples in `OFFLINE_SALES_QUICKSTART.md`

---

## 🔐 Security

- ✅ Admin-only access (JWT authentication)
- ✅ Input validation on all fields
- ✅ SQL injection protection (Sequelize ORM)
- ✅ Atomic transactions (rollback on errors)
- ✅ Stock validation (prevent overselling)

---

## 📱 Frontend Integration (Next Step)

Ready for Flutter integration! Example service:

```dart
class OfflineSaleService {
  Future<OfflineSale> createSale({
    required List<SaleItem> items,
    String? customerName,
    String paymentMethod = 'cash',
  }) async {
    final response = await apiService.post(
      '/admin/offline-sales',
      data: {
        'items': items.map((i) => {
          'productId': i.productId,
          'quantity': i.quantity,
        }).toList(),
        'customerName': customerName,
        'paymentMethod': paymentMethod,
      },
    );
    return OfflineSale.fromJson(response['data']);
  }
}
```

See complete Flutter integration guide in `OFFLINE_SALES_FEATURE.md`.

---

## 🛠️ Troubleshooting

### Migration Fails
```bash
# Check if table exists
# Drop and recreate if needed
cd backend
node migrations/20260104_add_offline_sales.js
```

### Authentication Error
- Ensure you have a valid admin JWT token
- Token format: `Bearer YOUR_TOKEN`

### Stock Not Reducing
- Check backend logs: `backend/logs/`
- Verify transaction is committing
- Check product ID is correct

### Invoice Not Found
- Run migration to add `admin_daily` enum value
- Check date format: `YYYY-MM-DD`

---

## 📈 What Gets Tracked

| Metric | Description |
|--------|-------------|
| Total Sales | Number of transactions |
| Total Revenue | Sum of all sales amounts |
| Average Sale | Mean transaction value |
| Daily Invoice | Accumulated daily sales |
| Stock Levels | Real-time inventory |
| Payment Methods | Cash, Card, UPI breakdown |

---

## 🎁 Bonus Features

1. **Flexible Item Storage** - JSONB allows custom item fields
2. **Soft Deletes** - Sales can be archived, not destroyed
3. **Audit Trail** - CreatedAt/UpdatedAt timestamps
4. **Scalable** - Proper indexes for fast queries
5. **Transaction Safe** - All-or-nothing operations

---

## 📞 Need Help?

1. **Quick Setup**: Read `OFFLINE_SALES_QUICKSTART.md`
2. **API Reference**: Read `OFFLINE_SALES_FEATURE.md`
3. **Technical Details**: Read `OFFLINE_SALES_IMPLEMENTATION.md`
4. **Test APIs**: Use Postman collection
5. **Backend Logs**: Check `backend/logs/`

---

## ✅ Pre-Deployment Checklist

- [ ] Run migration on production DB
- [ ] Test with Postman collection
- [ ] Verify stock reduction works
- [ ] Verify invoice creation works
- [ ] Test error scenarios
- [ ] Check backend logs
- [ ] Create admin user if needed
- [ ] Add some products if needed
- [ ] Document admin credentials
- [ ] Train admin staff on usage

---

## 🏗️ Project Structure

```
backend/
├── src/
│   ├── models/
│   │   ├── OfflineSale.js          ⭐ NEW
│   │   └── Invoice.js               ✏️ UPDATED
│   ├── services/
│   │   └── offlineSale.service.js  ⭐ NEW
│   ├── controllers/
│   │   └── admin.controller.js     ✏️ UPDATED
│   ├── routes/
│   │   └── admin.routes.js         ✏️ UPDATED
│   └── config/
│       └── db.js                    ✏️ UPDATED
├── migrations/
│   └── 20260104_add_offline_sales.js ⭐ NEW
└── test-offline-sales.js            ⭐ NEW

Documentation/
├── OFFLINE_SALES_FEATURE.md         ⭐ Complete API docs
├── OFFLINE_SALES_QUICKSTART.md      ⭐ Setup guide
├── OFFLINE_SALES_IMPLEMENTATION.md  ⭐ Technical summary
└── OFFLINE_SALES_README.md          ⭐ This file

Testing/
├── Offline_Sales_API.postman_collection.json ⭐ API tests
└── START_OFFLINE_SALES.bat          ⭐ Setup script
```

---

## 🎯 Success Indicators

After setup, you should see:

✅ Migration completed successfully  
✅ Test script passes all checks  
✅ OfflineSales table exists in DB  
✅ Invoice enum includes 'admin_daily'  
✅ API endpoints return 200/201 responses  
✅ Stock reduces when sale is created  
✅ Daily invoice updates automatically  

---

## 🚀 Deployment Steps

### 1. Development Testing
```bash
START_OFFLINE_SALES.bat  # Windows
# or
node backend/test-offline-sales.js  # Linux/Mac
```

### 2. Staging Deployment
```bash
# On staging server
cd backend
node migrations/20260104_add_offline_sales.js
npm restart
```

### 3. Production Deployment
```bash
# Backup database first!
pg_dump your_db > backup.sql

# Run migration
cd backend
node migrations/20260104_add_offline_sales.js

# Restart server
pm2 restart all  # or your process manager
```

### 4. Verification
```bash
# Run health check
curl http://your-domain/api/admin/offline-sales/stats \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

---

## 🎉 You're All Set!

The **Offline Sales** feature is:
- ✅ Fully implemented
- ✅ Thoroughly documented
- ✅ Tested and verified
- ✅ Production ready

**Next Steps:**
1. Run `START_OFFLINE_SALES.bat` (or the manual commands)
2. Test with Postman
3. Build Flutter UI screens
4. Train admin users
5. Go live! 🚀

---

**Questions?** Check the documentation files listed above.

**Issues?** Check backend logs in `backend/logs/`

**Ready?** Run `START_OFFLINE_SALES.bat` now!

---

*Last Updated: January 4, 2026*  
*Version: 1.0.0*  
*Status: ✅ Production Ready*

