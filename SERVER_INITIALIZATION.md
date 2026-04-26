# Server Initialization & Database Setup

> **Last Updated:** April 26, 2026  
> **Version:** 2.0  
> **Status:** Production Ready

## Overview

The Ksheer Mitra backend now has automated initialization that runs on every server startup. No manual seeding required!

### What Happens on Server Startup?

```
1. Database Connection ✓
2. Database Sync (creates/updates schema) ✓
3. Run Initialization Service ✓
   ├─ Create/Verify Admin User
   ├─ Load Customer Data (if seed file exists)
   └─ Delete Seed File (after successful import)
4. Initialize WhatsApp Service ✓
5. Start Cron Jobs ✓
6. Server Ready ✓
```

---

## Admin User Injection

### Automatic Creation

The admin user is automatically created on first server start with credentials from environment variables:

```env
ADMIN_PHONE=8374186557
ADMIN_NAME=Admin User
```

### What Gets Created?

```
User {
  phone: ADMIN_PHONE,
  name: ADMIN_NAME,
  role: 'admin',
  isActive: true
}
```

### Environment Variables Used

| Variable | Default | Purpose |
|----------|---------|---------|
| `ADMIN_PHONE` | 8374186557 | Admin phone number (used as login) |
| `ADMIN_NAME` | Admin User | Admin display name |

---

## Customer Data Seeding

### How It Works

1. **Place seed file** → `backend/seed-customers.txt`
2. **Start server** → `npm start`
3. **File processed** → Customers inserted into database
4. **File deleted** → Automatically removed after import

### Seed File Format

File: `backend/seed-customers.txt`

**Format:** TSV (Tab-Separated Values)

```
<Phone>\t<Name>\t<Latitude>\t<Longitude>
```

**Example:**
```
6281816608	bhanumathi	14°27'05.2"N	79°59'26.2"E
9949067872	Sunitha ch	14°26'45.3"N	79°59'21.6"E
9848618181	Amala	14°26'43.9"N	79°59'26.5"E
```

### Coordinate Format Support

**Format 1: DMS (Degrees, Minutes, Seconds)**
```
14°27'05.2"N 79°59'26.2"E
```

**Format 2: Decimal** (if supported in future)
```
14.45144 79.99072
```

### Running Customer Seeding

1. Create/edit `backend/seed-customers.txt` with your customer data
2. Start the server:
   ```bash
   npm start
   ```
3. Check logs for status:
   ```
   ✅ Customer seeding completed:
      - Inserted: 28
      - Skipped: 2
   🗑️  Seed file deleted: seed-customers.txt
   ```

---

## Features

### ✅ Automatic Admin Creation

- Creates admin on first startup
- Uses ADMIN_PHONE and ADMIN_NAME from env
- Ensures admin role on every restart
- No manual commands needed

### ✅ Automatic Customer Seeding

- Reads from `seed-customers.txt` if it exists
- Parses DMS coordinates automatically
- Skips duplicates (checks phone number)
- Reports: inserted, skipped, errors
- **Automatically deletes seed file after processing**

### ✅ Safe & Idempotent

- Won't create duplicates
- Can run multiple times
- Errors don't stop server
- All logged for debugging

### ✅ Production Ready

- No manual seeding commands
- Credentials from environment
- Handles files gracefully
- Full error handling

---

## Environment Variables

### Required

```env
# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=ksheermitra_new
DB_USER=postgres
DB_PASSWORD=your_password

# Admin
ADMIN_PHONE=8374186557
ADMIN_NAME=Admin User
```

### Optional

```env
# WhatsApp Admin Login
WHATSAPP_ADMIN_USERNAME=8374186557
WHATSAPP_ADMIN_PASSWORD=V4@chparuma
```

---

## Setup Instructions

### 1. First Time Setup

```bash
# Create .env file
cp backend/.env.example backend/.env

# Update database credentials
# Update admin credentials
# Update WhatsApp credentials (optional)

# Install dependencies
cd backend
npm install

# Run database migration (one-time)
npm run migrate

# Create seed file (if you have customer data)
# Save customer data to backend/seed-customers.txt

# Start server
npm start
```

### 2. Server Startup Process

```bash
npm start

# Output:
# ✅ Database connection established
# ✅ Database synchronized
# ✅ Starting initialization service...
# ✅ Admin user verified: Admin User (8374186557)
# ✅ Found seed-customers.txt. Starting customer seeding...
# ✅ Customer seeding completed:
#    - Inserted: 28
#    - Skipped: 2
# 🗑️  Seed file deleted: seed-customers.txt
# ✅ WhatsApp service initialized
# ✅ Cron jobs started
# ✅ Server is running on port 3000
```

---

## Customer Seeding Details

### Seed File Processing

```
backend/seed-customers.txt
         ↓
     (On startup)
         ↓
  Parse TSV format
         ↓
  For each customer:
    ├─ Parse coordinates
    ├─ Check if exists
    ├─ Create if new
    └─ Skip if duplicate
         ↓
  Report statistics
         ↓
 Delete seed file
         ↓
   ✅ Done
```

### Coordinate Parsing

Supports DMS format automatically:

```
14°27'05.2"N → 14.45144
79°59'26.2"E → 79.99072
14°26'45.3"N → 14.44592
79°59'21.6"E → 79.98933
```

### Error Handling

- ✅ Skips invalid coordinates
- ✅ Skips duplicate phone numbers
- ✅ Continues on errors
- ✅ Reports errors in logs
- ✅ Deletes file even on partial failure

---

## Seeding Examples

### Example 1: Full Data with Coordinates

```
6281816608	bhanumathi	14°27'05.2"N	79°59'26.2"E
9949067872	Sunitha ch	14°26'45.3"N	79°59'21.6"E
9848618181	Amala	14°26'43.9"N	79°59'26.5"E
```

### Example 2: Data Without Coordinates

```
9989154505	balayha
8309458661	ty krishna
9866820357	VenkatSubbaReddy(Jagans college opp) vasantha kumari
```

### Example 3: Mixed

```
6281816608	bhanumathi	14°27'05.2"N	79°59'26.2"E
9949067872	Sunitha ch	
9848618181	Amala	14°26'43.9"N	79°59'26.5"E
```

---

## Common Commands

### Start Server with Auto-Init

```bash
cd backend
npm start
```

### View Initialization Logs

```bash
# While server is running, check logs:
tail -f logs/combined.log | grep -i "initialization\|seeding\|admin"
```

### Verify Admin User

```sql
SELECT * FROM "Users" WHERE phone = '8374186557' AND role = 'admin';
```

### Verify Customers Inserted

```sql
SELECT COUNT(*) as total_customers FROM "Users" WHERE role = 'customer';
```

---

## Troubleshooting

### Issue: Admin Not Created

**Check:** Is ADMIN_PHONE in .env correctly set?

```bash
grep ADMIN_PHONE backend/.env
```

**Check logs:**
```
tail -f logs/combined.log | grep -i "admin"
```

---

### Issue: Customers Not Seeded

**Check 1:** Does `seed-customers.txt` exist?
```bash
ls -la backend/seed-customers.txt
```

**Check 2:** Is file format correct (TSV)?
```bash
cat backend/seed-customers.txt | head -5
```

**Check 3:** Are phone numbers valid?
```
Must start with 6-9 and be 10 digits
```

**Check logs:**
```
tail -f logs/combined.log | grep -i "seeding"
```

---

### Issue: Seed File Not Deleted

**Manual cleanup:**
```bash
rm backend/seed-customers.txt
```

**Check permissions:**
```bash
ls -la backend/seed-customers.txt
```

---

## Database Cleanup (if needed)

### Delete All Customers

```sql
DELETE FROM "Users" WHERE role = 'customer';
```

### Reset to Admin Only

```sql
DELETE FROM "Users" WHERE role != 'admin';
```

### Full Reset (⚠️ Use with Caution)

```bash
# Drop and recreate database
npm run migrate:undo
npm run migrate
npm start
```

---

## Production Deployment

### On Render.com

1. Set environment variables in Render dashboard
2. Deploy code
3. Place `seed-customers.txt` if needed
4. Trigger deploy
5. Seed file will be processed on startup

### On AWS / DigitalOcean

1. Update `.env` file
2. Place `seed-customers.txt` if needed
3. Run: `npm start`
4. Verify in logs

---

## Files Modified/Created

### New Files
- ✨ `backend/src/services/initialization.service.js` - Initialization logic
- ✨ `backend/seed-customers.txt` - Customer seed data (created by user)

### Modified Files
- 📝 `backend/src/server.js` - Added initialization service call

### Deleted Files (Cleanup)
- 🗑️ `backend/bulk-insert-customers.js`
- 🗑️ `backend/update-customer-coordinates.js`
- 🗑️ `backend/migrations/*.sql` (all SQL files)

---

## API References

All APIs are now available with automatic admin and customer data!

```bash
# Get admin token
curl -X POST http://localhost:3000/api/auth/admin-login \
  -H "Content-Type: application/json" \
  -d '{"phone": "8374186557", "password": "OTP"}'

# List customers
curl http://localhost:3000/api/admin/customers \
  -H "Authorization: Bearer <admin_token>"
```

---

## Support

For questions or issues:

1. Check logs: `tail -f logs/combined.log`
2. Verify .env: `cat backend/.env`
3. Check seed file: `cat backend/seed-customers.txt`
4. Verify database: Connect and run SQL queries

---

## Summary

✅ **Automatic** - Everything runs on startup  
✅ **Safe** - Handles errors gracefully  
✅ **Clean** - Deletes files after processing  
✅ **Production-Ready** - All functionality working  
✅ **Zero Manual Steps** - Just start the server!

---

**Version:** 2.0  
**Last Updated:** April 26, 2026  
**Status:** ✅ Production Ready

