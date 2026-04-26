# WhatsApp Admin QR Code Login Feature

This document describes the new WhatsApp QR Code login feature for admin users.

## Overview

The WhatsApp QR Code login feature allows administrators to:
1. Generate a QR code to establish a new WhatsApp session
2. Monitor WhatsApp session status and expiration
3. Automatically receive notifications before the session expires (within 1 hour)
4. Reset and re-establish WhatsApp sessions

## Environment Variables Required

Add the following environment variables to your `.env` file:

```env
# WhatsApp Admin Credentials (for QR code login endpoint)
WHATSAPP_ADMIN_USERNAME=your_admin_username
WHATSAPP_ADMIN_PASSWORD=your_admin_password

# WhatsApp Session Expiration Check (optional, defaults to every 15 minutes)
WHATSAPP_EXPIRATION_CHECK_CRON=*/15 * * * *
```

## API Endpoints

All endpoints require **Basic Authentication** with the credentials specified above.

### 1. Get QR Code for WhatsApp Login
```
POST /api/whatsapp-login/get-qr
Content-Type: application/json
Authorization: Basic <base64(username:password)>

Response:
{
  "success": true,
  "message": "QR code generated. Scan it within 5 minutes using WhatsApp Linked Devices",
  "data": {
    "qrCode": "data:image/png;base64,iVBORw0KGgoAAAANS...",
    "sessionId": "550e8400-e29b-41d4-a716-446655440000",
    "expiresIn": 300,
    "instructions": [
      "Open WhatsApp on your phone",
      "Go to Settings > Linked Devices",
      "Click 'Link a device'",
      "Scan the QR code shown above",
      "Confirm on your phone"
    ]
  }
}
```

### 2. Get Session Status
```
GET /api/whatsapp-login/status
Authorization: Basic <base64(username:password)>

Response:
{
  "success": true,
  "data": {
    "sessionId": "550e8400-e29b-41d4-a716-446655440000",
    "isConnected": true,
    "connectionState": "open",
    "sessionStartedAt": "2026-04-26T10:30:00.000Z",
    "sessionExpiresAt": "2026-04-29T10:30:00.000Z",
    "lastQrGeneratedAt": "2026-04-26T10:25:00.000Z",
    "uptime": 12,
    "timeUntilExpiration": 72
  }
}
```

### 3. Get Detailed Session Info with Expiration Alert
```
GET /api/whatsapp-login/info
Authorization: Basic <base64(username:password)>

Response:
{
  "success": true,
  "data": {
    "session": {
      "sessionId": "550e8400-e29b-41d4-a716-446655440000",
      "isConnected": true,
      "connectionState": "open",
      ...
    },
    "whatsapp": {
      "isReady": true,
      "isInitializing": false,
      "queueLength": 0,
      "processing": false,
      "reconnectAttempts": 0,
      "maxReconnectAttempts": 5
    },
    "expirationAlert": {
      "isExpiringSoon": true,
      "expiresAt": "2026-04-29T10:30:00.000Z",
      "minutesUntilExpiry": 45,
      "message": "WhatsApp session will expire in 45 minutes. Please scan a new QR code."
    }
  }
}
```

### 4. Reset Session
```
POST /api/whatsapp-login/reset
Authorization: Basic <base64(username:password)>

Response:
{
  "success": true,
  "message": "WhatsApp session reset. Please scan the new QR code.",
  "nextAction": "GET /api/whatsapp-login/get-qr"
}
```

## Database Changes

A new table `WhatsAppSessions` has been created to track:
- Session QR codes
- Session start and expiration times
- Connection state
- Last notification time

Run migrations:
```bash
npm run migrate
```

## How It Works

### Session Lifecycle

1. **Admin requests QR code** → `POST /api/whatsapp-login/get-qr`
   - A new QR code is generated
   - Session state is set to "connecting"
   - QR code expires in 5 minutes

2. **Admin scans QR code** → Mobile confirmation
   - WhatsApp Web session is established
   - Session state changes to "open"
   - Session expiration is set to 72 hours from now

3. **Automatic expiration monitoring** → Runs every 15 minutes (cron job)
   - Server checks if session is about to expire (within 1 hour)
   - If yes, a notification is sent to admin via WhatsApp
   - Notification is only sent once per hour

4. **Notification content**:
   - ⚠️ WhatsApp Session Alert
   - Minutes until expiration
   - Action required: scan new QR code
   - Impact: deliveries may be affected

5. **Admin refreshes session** → `POST /api/whatsapp-login/get-qr`
   - New QR code is generated
   - Process repeats

### Using Basic Authentication

To make API requests with Basic auth, encode your credentials as Base64:

```javascript
// JavaScript example
const username = 'your_admin_username';
const password = 'your_admin_password';
const credentials = btoa(`${username}:${password}`);

fetch('http://localhost:3000/api/whatsapp-login/status', {
  headers: {
    'Authorization': `Basic ${credentials}`
  }
})
```

```bash
# cURL example
curl -H "Authorization: Basic $(echo -n 'username:password' | base64)" \
  http://localhost:3000/api/whatsapp-login/status
```

```python
# Python example
import requests
from requests.auth import HTTPBasicAuth

response = requests.get(
  'http://localhost:3000/api/whatsapp-login/status',
  auth=HTTPBasicAuth('username', 'password')
)
```

## Frontend Integration Example

```dart
// Flutter/Dart example
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> getWhatsAppQRCode(String baseUrl) async {
  final username = 'your_admin_username';
  final password = 'your_admin_password';
  final credentials = base64Encode(utf8.encode('$username:$password'));

  final response = await http.post(
    Uri.parse('$baseUrl/api/whatsapp-login/get-qr'),
    headers: {
      'Authorization': 'Basic $credentials',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['data']['qrCode']; // Base64 image
  } else {
    throw Exception('Failed to get QR code');
  }
}

// Check expiration status
Future<Map> checkSessionStatus(String baseUrl) async {
  final username = 'your_admin_username';
  final password = 'your_admin_password';
  final credentials = base64Encode(utf8.encode('$username:$password'));

  final response = await http.get(
    Uri.parse('$baseUrl/api/whatsapp-login/info'),
    headers: {
      'Authorization': 'Basic $credentials',
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body)['data'];
  } else {
    throw Exception('Failed to get session status');
  }
}
```

## Testing the Feature

### 1. Test QR Code Generation
```bash
curl -X POST http://localhost:3000/api/whatsapp-login/get-qr \
  -H "Authorization: Basic $(echo -n 'admin:password123' | base64)" \
  -H "Content-Type: application/json"
```

### 2. Test Session Status
```bash
curl http://localhost:3000/api/whatsapp-login/status \
  -H "Authorization: Basic $(echo -n 'admin:password123' | base64)"
```

### 3. Test Reset
```bash
curl -X POST http://localhost:3000/api/whatsapp-login/reset \
  -H "Authorization: Basic $(echo -n 'admin:password123' | base64)" \
  -H "Content-Type: application/json"
```

## Troubleshooting

### Invalid Credentials
**Error**: `401 Unauthorized - Invalid username or password`
- Check that WHATSAPP_ADMIN_USERNAME and WHATSAPP_ADMIN_PASSWORD are set correctly in .env
- Ensure credentials are properly encoded in Base64

### QR Code Not Scanning
- QR code expires after 5 minutes, generate a new one if needed
- Ensure phone camera can see the complete QR code
- Use WhatsApp's "Linked Devices" feature (not Web WhatsApp)

### Session Expiration Alert Not Received
- Check that admin user exists in the database
- Verify WHATSAPP_EXPIRATION_CHECK_CRON is configured correctly
- Check server logs for cron job execution

### WhatsApp Not Ready
**Error**: `WhatsApp is not connected! Please scan QR code or restart the server.`
- Generate a new QR code via `/api/whatsapp-login/get-qr`
- Scan it with your phone
- Wait for connection confirmation

## Security Considerations

1. **Basic Authentication**: Credentials are Base64 encoded but not encrypted. Always use HTTPS in production.
2. **Environment Variables**: Store credentials securely, never commit them to version control.
3. **Rate Limiting**: WhatsApp login endpoints are protected by the global rate limiter.
4. **CORS**: Configure CORS appropriately for your frontend domain in production.

## Future Enhancements

- [ ] Add in-app notification system for exipration alerts
- [ ] Implement WebSocket for real-time session status updates
- [ ] Add multiple admin user support
- [ ] Add session usage logs and analytics
- [ ] Implement OAuth for credentials instead of basic auth
- [ ] Add SMS fallback notification for critical alerts

