# WhatsApp Admin QR Login - Quick Start Guide

## ⚡ 5-Minute Setup

### 1. Update Environment Variables
Add to your `.env` file:
```env
WHATSAPP_ADMIN_USERNAME=admin
WHATSAPP_ADMIN_PASSWORD=your_secure_password_here
```

### 2. Install Dependencies
```bash
cd backend
npm install
```

### 3. Run Migration
```bash
npm run migrate
```

### 4. Start Server
```bash
npm start
```

### 5. Test It Out
```bash
# Get QR Code
curl -X POST http://localhost:3000/api/whatsapp-login/get-qr \
  -H "Authorization: Basic $(echo -n 'admin:your_secure_password_here' | base64)" \
  -H "Content-Type: application/json"
```

## 🎯 What You Just Deployed

✅ WhatsApp QR code generation endpoint
✅ Session status monitoring
✅ Automatic expiration alerts
✅ Session reset functionality
✅ Admin authentication with username/password

## 📍 Key Files to Know

| File | Purpose |
|------|---------|
| `backend/src/routes/whatsappLogin.routes.js` | API endpoints |
| `backend/src/services/whatsappSession.service.js` | Business logic |
| `backend/src/middleware/whatsapp-auth.middleware.js` | Authentication |
| `backend/src/services/cron.service.js` | Expiration checks |

## 🔗 API Endpoints

```
POST   /api/whatsapp-login/get-qr      # Get QR code
GET    /api/whatsapp-login/status      # Check status
GET    /api/whatsapp-login/info        # Get detailed info
POST   /api/whatsapp-login/reset       # Reset session
```

**All require**: `Authorization: Basic <base64(username:password)>`

## 🧪 Simple Test

```javascript
// Change to this script and run: node this-script.js
const http = require('http');

const username = 'admin';
const password = 'your_secure_password_here';
const auth = Buffer.from(`${username}:${password}`).toString('base64');

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/api/whatsapp-login/status',
  method: 'GET',
  headers: {
    'Authorization': `Basic ${auth}`
  }
};

http.request(options, (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => console.log(JSON.parse(data)));
}).end();
```

## 📱 Frontend Integration (Flutter)

```dart
// Add to your admin dashboard
import 'services/whatsapp_login.service.dart';

final whatsappService = WhatsAppLoginService(
  baseUrl: 'http://localhost:3000',
  username: 'admin',
  password: 'your_secure_password_here',
);

// Get QR code to display
final qr = await whatsappService.getQRCode();
print(qr.qrCode); // Base64 image data

// Check if expiring soon
final expiring = await whatsappService.isSessionExpiringSoon();
if (expiring) {
  // Show alert to admin
}
```

## 🔍 Checking Status via API

```bash
# 1. Get QR code
curl -X POST http://localhost:3000/api/whatsapp-login/get-qr \
  -H "Authorization: Basic $(echo -n 'admin:password' | base64)" \
  -H "Content-Type: application/json"

# 2. Check status (after scanning QR)
curl http://localhost:3000/api/whatsapp-login/status \
  -H "Authorization: Basic $(echo -n 'admin:password' | base64)"

# 3. Get info with alert
curl http://localhost:3000/api/whatsapp-login/info \
  -H "Authorization: Basic $(echo -n 'admin:password' | base64)"

# 4. Reset if needed
curl -X POST http://localhost:3000/api/whatsapp-login/reset \
  -H "Authorization: Basic $(echo -n 'admin:password' | base64)" \
  -H "Content-Type: application/json"
```

## 📊 Database Schema

New table: `WhatsAppSessions`

```sql
CREATE TABLE "WhatsAppSessions" (
  id UUID PRIMARY KEY,
  sessionQrCode TEXT,
  lastQrGeneratedAt DATE,
  sessionStartedAt DATE,
  sessionExpiresAt DATE,
  isConnected BOOLEAN,
  connectionState ENUM('disconnected', 'connecting', 'open', 'closed'),
  expirationNotificationSentAt DATE,
  metadata JSON,
  createdAt DATE,
  updatedAt DATE
);
```

## 🔔 Automatic Notifications

The server automatically checks every 15 minutes (configurable):

```javascript
// If session expires within 60 minutes:
// - Sends WhatsApp message to admin
// - Records notification timestamp
// - Won't send duplicate for 1 hour
```

Change check interval in `.env`:
```env
# Default: every 15 minutes
WHATSAPP_EXPIRATION_CHECK_CRON=*/15 * * * *

# Example alternatives:
# Every 5 minutes: */5 * * * *
# Every hour: 0 * * * *
# 8 AM daily: 0 8 * * *
```

## 🛠️ Troubleshooting

| Problem | Solution |
|---------|----------|
| 401 Unauthorized | Check username/password in env vars |
| QR not displaying | Ensure qrcode package installed: `npm install qrcode` |
| Notifications not sent | Verify admin user exists, WhatsApp connected |
| Database migration fails | Check PostgreSQL is running and accessible |

## 📖 More Documentation

- **Full Docs**: `WHATSAPP_LOGIN_FEATURE.md`
- **Implementation**: `IMPLEMENTATION_SUMMARY.md`
- **Testing Tool**: `test-whatsapp-login.js`
- **Frontend Service**: `ksheermitra/lib/services/whatsapp_login.service.dart`

## ✅ Verification Checklist

After setup, verify:

- [ ] .env file has WHATSAPP_ADMIN_USERNAME & PASSWORD
- [ ] npm dependencies installed (npm install)
- [ ] Database migration ran (npm run migrate)
- [ ] Server starts without errors (npm start)
- [ ] QR endpoint returns image (curl test)
- [ ] Status endpoint returns JSON (curl test)
- [ ] Admin receives test WhatsApp message (optional)

## 🎉 You're Done!

Your WhatsApp admin login feature is now active!

### Next Steps:
1. Update admin credentials to something secure
2. Integrate into your admin dashboard
3. Test with mobile scanning
4. Set up production environment variables
5. Configure backup notifications (SMS, email)

---

**Need Help?** Check the detailed documentation files in the repository.

