# API Documentation - Ksheermitra

Complete API reference for the Ksheermitra Smart Milk Delivery System.

## Base URL
```
Development: http://localhost:3000/api
Production: https://api.ksheermitra.com/api
```

## Authentication

All endpoints except `/auth/*` require JWT authentication.

**Header:**
```
Authorization: Bearer <token>
```

## Response Format

### Success Response
```json
{
  "success": true,
  "data": { },
  "message": "Success message"
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error message",
  "errors": [
    {
      "field": "fieldName",
      "message": "Error description"
    }
  ]
}
```

---

## Authentication Endpoints

### Send OTP
Send OTP to user's WhatsApp.

**Endpoint:** `POST /auth/send-otp`

**Request Body:**
```json
{
  "phone": "+919876543210"
}
```

**Response:**
```json
{
  "success": true,
  "message": "OTP sent successfully",
  "expiresAt": "2024-01-01T10:10:00.000Z"
}
```

---

### Verify OTP
Verify OTP and get authentication token.

**Endpoint:** `POST /auth/verify-otp`

**Request Body:**
```json
{
  "phone": "+919876543210",
  "otp": "123456"
}
```

**Response:**
```json
{
  "success": true,
  "user": {
    "id": "uuid",
    "name": "User Name",
    "phone": "+919876543210",
    "role": "customer",
    "email": null,
    "address": null,
    "latitude": null,
    "longitude": null,
    "areaId": null,
    "isActive": true
  },
  "token": "jwt.token.here",
  "refreshToken": "refresh.token.here"
}
```

---

### Refresh Token
Get new access token using refresh token.

**Endpoint:** `POST /auth/refresh-token`

**Request Body:**
```json
{
  "refreshToken": "refresh.token.here"
}
```

**Response:**
```json
{
  "success": true,
  "token": "new.jwt.token.here"
}
```

---

## Customer Endpoints

All customer endpoints require authentication with `customer` role.

### Get Profile
**Endpoint:** `GET /customer/profile`

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Customer Name",
    "phone": "+919876543210",
    "email": "customer@example.com",
    "address": "123 Main St",
    "latitude": "12.9716",
    "longitude": "77.5946",
    "areaId": "area-uuid",
    "area": {
      "id": "area-uuid",
      "name": "Zone A"
    }
  }
}
```

---

### Update Profile
**Endpoint:** `PUT /customer/profile`

**Request Body:**
```json
{
  "name": "Updated Name",
  "email": "newemail@example.com",
  "address": "New Address",
  "latitude": "12.9716",
  "longitude": "77.5946"
}
```

---

### Create Subscription
**Endpoint:** `POST /customer/subscriptions`

**Request Body:**
```json
{
  "productId": "product-uuid",
  "quantity": 1.0,
  "frequency": "daily",
  "selectedDays": [1, 3, 5],
  "startDate": "2024-01-01",
  "endDate": "2024-12-31"
}
```

**Frequency Options:**
- `daily` - Every day
- `weekly` - Selected days of week
- `monthly` - Same date every month
- `custom` - Custom schedule

**Selected Days:** (0=Sunday, 1=Monday, ..., 6=Saturday)

---

### Get Subscriptions
**Endpoint:** `GET /customer/subscriptions`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "subscription-uuid",
      "customerId": "customer-uuid",
      "productId": "product-uuid",
      "quantity": 1.0,
      "frequency": "daily",
      "selectedDays": null,
      "startDate": "2024-01-01",
      "endDate": "2024-12-31",
      "status": "active",
      "product": {
        "id": "product-uuid",
        "name": "Full Cream Milk",
        "unit": "liter",
        "pricePerUnit": 60.00
      }
    }
  ]
}
```

---

### Pause Subscription
**Endpoint:** `POST /customer/subscriptions/:id/pause`

**Request Body:**
```json
{
  "pauseStartDate": "2024-06-01",
  "pauseEndDate": "2024-06-15"
}
```

---

### Resume Subscription
**Endpoint:** `POST /customer/subscriptions/:id/resume`

---

### Get Delivery History
**Endpoint:** `GET /customer/deliveries`

**Query Parameters:**
- `startDate` (optional): YYYY-MM-DD
- `endDate` (optional): YYYY-MM-DD

---

### Get Invoices
**Endpoint:** `GET /customer/invoices`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "invoice-uuid",
      "invoiceNumber": "INV-M-202401-12345",
      "type": "monthly",
      "invoiceDate": "2024-01-01",
      "periodStart": "2024-01-01",
      "periodEnd": "2024-01-31",
      "totalAmount": 1800.00,
      "paidAmount": 0.00,
      "paymentStatus": "pending",
      "pdfPath": "/path/to/invoice.pdf"
    }
  ]
}
```

---

## Delivery Boy Endpoints

All delivery boy endpoints require authentication with `delivery_boy` role.

### Get Assigned Customers
**Endpoint:** `GET /delivery/customers`

**Query Parameters:**
- `date` (optional): YYYY-MM-DD (defaults to today)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "customer-uuid",
      "name": "Customer Name",
      "phone": "+919876543210",
      "address": "123 Main St",
      "latitude": "12.9716",
      "longitude": "77.5946",
      "deliveries": [
        {
          "id": "delivery-uuid",
          "productName": "Full Cream Milk",
          "quantity": 1.0,
          "unit": "liter",
          "amount": 60.00,
          "status": "pending"
        }
      ]
    }
  ]
}
```

---

### Get Optimized Route
**Endpoint:** `GET /delivery/route`

**Query Parameters:**
- `date` (optional): YYYY-MM-DD

**Response:**
```json
{
  "success": true,
  "data": {
    "optimizedOrder": [0, 2, 1],
    "optimizedDestinations": [
      {
        "id": "customer-uuid",
        "name": "Customer Name",
        "latitude": "12.9716",
        "longitude": "77.5946"
      }
    ],
    "routes": [
      {
        "startAddress": "Start Location",
        "endAddress": "Customer 1",
        "distance": "2.5 km",
        "duration": "10 mins",
        "distanceMeters": 2500,
        "durationSeconds": 600
      }
    ],
    "totalDistance": 5000,
    "totalDuration": 1200
  }
}
```

---

### Update Delivery Status
**Endpoint:** `PUT /delivery/delivery-status`

**Request Body:**
```json
{
  "deliveryId": "delivery-uuid",
  "status": "delivered",
  "notes": "Delivered successfully"
}
```

**Status Options:** `delivered`, `missed`

---

### Get Delivery Stats
**Endpoint:** `GET /delivery/stats`

**Query Parameters:**
- `date` (optional): YYYY-MM-DD

**Response:**
```json
{
  "success": true,
  "data": {
    "pending": 10,
    "delivered": 45,
    "missed": 2,
    "cancelled": 1,
    "totalDelivered": 45,
    "totalAmount": 2700.00
  }
}
```

---

### Generate Daily Invoice
**Endpoint:** `POST /delivery/generate-invoice`

**Request Body:**
```json
{
  "date": "2024-01-15"
}
```

---

## Admin Endpoints

All admin endpoints require authentication with `admin` role.

### List Customers
**Endpoint:** `GET /admin/customers`

**Query Parameters:**
- `page` (default: 1)
- `limit` (default: 50)
- `search` (optional): Search by name or phone

**Response:**
```json
{
  "success": true,
  "data": {
    "customers": [
      {
        "id": "uuid",
        "name": "Customer Name",
        "phone": "+919876543210",
        "email": "customer@example.com",
        "address": "123 Main St",
        "latitude": "12.9716",
        "longitude": "77.5946",
        "areaId": "area-uuid",
        "area": {
          "id": "area-uuid",
          "name": "Zone A",
          "deliveryBoy": {
            "id": "db-uuid",
            "name": "Delivery Boy Name"
          }
        }
      }
    ],
    "pagination": {
      "total": 100,
      "page": 1,
      "limit": 50,
      "totalPages": 2
    }
  }
}
```

---

### Get Customers with Locations
**Endpoint:** `GET /admin/customers/map`

Returns all customers with GPS coordinates for map view.

---

### List Delivery Boys
**Endpoint:** `GET /admin/delivery-boys`

---

### Create Delivery Boy
**Endpoint:** `POST /admin/delivery-boys`

**Request Body:**
```json
{
  "name": "Delivery Boy Name",
  "phone": "+919876543211",
  "email": "db@example.com",
  "address": "Address",
  "latitude": "12.9716",
  "longitude": "77.5946"
}
```

---

### Assign Area
**Endpoint:** `POST /admin/assign-area`

**Request Body:**
```json
{
  "customerId": "customer-uuid",
  "areaId": "area-uuid"
}
```

---

### Bulk Assign Area
**Endpoint:** `POST /admin/bulk-assign-area`

**Request Body:**
```json
{
  "customerIds": ["uuid1", "uuid2", "uuid3"],
  "areaId": "area-uuid"
}
```

---

### List Areas
**Endpoint:** `GET /admin/areas`

---

### Create Area
**Endpoint:** `POST /admin/areas`

**Request Body:**
```json
{
  "name": "Zone E",
  "description": "New delivery zone",
  "deliveryBoyId": "db-uuid"
}
```

---

### Update Area
**Endpoint:** `PUT /admin/areas/:id`

**Request Body:**
```json
{
  "name": "Updated Zone Name",
  "deliveryBoyId": "new-db-uuid",
  "isActive": true
}
```

---

### List Products
**Endpoint:** `GET /admin/products`

---

### Create Product
**Endpoint:** `POST /admin/products`

**Request Body:**
```json
{
  "name": "Product Name",
  "description": "Product description",
  "unit": "liter",
  "pricePerUnit": 60.00,
  "stock": 1000
}
```

**Unit Options:** `liter`, `ml`, `kg`, `gm`, `piece`

---

### Update Product
**Endpoint:** `PUT /admin/products/:id`

**Request Body:**
```json
{
  "name": "Updated Name",
  "pricePerUnit": 65.00,
  "isActive": true
}
```

---

### Get Daily Invoices
**Endpoint:** `GET /admin/invoices/daily`

**Query Parameters:**
- `startDate` (optional): YYYY-MM-DD
- `endDate` (optional): YYYY-MM-DD
- `deliveryBoyId` (optional): Filter by delivery boy

---

## Error Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request (validation error) |
| 401 | Unauthorized (invalid token) |
| 403 | Forbidden (insufficient permissions) |
| 404 | Not Found |
| 409 | Conflict (duplicate entry) |
| 429 | Too Many Requests (rate limited) |
| 500 | Internal Server Error |

---

## Rate Limiting

- Default: 100 requests per 15 minutes per IP
- Configurable via `RATE_LIMIT_WINDOW_MS` and `RATE_LIMIT_MAX_REQUESTS` in .env

---

## Testing with cURL

### Get Token
```bash
# Send OTP
curl -X POST http://localhost:3000/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "+919876543210"}'

# Verify OTP
curl -X POST http://localhost:3000/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "+919876543210", "otp": "123456"}'
```

### Use Token
```bash
TOKEN="your.jwt.token.here"

curl -X GET http://localhost:3000/api/customer/profile \
  -H "Authorization: Bearer $TOKEN"
```

---

## Postman Collection

Import this base request:
- **Base URL**: `{{baseUrl}}/api`
- **Authorization**: Bearer Token
- **Headers**: `Content-Type: application/json`

Create environment variables:
- `baseUrl`: http://localhost:3000
- `token`: (auto-set after login)
