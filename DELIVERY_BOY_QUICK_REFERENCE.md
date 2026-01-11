# 🚚 DELIVERY BOY API - QUICK REFERENCE CARD

## 🔗 Base URL
```
http://localhost:3000/api/delivery-boy
```

## 🔐 Authentication
All endpoints require JWT token in header:
```
Authorization: Bearer <your_jwt_token>
```

---

## 📍 ENDPOINTS QUICK REFERENCE

### 1. GET /delivery-map
**Purpose:** Get today's delivery routes
```bash
GET /api/delivery-boy/delivery-map?date=2025-11-02
```
**Response:** List of deliveries with customer locations

---

### 2. POST /generate-invoice
**Purpose:** Generate daily invoice
```bash
POST /api/delivery-boy/generate-invoice
Body: {"date": "2025-11-02"}
```
**Response:** Invoice ID, number, total amount

---

### 3. GET /history
**Purpose:** View past deliveries
```bash
GET /api/delivery-boy/history?page=1&limit=10
```
**Response:** Paginated delivery history

---

### 4. GET /stats
**Purpose:** View performance stats
```bash
GET /api/delivery-boy/stats?period=today
```
**Periods:** today, week, month, all
**Response:** Total deliveries, earnings, completion rate

---

### 5. PATCH /delivery/:id/status
**Purpose:** Update delivery status
```bash
PATCH /api/delivery-boy/delivery/{id}/status
Body: {
  "status": "delivered",
  "notes": "Completed",
  "latitude": 12.9716,
  "longitude": 77.5946
}
```
**Status Values:** pending, in-progress, delivered, failed

---

### 6. GET /profile
**Purpose:** Get delivery boy profile
```bash
GET /api/delivery-boy/profile
```
**Response:** Profile info, assigned areas

---

### 7. PUT /location
**Purpose:** Update current location
```bash
PUT /api/delivery-boy/location
Body: {
  "latitude": 12.9716,
  "longitude": 77.5946
}
```

---

## ⚡ QUICK COMMANDS

### PowerShell Testing
```powershell
# Set token
$TOKEN = "your_jwt_token_here"

# Test delivery map
curl -X GET "http://localhost:3000/api/delivery-boy/delivery-map" `
  -H "Authorization: Bearer $TOKEN"

# Test stats
curl -X GET "http://localhost:3000/api/delivery-boy/stats?period=today" `
  -H "Authorization: Bearer $TOKEN"

# Generate invoice
curl -X POST "http://localhost:3000/api/delivery-boy/generate-invoice" `
  -H "Authorization: Bearer $TOKEN" `
  -H "Content-Type: application/json" `
  -d '{\"date\": \"2025-11-02\"}'
```

---

## 🔧 COMMON TASKS

### Get JWT Token
```powershell
# 1. Send OTP
curl -X POST http://localhost:3000/api/auth/send-otp `
  -H "Content-Type: application/json" `
  -d '{\"phone\": \"+919876543210\"}'

# 2. Verify OTP (check WhatsApp/DB for OTP)
curl -X POST http://localhost:3000/api/auth/verify-otp `
  -H "Content-Type: application/json" `
  -d '{\"phone\": \"+919876543210\", \"otp\": \"123456\"}'

# Copy accessToken from response
```

### Check Server Health
```bash
curl http://localhost:3000/health
```

### View Logs
```powershell
type backend\logs\error.log
```

---

## 🐛 TROUBLESHOOTING

| Error | Solution |
|-------|----------|
| 404 Not Found | Restart server: `npm start` |
| 401 Unauthorized | Get new JWT token |
| 403 Forbidden | Check user role is 'delivery_boy' |
| Database error | Run migration script |
| Empty response | Normal if no data exists |

---

## 📱 RESPONSE FORMATS

### Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { /* result */ }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error description",
  "errors": [ /* details */ ]
}
```

---

## 🗂️ STATUS VALUES

### Delivery Status
- `pending` - Not started
- `in-progress` - On the way
- `delivered` - Completed
- `failed` - Could not deliver
- `missed` - Customer not available
- `cancelled` - Cancelled

### Invoice Status
- `pending` - Not generated
- `generated` - Created
- `sent` - Sent to delivery boy
- `paid` - Payment received

---

## 📊 DATABASE QUICK QUERIES

### Check Deliveries
```sql
SELECT * FROM "Deliveries" 
WHERE "deliveryBoyId" = 'your-uuid'
ORDER BY "deliveryDate" DESC
LIMIT 10;
```

### Check Today's Stats
```sql
SELECT status, COUNT(*) 
FROM "Deliveries" 
WHERE "deliveryBoyId" = 'your-uuid' 
  AND "deliveryDate" = CURRENT_DATE
GROUP BY status;
```

### Check Invoices
```sql
SELECT * FROM "Invoices"
WHERE "deliveryBoyId" = 'your-uuid'
ORDER BY "invoiceDate" DESC
LIMIT 5;
```

---

## 🎯 TYPICAL WORKFLOW

1. **Morning:** Login → Get delivery map
2. **During Day:** Update status as you deliver
3. **After Delivery:** Mark as delivered with location
4. **Evening:** Generate invoice for the day
5. **Anytime:** Check stats and history

---

## 📞 SUPPORT FILES

- `START_HERE_DELIVERY_BOY.md` - 5-min setup
- `DELIVERY_BOY_API_COMPLETE.md` - Full docs
- `Delivery_Boy_API.postman_collection.json` - Postman
- `test-delivery-boy-api.bat` - Test script

---

## ⚙️ CONFIGURATION

### Environment Variables
```env
PORT=3000
JWT_SECRET=your-secret
DATABASE_URL=postgresql://...
```

### Database
- PostgreSQL 12+
- Run migration: `update-invoice-delivery-enums.sql`

### Dependencies
- Node.js 14+
- Express 4.18+
- Sequelize 6.31+

---

## ✅ DEPLOYMENT CHECKLIST

- [ ] Run database migration
- [ ] Restart backend server
- [ ] Test health endpoint
- [ ] Test all 7 endpoints
- [ ] Import Postman collection
- [ ] Share with frontend team

---

## 🚀 READY TO USE!

**Current Status:** ✅ PRODUCTION READY

**Next Action:** Run migration & restart server

**Questions?** Check full documentation

---

*Quick Reference Card v1.0*
*Last Updated: November 2, 2025*

