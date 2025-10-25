# Admin Delivery Boy Management Guide

## Overview
The admin can add, view, update, and manage delivery boy details through the API endpoints.

## Available Endpoints

### 1. Get All Delivery Boys
**Endpoint:** `GET /api/admin/delivery-boys`
**Auth Required:** Yes (Admin only)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Delivery Boy Name",
      "phone": "+919876543210",
      "email": "email@example.com",
      "address": "Address",
      "latitude": "12.345678",
      "longitude": "77.123456",
      "role": "delivery_boy",
      "isActive": true,
      "area": {
        "id": "uuid",
        "name": "Area Name"
      }
    }
  ]
}
```

### 2. Create Delivery Boy
**Endpoint:** `POST /api/admin/delivery-boys`
**Auth Required:** Yes (Admin only)

**Request Body:**
```json
{
  "name": "John Doe",
  "phone": "+919876543210",
  "email": "john@example.com",
  "address": "123 Main Street, City",
  "latitude": "12.345678",
  "longitude": "77.123456"
}
```

**Validation Rules:**
- `name`: Required, 2-100 characters
- `phone`: Required, valid phone number format (E.164)
- `email`: Optional, valid email format
- `address`: Optional string
- `latitude`: Optional decimal value
- `longitude`: Optional decimal value

**Response:**
```json
{
  "success": true,
  "message": "Delivery boy created successfully",
  "data": {
    "id": "uuid",
    "name": "John Doe",
    "phone": "+919876543210",
    "email": "john@example.com",
    "address": "123 Main Street, City",
    "latitude": "12.345678",
    "longitude": "77.123456",
    "role": "delivery_boy",
    "isActive": true
  }
}
```

**Error Response (409 - Duplicate):**
```json
{
  "success": false,
  "message": "Phone number already registered"
}
```

### 3. Get Delivery Boy Details
**Endpoint:** `GET /api/admin/delivery-boys/:id`
**Auth Required:** Yes (Admin only)

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "John Doe",
    "phone": "+919876543210",
    "email": "john@example.com",
    "address": "123 Main Street, City",
    "latitude": "12.345678",
    "longitude": "77.123456",
    "role": "delivery_boy",
    "isActive": true,
    "area": {
      "id": "uuid",
      "name": "Area Name",
      "description": "Area description"
    }
  }
}
```

### 4. Update Delivery Boy
**Endpoint:** `PUT /api/admin/delivery-boys/:id`
**Auth Required:** Yes (Admin only)

**Request Body (all fields optional):**
```json
{
  "name": "Updated Name",
  "phone": "+919876543211",
  "email": "updated@example.com",
  "address": "456 New Street, City",
  "latitude": "12.987654",
  "longitude": "77.654321",
  "isActive": false
}
```

**Response:**
```json
{
  "success": true,
  "message": "Delivery boy updated successfully",
  "data": {
    "id": "uuid",
    "name": "Updated Name",
    "phone": "+919876543211",
    "isActive": false
  }
}
```

## Using the API

### Step 1: Login as Admin
```bash
POST /api/auth/login
Content-Type: application/json

{
  "phone": "+919876543210",
  "otp": "123456"
}
```

Save the `token` from the response.

### Step 2: Create Delivery Boy
```bash
POST /api/admin/delivery-boys
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "name": "Ramesh Kumar",
  "phone": "+919123456789",
  "email": "ramesh@example.com",
  "address": "HSR Layout, Bangalore",
  "latitude": "12.9121",
  "longitude": "77.6446"
}
```

### Step 3: Assign Area to Delivery Boy
```bash
POST /api/admin/assign-area-with-map
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "areaId": "area-uuid",
  "deliveryBoyId": "delivery-boy-uuid",
  "boundaries": [
    {"lat": 12.9121, "lng": 77.6446},
    {"lat": 12.9150, "lng": 77.6500}
  ],
  "centerLatitude": "12.9135",
  "centerLongitude": "77.6473"
}
```

## cURL Examples

### Create Delivery Boy
```bash
curl -X POST http://localhost:3000/api/admin/delivery-boys \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Ramesh Kumar",
    "phone": "+919123456789",
    "email": "ramesh@example.com",
    "address": "HSR Layout, Bangalore"
  }'
```

### Get All Delivery Boys
```bash
curl -X GET http://localhost:3000/api/admin/delivery-boys \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Update Delivery Boy
```bash
curl -X PUT http://localhost:3000/api/admin/delivery-boys/DELIVERY_BOY_ID \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Name",
    "isActive": false
  }'
```

## Database Schema

The delivery boy details are stored in the `Users` table with the following structure:

```sql
CREATE TABLE Users (
  id UUID PRIMARY KEY,
  name VARCHAR(100),
  phone VARCHAR(15) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE,
  role ENUM('admin', 'customer', 'delivery_boy') NOT NULL DEFAULT 'customer',
  address TEXT,
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  areaId UUID REFERENCES Areas(id),
  isActive BOOLEAN DEFAULT true,
  passwordHash VARCHAR(255),
  lastLogin TIMESTAMP,
  createdAt TIMESTAMP DEFAULT NOW(),
  updatedAt TIMESTAMP DEFAULT NOW(),
  deletedAt TIMESTAMP
);
```

## Features

1. ✅ Create delivery boy with contact details
2. ✅ Add location coordinates (latitude/longitude)
3. ✅ Update delivery boy information
4. ✅ Activate/Deactivate delivery boys
5. ✅ List all delivery boys
6. ✅ View individual delivery boy details
7. ✅ Assign areas to delivery boys
8. ✅ Phone number validation and uniqueness check
9. ✅ Email validation
10. ✅ Soft delete support

## Error Handling

The API returns appropriate HTTP status codes:
- `200`: Success
- `201`: Created successfully
- `400`: Bad request (validation error)
- `401`: Unauthorized
- `403`: Forbidden (not admin)
- `404`: Not found
- `409`: Conflict (duplicate phone number)
- `500`: Internal server error

## Frontend Integration Notes

When building the Flutter admin panel, you'll need:

1. **Create Delivery Boy Form** with fields:
   - Name (required)
   - Phone (required, with country code picker)
   - Email (optional)
   - Address (optional, with location picker)
   - Latitude/Longitude (auto-filled from map)

2. **Delivery Boys List Screen**:
   - Display all delivery boys in a list/grid
   - Show name, phone, assigned area
   - Active/Inactive status indicator
   - Edit and Delete actions

3. **Edit Delivery Boy Screen**:
   - Pre-fill existing data
   - Allow updates to all fields
   - Toggle active status

4. **Area Assignment Screen**:
   - Google Maps integration
   - Draw boundaries for areas
   - Assign delivery boy to area

## Testing

To test the API, start the backend server:

```bash
cd backend
npm install
npm run dev
```

The server will start on `http://localhost:3000`

Check server health:
```bash
curl http://localhost:3000/health
```

## Next Steps

1. ✅ Backend API is ready
2. 🔄 Create Flutter admin screens for:
   - Delivery boy list
   - Add delivery boy form
   - Edit delivery boy form
   - Area assignment with map
3. 🔄 Integrate Google Maps in Flutter app
4. 🔄 Add search and filter functionality
5. 🔄 Add performance tracking for delivery boys

## Notes

- Phone numbers must be unique across all users (admin, customer, delivery_boy)
- Delivery boys don't need passwords for initial creation
- Location coordinates are optional but recommended for map features
- Soft delete is enabled (deletedAt field) for data recovery
- All dates are stored in UTC

