# 🚚 Delivery Boy Module - Complete API Documentation

## ✅ Implementation Status

All required API endpoints have been successfully implemented and are ready for testing.

---

## 🔐 Authentication

All delivery boy endpoints require authentication using a JWT token obtained through the auth flow.

**Headers Required:**
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

The user must have `role: 'delivery_boy'` in their JWT token.

---

## 📍 API Endpoints

### 1. **GET /api/delivery-boy/delivery-map**
Fetch assigned delivery routes for navigation with customer locations and product details.

**Query Parameters:**
- `date` (optional): ISO date string (e.g., "2025-11-02"). Defaults to today.

**Response:**
```json
{
  "success": true,
  "data": {
    "deliveryBoyId": "uuid",
    "date": "2025-11-02T00:00:00.000Z",
    "currentLocation": {
      "latitude": 12.9716,
      "longitude": 77.5946
    },
    "routes": [
      {
        "deliveryId": "uuid",
        "customerName": "Ramesh Kumar",
        "customerPhone": "+919876543210",
        "address": "123 MG Road, Bangalore",
        "latitude": 12.9716,
        "longitude": 77.5946,
        "status": "pending",
        "items": [
          {
            "productName": "Full Cream Milk",
            "quantity": 2,
            "unit": "L",
            "price": 60
          }
        ],
        "totalAmount": 120,
        "notes": null
      }
    ],
    "totalDeliveries": 15
  }
}
```

**Use Case:** 
- Display all pending/in-progress deliveries on a map
- Navigate to each customer location
- View delivery details before starting route

---

### 2. **POST /api/delivery-boy/generate-invoice**
Generate daily invoice for all completed deliveries.

**Request Body:**
```json
{
  "date": "2025-11-02"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Invoice generated successfully",
  "data": {
    "invoiceId": "uuid",
    "invoiceNumber": "INV-DB-20251102-A1B2C3D4",
    "totalDeliveries": 15,
    "totalAmount": 1800.00,
    "generatedAt": "2025-11-02T20:18:00.000Z"
  }
}
```

**Use Case:**
- Generate end-of-day invoice
- Calculate total earnings
- Track completed deliveries

---

### 3. **GET /api/delivery-boy/history**
View paginated delivery history with grouping by date.

**Query Parameters:**
- `page` (optional): Page number, default 1
- `limit` (optional): Items per page, default 30, max 100
- `startDate` (optional): Filter from date (ISO format)
- `endDate` (optional): Filter to date (ISO format)

**Response:**
```json
{
  "success": true,
  "data": {
    "deliveryBoyId": "uuid",
    "history": [
      {
        "date": "2025-11-01",
        "deliveries": [
          {
            "deliveryId": "uuid",
            "customerName": "Ramesh Kumar",
            "customerPhone": "+919876543210",
            "address": "123 MG Road, Bangalore",
            "status": "delivered",
            "amount": 120,
            "deliveredAt": "2025-11-01T08:30:00.000Z",
            "items": [
              {
                "productName": "Full Cream Milk",
                "quantity": 2,
                "unit": "L",
                "price": 60
              }
            ]
          }
        ],
        "totalAmount": 1500,
        "completedCount": 12,
        "pendingCount": 0
      }
    ],
    "pagination": {
      "total": 120,
      "page": 1,
      "limit": 30,
      "totalPages": 4
    }
  }
}
```

**Use Case:**
- View past deliveries
- Check delivery status
- Verify completed tasks

---

### 4. **GET /api/delivery-boy/stats**
Get performance statistics and analytics.

**Query Parameters:**
- `period` (optional): One of: 'all', 'today', 'week', 'month'. Default: 'all'

**Response:**
```json
{
  "success": true,
  "data": {
    "deliveryBoyId": "uuid",
    "period": "all",
    "totalDeliveries": 120,
    "completedDeliveries": 110,
    "pendingDeliveries": 10,
    "totalEarnings": 14500.00,
    "averageDeliveryTime": "22 mins",
    "today": {
      "total": 15,
      "completed": 12,
      "pending": 3
    },
    "completionRate": 91.67
  }
}
```

**Use Case:**
- Dashboard analytics
- Performance tracking
- Quick overview of work status

---

### 5. **PATCH /api/delivery-boy/delivery/:id/status**
Update delivery status (mark as delivered, in-progress, or failed).

**URL Parameters:**
- `id`: UUID of the delivery

**Request Body:**
```json
{
  "status": "delivered",
  "notes": "Delivered successfully",
  "latitude": 12.9716,
  "longitude": 77.5946
}
```

**Valid Status Values:**
- `pending`
- `in-progress`
- `delivered`
- `failed`

**Response:**
```json
{
  "success": true,
  "message": "Delivery status updated successfully",
  "data": {
    "deliveryId": "uuid",
    "status": "delivered",
    "deliveredAt": "2025-11-02T08:45:00.000Z"
  }
}
```

**Use Case:**
- Mark delivery as complete
- Update delivery progress
- Record delivery timestamp and location

---

### 6. **GET /api/delivery-boy/profile**
Get delivery boy profile information.

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Ravi Kumar",
    "phone": "+919876543210",
    "email": "ravi@example.com",
    "role": "delivery_boy",
    "address": "456 Service Road, Bangalore",
    "latitude": 12.9716,
    "longitude": 77.5946,
    "isActive": true,
    "assignedAreas": [
      {
        "id": "uuid",
        "name": "Koramangala",
        "pincode": "560034"
      }
    ],
    "createdAt": "2025-01-15T10:00:00.000Z",
    "updatedAt": "2025-11-02T08:00:00.000Z"
  }
}
```

**Use Case:**
- View profile details
- Check assigned areas
- Update profile information

---

### 7. **PUT /api/delivery-boy/location**
Update current location for real-time tracking.

**Request Body:**
```json
{
  "latitude": 12.9716,
  "longitude": 77.5946
}
```

**Response:**
```json
{
  "success": true,
  "message": "Location updated successfully",
  "data": {
    "latitude": 12.9716,
    "longitude": 77.5946
  }
}
```

**Use Case:**
- Real-time location tracking
- Route optimization
- Customer notifications

---

## 🗄️ Database Schema

### Tables Used

1. **Deliveries**
   - Stores individual delivery records
   - Links customer, delivery boy, and subscription
   - Tracks status and completion

2. **DeliveryItems**
   - Multi-product support
   - Links products to deliveries
   - Stores quantity and price per item

3. **Invoices**
   - Stores delivery boy invoices
   - Type: 'delivery_boy_daily'
   - Includes metadata with delivery details

4. **Users**
   - Delivery boy profiles (role: 'delivery_boy')
   - Location tracking (latitude, longitude)
   - Authentication and authorization

---

## 🚀 Deployment Steps

### 1. Run Database Migration
```bash
psql -U your_username -d ksheer_mitra -f backend/migrations/update-invoice-delivery-enums.sql
```

### 2. Restart Backend Server
```bash
cd backend
npm install
npm start
```

### 3. Verify Endpoints
Check health endpoint:
```bash
curl http://localhost:3000/health
```

---

## 🧪 Testing Guide

### Prerequisites
1. PostgreSQL database running
2. Backend server started
3. Valid JWT token for a delivery boy user

### Test Sequence

#### Step 1: Get Delivery Map
```bash
curl -X GET "http://localhost:3000/api/delivery-boy/delivery-map?date=2025-11-02" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

#### Step 2: Update Delivery Status
```bash
curl -X PATCH "http://localhost:3000/api/delivery-boy/delivery/DELIVERY_ID/status" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "delivered",
    "notes": "Delivered successfully"
  }'
```

#### Step 3: Generate Invoice
```bash
curl -X POST "http://localhost:3000/api/delivery-boy/generate-invoice" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "date": "2025-11-02"
  }'
```

#### Step 4: View History
```bash
curl -X GET "http://localhost:3000/api/delivery-boy/history?page=1&limit=10" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

#### Step 5: Get Stats
```bash
curl -X GET "http://localhost:3000/api/delivery-boy/stats?period=today" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## 🔧 Integration with Frontend (Flutter)

### Setup HTTP Client

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeliveryBoyService {
  final String baseUrl = 'http://YOUR_SERVER_URL/api/delivery-boy';
  final String token;

  DeliveryBoyService(this.token);

  Future<Map<String, dynamic>> getDeliveryMap({String? date}) async {
    final url = date != null 
      ? '$baseUrl/delivery-map?date=$date'
      : '$baseUrl/delivery-map';
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load delivery map');
    }
  }

  Future<Map<String, dynamic>> updateDeliveryStatus(
    String deliveryId,
    String status, {
    String? notes,
    double? latitude,
    double? longitude,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/delivery/$deliveryId/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'status': status,
        if (notes != null) 'notes': notes,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update delivery status');
    }
  }

  Future<Map<String, dynamic>> generateInvoice(String date) async {
    final response = await http.post(
      Uri.parse('$baseUrl/generate-invoice'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'date': date}),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to generate invoice');
    }
  }
}
```

---

## 📱 Frontend Features to Implement

### 1. Route Map Screen
- Display all deliveries on Google Maps
- Show markers for each customer location
- Calculate optimized route
- Navigation to each stop

### 2. Delivery Details Screen
- Customer information
- Product list with quantities
- Delivery instructions
- Mark as delivered button
- Add notes/photos

### 3. Invoice Screen
- Generate daily invoice
- View invoice summary
- Total deliveries and earnings
- Download/share PDF

### 4. History Screen
- Paginated list of past deliveries
- Filter by date range
- Search by customer name
- View delivery details

### 5. Dashboard/Stats Screen
- Today's deliveries count
- Completed vs pending
- Total earnings
- Average delivery time
- Performance metrics

---

## 🐛 Troubleshooting

### Issue: 404 Not Found
**Solution:** Ensure backend server is running and routes are properly mounted.

### Issue: 401 Unauthorized
**Solution:** Check JWT token is valid and not expired. Verify role is 'delivery_boy'.

### Issue: No deliveries returned
**Solution:** Check if deliveries are assigned to the delivery boy in the database.

### Issue: Invoice already exists
**Solution:** This is expected behavior. The system prevents duplicate invoices for the same date.

---

## 📊 Performance Optimization

1. **Pagination**: All list endpoints support pagination to reduce payload size
2. **Indexes**: Database indexes on frequently queried fields
3. **Caching**: Consider implementing Redis for frequently accessed data
4. **Real-time Updates**: Use WebSockets for live delivery status updates

---

## 🔒 Security Considerations

1. **Authentication**: All endpoints require valid JWT token
2. **Authorization**: Only delivery boys can access their own data
3. **Input Validation**: All inputs are validated using express-validator
4. **SQL Injection Prevention**: Using Sequelize ORM with parameterized queries
5. **Rate Limiting**: Applied to all API routes

---

## 📞 Support

For issues or questions:
- Check logs in `backend/logs/error.log`
- Review this documentation
- Contact backend team

---

## 🎉 Ready to Use!

All endpoints are now live and ready for testing. Use the Postman collection provided for easy testing and integration.

**Base URL:** `http://localhost:3000/api/delivery-boy`

**Deployed URL:** Replace with your production URL when deployed.

