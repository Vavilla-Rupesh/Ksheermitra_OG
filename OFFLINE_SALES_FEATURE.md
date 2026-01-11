# In-Store (Offline) Sales Feature - Complete Guide

## Overview
The In-Store (Offline) Sales feature allows administrators to record direct sales to walk-in customers at the shop. This feature automatically:
- Validates and reduces product stock
- Creates a sale record
- Updates the daily admin invoice
- Handles transactions atomically (all-or-nothing)

---

## Features
✅ **Admin-only access** - Only authenticated admin users can create offline sales  
✅ **Multi-product sales** - Sell multiple products in a single transaction  
✅ **Automatic stock management** - Stock is reduced immediately upon sale  
✅ **Daily invoice integration** - Sales are added to the current day's admin invoice  
✅ **Optional customer details** - Record walk-in customer name and phone (optional)  
✅ **Payment method tracking** - Support for cash, card, UPI, and other payment methods  
✅ **Atomic transactions** - Stock and invoice updates happen together or not at all  
✅ **Comprehensive validation** - Stock availability, product status, and quantity checks  

---

## Database Schema

### OfflineSales Table
```sql
CREATE TABLE "OfflineSales" (
  id UUID PRIMARY KEY,
  saleNumber VARCHAR(50) UNIQUE NOT NULL,
  saleDate DATE NOT NULL,
  adminId UUID NOT NULL REFERENCES Users(id),
  totalAmount DECIMAL(10,2) NOT NULL,
  items JSONB NOT NULL,
  customerName VARCHAR(100),
  customerPhone VARCHAR(15),
  paymentMethod ENUM('cash', 'card', 'upi', 'other') DEFAULT 'cash',
  notes TEXT,
  invoiceId UUID REFERENCES Invoices(id),
  createdAt TIMESTAMP NOT NULL,
  updatedAt TIMESTAMP NOT NULL,
  deletedAt TIMESTAMP
);
```

### Invoice Type Update
The `Invoices.invoiceType` enum now includes:
- `'daily'` - Customer daily invoices
- `'monthly'` - Customer monthly invoices
- `'delivery_boy_daily'` - Delivery boy daily invoices
- **`'admin_daily'`** - Admin offline sales daily invoices (NEW)

---

## API Endpoints

### 1. Create Offline Sale
**POST** `/api/admin/offline-sales`

**Authentication Required:** Yes (Admin only)

**Request Body:**
```json
{
  "items": [
    {
      "productId": "uuid-of-product",
      "quantity": 5
    },
    {
      "productId": "uuid-of-another-product",
      "quantity": 2
    }
  ],
  "customerName": "John Doe",
  "customerPhone": "+919876543210",
  "paymentMethod": "cash",
  "notes": "Walk-in customer, paid in full"
}
```

**Validation Rules:**
- `items` - Required, array with at least 1 item
- `items[].productId` - Required, valid UUID
- `items[].quantity` - Required, integer >= 1
- `customerName` - Optional, 2-100 characters
- `customerPhone` - Optional, valid phone format (+country_code + number)
- `paymentMethod` - Optional, one of: 'cash', 'card', 'upi', 'other'
- `notes` - Optional, string

**Success Response (201):**
```json
{
  "success": true,
  "message": "Offline sale created successfully",
  "data": {
    "id": "sale-uuid",
    "saleNumber": "SALE-20260104-143022-a1b2c3",
    "saleDate": "2026-01-04",
    "adminId": "admin-uuid",
    "totalAmount": "235.00",
    "items": [
      {
        "productId": "product-uuid-1",
        "productName": "Milk",
        "quantity": 5,
        "unit": "liter",
        "pricePerUnit": 45.00,
        "amount": 225.00
      },
      {
        "productId": "product-uuid-2",
        "productName": "Curd",
        "quantity": 2,
        "unit": "kg",
        "pricePerUnit": 5.00,
        "amount": 10.00
      }
    ],
    "customerName": "John Doe",
    "customerPhone": "+919876543210",
    "paymentMethod": "cash",
    "notes": "Walk-in customer, paid in full",
    "invoiceId": "invoice-uuid",
    "admin": {
      "id": "admin-uuid",
      "name": "Admin Name",
      "phone": "+919123456789"
    },
    "invoice": {
      "id": "invoice-uuid",
      "invoiceNumber": "INV-ADMIN-20260104",
      "totalAmount": "235.00"
    },
    "createdAt": "2026-01-04T14:30:22.000Z",
    "updatedAt": "2026-01-04T14:30:22.000Z"
  }
}
```

**Error Responses:**

*400 - Insufficient Stock:*
```json
{
  "success": false,
  "message": "Insufficient stock for Milk. Available: 3, Requested: 5"
}
```

*400 - Invalid Product:*
```json
{
  "success": false,
  "message": "Product is not active: Butter"
}
```

*401 - Unauthorized:*
```json
{
  "success": false,
  "message": "Authentication required"
}
```

*403 - Forbidden:*
```json
{
  "success": false,
  "message": "Admin access required"
}
```

---

### 2. Get Offline Sales
**GET** `/api/admin/offline-sales`

**Authentication Required:** Yes (Admin only)

**Query Parameters:**
- `startDate` - Optional, filter by start date (YYYY-MM-DD)
- `endDate` - Optional, filter by end date (YYYY-MM-DD)
- `page` - Optional, page number (default: 1)
- `limit` - Optional, items per page (default: 50)

**Example Request:**
```
GET /api/admin/offline-sales?startDate=2026-01-01&endDate=2026-01-31&page=1&limit=20
```

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "sales": [
      {
        "id": "sale-uuid",
        "saleNumber": "SALE-20260104-143022-a1b2c3",
        "saleDate": "2026-01-04",
        "totalAmount": "235.00",
        "items": [...],
        "customerName": "John Doe",
        "paymentMethod": "cash",
        "admin": {
          "id": "admin-uuid",
          "name": "Admin Name",
          "phone": "+919123456789"
        },
        "invoice": {
          "id": "invoice-uuid",
          "invoiceNumber": "INV-ADMIN-20260104",
          "totalAmount": "1500.00",
          "status": "pending"
        },
        "createdAt": "2026-01-04T14:30:22.000Z"
      }
    ],
    "pagination": {
      "total": 45,
      "page": 1,
      "limit": 20,
      "totalPages": 3
    }
  }
}
```

---

### 3. Get Offline Sale by ID
**GET** `/api/admin/offline-sales/:id`

**Authentication Required:** Yes (Admin only)

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "sale-uuid",
    "saleNumber": "SALE-20260104-143022-a1b2c3",
    "saleDate": "2026-01-04",
    "totalAmount": "235.00",
    "items": [...],
    "customerName": "John Doe",
    "customerPhone": "+919876543210",
    "paymentMethod": "cash",
    "notes": "Walk-in customer",
    "admin": {
      "id": "admin-uuid",
      "name": "Admin Name",
      "phone": "+919123456789",
      "email": "admin@example.com"
    },
    "invoice": {
      "id": "invoice-uuid",
      "invoiceNumber": "INV-ADMIN-20260104",
      "totalAmount": "1500.00",
      "status": "pending",
      "invoiceDate": "2026-01-04"
    },
    "createdAt": "2026-01-04T14:30:22.000Z",
    "updatedAt": "2026-01-04T14:30:22.000Z"
  }
}
```

**Error Response (404):**
```json
{
  "success": false,
  "message": "Offline sale not found"
}
```

---

### 4. Get Offline Sales Statistics
**GET** `/api/admin/offline-sales/stats`

**Authentication Required:** Yes (Admin only)

**Query Parameters:**
- `startDate` - Optional, filter by start date (YYYY-MM-DD)
- `endDate` - Optional, filter by end date (YYYY-MM-DD)

**Example Request:**
```
GET /api/admin/offline-sales/stats?startDate=2026-01-01&endDate=2026-01-31
```

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "totalSales": 45,
    "totalRevenue": "12500.50",
    "averageSaleAmount": "277.79"
  }
}
```

---

### 5. Get Admin Daily Invoice
**GET** `/api/admin/invoices/admin-daily`

**Authentication Required:** Yes (Admin only)

**Query Parameters:**
- `date` - Required, date in YYYY-MM-DD format

**Example Request:**
```
GET /api/admin/invoices/admin-daily?date=2026-01-04
```

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "invoice-uuid",
    "invoiceNumber": "INV-ADMIN-20260104",
    "invoiceType": "admin_daily",
    "invoiceDate": "2026-01-04",
    "totalAmount": "1500.00",
    "paidAmount": "0.00",
    "status": "pending",
    "metadata": {
      "offlineSales": [
        {
          "saleNumber": "SALE-20260104-143022-a1b2c3",
          "amount": "235.00",
          "items": [...],
          "customerName": "John Doe",
          "timestamp": "2026-01-04 14:30:22"
        }
      ],
      "description": "Daily In-Store Sales Invoice"
    },
    "offlineSales": [
      {
        "id": "sale-uuid",
        "saleNumber": "SALE-20260104-143022-a1b2c3",
        "totalAmount": "235.00",
        "customerName": "John Doe",
        "admin": {
          "id": "admin-uuid",
          "name": "Admin Name",
          "phone": "+919123456789"
        }
      }
    ]
  }
}
```

**Error Response (404):**
```json
{
  "success": false,
  "message": "No invoice found for the specified date"
}
```

---

## Business Logic

### Transaction Flow
1. **Validate Admin** - Ensure the user is an active admin
2. **Validate Items** - Check all products exist and are active
3. **Check Stock** - Verify sufficient stock for each product
4. **Calculate Totals** - Compute item amounts and total sale amount
5. **Reduce Stock** - Decrease product stock quantities
6. **Get/Create Invoice** - Find or create the admin daily invoice for the date
7. **Create Sale Record** - Insert the offline sale record
8. **Update Invoice** - Add sale amount to invoice total and update metadata
9. **Commit Transaction** - Save all changes atomically

### Invoice Management
- **Invoice Number Format:** `INV-ADMIN-YYYYMMDD`
- **Auto-Creation:** If no invoice exists for the day, it's created automatically
- **Accumulation:** All sales for the day are added to the same invoice
- **Metadata Tracking:** Each sale is recorded in the invoice's metadata

### Stock Management
- Stock is reduced **immediately** when a sale is created
- If stock is insufficient, the entire transaction is rolled back
- No partial sales are allowed

---

## Error Handling

### Common Errors
1. **Insufficient Stock**
   - Status: 400
   - Message: "Insufficient stock for {product}. Available: {X}, Requested: {Y}"

2. **Invalid Product**
   - Status: 500
   - Message: "Product not found: {productId}"

3. **Inactive Product**
   - Status: 500
   - Message: "Product is not active: {productName}"

4. **Invalid Admin**
   - Status: 500
   - Message: "Invalid or inactive admin user"

5. **Validation Errors**
   - Status: 400
   - Message: Field-specific validation messages

---

## Database Migration

Run the migration to create the OfflineSales table:

```bash
# If using Sequelize CLI
npx sequelize-cli db:migrate

# Or manually run the migration file
node backend/migrations/20260104_add_offline_sales.js
```

---

## Testing

### Manual API Testing

**1. Create a sale with curl:**
```bash
curl -X POST http://localhost:5000/api/admin/offline-sales \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "items": [
      {"productId": "PRODUCT_UUID_1", "quantity": 2},
      {"productId": "PRODUCT_UUID_2", "quantity": 1}
    ],
    "customerName": "Test Customer",
    "paymentMethod": "cash"
  }'
```

**2. Get sales:**
```bash
curl -X GET "http://localhost:5000/api/admin/offline-sales?startDate=2026-01-01" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

**3. Get statistics:**
```bash
curl -X GET "http://localhost:5000/api/admin/offline-sales/stats" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

---

## Integration with Frontend (Flutter)

### API Service Example
```dart
class OfflineSaleService {
  final ApiService _apiService;
  
  Future<OfflineSale> createOfflineSale({
    required List<SaleItem> items,
    String? customerName,
    String? customerPhone,
    String paymentMethod = 'cash',
    String? notes,
  }) async {
    final response = await _apiService.post(
      '/admin/offline-sales',
      data: {
        'items': items.map((item) => {
          'productId': item.productId,
          'quantity': item.quantity,
        }).toList(),
        'customerName': customerName,
        'customerPhone': customerPhone,
        'paymentMethod': paymentMethod,
        'notes': notes,
      },
    );
    
    return OfflineSale.fromJson(response['data']);
  }
  
  Future<List<OfflineSale>> getOfflineSales({
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _apiService.get(
      '/admin/offline-sales',
      queryParameters: {
        'startDate': startDate,
        'endDate': endDate,
        'page': page,
        'limit': limit,
      },
    );
    
    return (response['data']['sales'] as List)
        .map((json) => OfflineSale.fromJson(json))
        .toList();
  }
}
```

---

## Security Considerations

1. **Admin-Only Access** - All endpoints require admin authentication
2. **Stock Validation** - Prevents overselling
3. **Atomic Transactions** - Ensures data consistency
4. **Input Validation** - Validates all user inputs
5. **SQL Injection Protection** - Uses parameterized queries via Sequelize

---

## Future Enhancements

- [ ] Barcode scanner integration for faster product selection
- [ ] Receipt printing functionality
- [ ] Customer loyalty program integration
- [ ] Return/refund handling
- [ ] Daily sales reports with PDF generation
- [ ] Stock alerts when running low
- [ ] Multi-currency support
- [ ] Discount/promotion support

---

## Support

For issues or questions, refer to:
- Backend logs: `backend/logs/`
- Database migrations: `backend/migrations/`
- Service implementation: `backend/src/services/offlineSale.service.js`
- Controller: `backend/src/controllers/admin.controller.js`

---

**Last Updated:** January 4, 2026  
**Version:** 1.0.0  
**Status:** ✅ Production Ready

