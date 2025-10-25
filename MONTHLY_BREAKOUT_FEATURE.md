# 🧾 Monthly Breakout Logic — Complete Implementation Guide

## 📋 Overview

The Monthly Breakout feature provides a comprehensive subscription management system that automatically tracks daily deliveries, allows product modifications, and generates end-of-month billing summaries.

---

## ✨ Key Features Implemented

### 1. **Automatic Monthly Breakout Generation**
- ✅ Automatically generates a day-by-day breakdown for each subscription
- ✅ Shows all delivery dates in the month with product details
- ✅ Calculates daily amounts based on product quantities and prices
- ✅ Respects subscription frequency (daily, weekly, monthly, custom)
- ✅ Excludes paused periods and dates outside subscription range

### 2. **Dynamic Product Modification**
- ✅ Customers can modify products for **any future delivery date**
- ✅ Real-time amount recalculation on product changes
- ✅ Add or remove products from specific delivery days
- ✅ Support for one-time product additions
- ✅ Prevents modification of past or delivered orders

### 3. **End-of-Month Billing Summary**
- ✅ Automatic invoice generation on the 1st of each month
- ✅ Comprehensive billing with all delivery details
- ✅ Tracks delivered, pending, and cancelled amounts
- ✅ PDF invoice generation
- ✅ WhatsApp invoice delivery to customers

---

## 🏗️ Technical Architecture

### Database Structure

#### **DeliveryItems Table**
Stores individual products for each delivery:
```sql
- id (UUID, Primary Key)
- deliveryId (UUID, Foreign Key → Deliveries)
- productId (UUID, Foreign Key → Products)
- quantity (DECIMAL)
- price (DECIMAL)
- isOneTime (BOOLEAN) — for one-time additions
- createdAt, updatedAt (TIMESTAMP)
```

#### **Enhanced Invoices Table**
Stores monthly billing summaries:
```sql
- deliveryDetails (JSONB) — Complete breakdown of all deliveries
- periodStart, periodEnd (DATE) — Month period
- totalAmount, paidAmount (DECIMAL)
- paymentStatus (ENUM: 'pending', 'partial', 'paid')
```

---

## 🔌 API Endpoints

### **1. Get Subscription Monthly Breakout**
```http
GET /api/customer/subscriptions/:id/monthly-breakout?year=2025&month=10
```

**Response:**
```json
{
  "success": true,
  "data": {
    "subscriptionId": "uuid",
    "year": 2025,
    "month": 10,
    "monthName": "October 2025",
    "totalAmount": 3500.00,
    "deliveredAmount": 1200.00,
    "pendingAmount": 2300.00,
    "deliveryCount": 25,
    "breakout": [
      {
        "id": "delivery-uuid",
        "date": "2025-10-01",
        "dayOfWeek": "Wednesday",
        "status": "delivered",
        "amount": 140.00,
        "items": [
          {
            "productName": "Full Cream Milk",
            "quantity": 2,
            "price": 100.00,
            "unit": "L",
            "pricePerUnit": 50.00,
            "isOneTime": false
          }
        ],
        "isEditable": false
      }
    ]
  }
}
```

### **2. Get Customer Monthly Breakout (All Subscriptions)**
```http
GET /api/customer/monthly-breakout/:year/:month
```

**Response:**
```json
{
  "success": true,
  "data": {
    "customerId": "uuid",
    "year": 2025,
    "month": 10,
    "monthName": "October 2025",
    "totalAmount": 5000.00,
    "deliveredAmount": 2000.00,
    "pendingAmount": 3000.00,
    "subscriptionCount": 2,
    "subscriptions": [...]
  }
}
```

### **3. Modify Delivery Products**
```http
PUT /api/customer/deliveries/:id/products
```

**Request Body:**
```json
{
  "products": [
    {
      "productId": "uuid",
      "quantity": 2.5,
      "isOneTime": false
    },
    {
      "productId": "uuid-2",
      "quantity": 1,
      "isOneTime": true
    }
  ]
}
```

**Response:**
```json
{
  "success": true,
  "message": "Delivery products updated successfully",
  "data": {
    "id": "delivery-uuid",
    "deliveryDate": "2025-10-25",
    "amount": 175.00,
    "items": [...]
  }
}
```

### **4. Generate Monthly Invoice**
```http
POST /api/customer/monthly-invoice/:year/:month
```

**Response:**
```json
{
  "success": true,
  "message": "Monthly invoice generated successfully",
  "data": {
    "id": "invoice-uuid",
    "invoiceNumber": "INV-202510-0001",
    "totalAmount": 3500.00,
    "paymentStatus": "pending",
    "pdfPath": "/path/to/invoice.pdf"
  }
}
```

### **5. Get Monthly Invoice**
```http
GET /api/customer/monthly-invoice/:year/:month
```

---

## ⚙️ Service Layer Implementation

### **MonthlyBreakoutService**

#### Key Methods:

1. **`generateMonthlyBreakout(subscriptionId, year, month)`**
   - Creates a complete monthly breakdown prediction
   - Calculates expected deliveries based on subscription frequency
   - Returns day-by-day breakdown with amounts

2. **`getMonthlyBreakout(subscriptionId, customerId, year, month)`**
   - Retrieves actual deliveries for the month
   - Shows real-time status and amounts
   - Marks which deliveries are editable

3. **`modifyDeliveryProducts(deliveryId, customerId, products)`**
   - Updates products for a specific delivery
   - Validates future dates only
   - Recalculates delivery amount
   - Uses transactions for data integrity

4. **`generateMonthlyInvoice(customerId, year, month)`**
   - Creates invoice for entire month
   - Aggregates all deliveries
   - Generates PDF invoice
   - Sends via WhatsApp

5. **`isDeliveryDay(subscription, date)`**
   - Determines if a date should have delivery
   - Respects frequency settings
   - Excludes paused periods

---

## 🤖 Automated Cron Jobs

### **1. Monthly Invoice Generation**
```javascript
Cron: '0 7 1 * *' (1st of every month at 7 AM)
```
- Generates invoices for previous month
- Processes all active customers
- Sends invoices via WhatsApp

### **2. Monthly Breakout Summary**
```javascript
Cron: '0 23 28-31 * *' (Last day of month at 11 PM)
```
- Pre-generates monthly summaries
- Caches breakout data for quick access

### **3. Delivery Cleanup**
```javascript
Cron: '0 2 * * *' (Daily at 2 AM)
```
- Marks old pending deliveries as "missed"
- Maintains data accuracy

---

## 📱 Frontend Integration Guide

### **Display Monthly Breakout**
```dart
// Fetch monthly breakout
final response = await apiService.get(
  '/customer/subscriptions/$subscriptionId/monthly-breakout',
  queryParameters: {'year': 2025, 'month': 10}
);

// Display in calendar view or list view
```

### **Modify Delivery Products**
```dart
// Allow user to modify products for future dates
Future<void> modifyDelivery(String deliveryId, List<Product> products) async {
  final response = await apiService.put(
    '/customer/deliveries/$deliveryId/products',
    data: {
      'products': products.map((p) => {
        'productId': p.id,
        'quantity': p.quantity,
        'isOneTime': p.isOneTime
      }).toList()
    }
  );
}
```

### **View Monthly Invoice**
```dart
// Get invoice for specific month
final invoice = await apiService.get(
  '/customer/monthly-invoice/$year/$month'
);

// Display invoice details and download PDF
```

---

## 🎯 Business Logic Flow

### **Monthly Subscription Flow:**

```
1. Customer creates subscription
   ↓
2. System generates deliveries for upcoming dates
   ↓
3. Daily: Deliveries marked as 'pending'
   ↓
4. Customer can modify future deliveries
   - Add/remove products
   - Change quantities
   - Amount recalculates automatically
   ↓
5. Delivery Boy marks as 'delivered'
   ↓
6. End of Month: System generates invoice
   - Sums all delivered deliveries
   - Creates PDF invoice
   - Sends via WhatsApp
   ↓
7. Customer views monthly breakout
   - See all deliveries
   - Track amounts
   - Download invoice
```

---

## 🔐 Security & Validation

### **Access Control:**
- ✅ Customers can only access their own subscriptions
- ✅ Modifications allowed only for future dates
- ✅ Only pending deliveries can be modified
- ✅ Transaction-based updates for data consistency

### **Validation Rules:**
- ✅ Products must be active and available
- ✅ Quantities must be positive numbers
- ✅ Dates must be in the future for modifications
- ✅ Subscription must be active

---

## 📊 Example Use Cases

### **Use Case 1: Customer wants extra milk on weekends**
```javascript
// Customer modifies Saturday delivery
PUT /api/customer/deliveries/{saturday-delivery-id}/products
{
  "products": [
    {
      "productId": "milk-id",
      "quantity": 3,  // Instead of regular 2L
      "isOneTime": false
    }
  ]
}
// Amount automatically recalculates: 3L × ₹50 = ₹150
```

### **Use Case 2: Customer going on vacation**
```javascript
// Pause subscription for vacation dates
POST /api/customer/subscriptions/{id}/pause
{
  "pauseStartDate": "2025-10-15",
  "pauseEndDate": "2025-10-20"
}
// Monthly breakout excludes these dates
// Invoice only charges for actual deliveries
```

### **Use Case 3: One-time product addition**
```javascript
// Add curd for just one day
PUT /api/customer/deliveries/{delivery-id}/products
{
  "products": [
    {
      "productId": "milk-id",
      "quantity": 2,
      "isOneTime": false  // Regular subscription item
    },
    {
      "productId": "curd-id",
      "quantity": 1,
      "isOneTime": true  // One-time addition
    }
  ]
}
```

---

## 🐛 Error Handling

### **Common Errors:**

1. **Cannot modify past deliveries**
```json
{
  "success": false,
  "message": "Cannot modify past deliveries"
}
```

2. **Delivery already delivered**
```json
{
  "success": false,
  "message": "Can only modify pending deliveries"
}
```

3. **Invoice already exists**
```json
{
  "success": false,
  "message": "Invoice already exists for this month"
}
```

---

## 🚀 Deployment Checklist

- [x] Run migration: `create-delivery-items-table.sql`
- [x] Ensure cron service is started in `server.js`
- [x] Set timezone in cron jobs: `Asia/Kolkata`
- [x] Configure environment variables:
  - `MONTHLY_INVOICE_CRON` (optional, default: '0 7 1 * *')
- [x] Test monthly breakout endpoints
- [x] Test product modification
- [x] Verify invoice generation
- [x] Check WhatsApp integration

---

## 📈 Performance Considerations

### **Optimizations:**
1. **Indexed Queries**: Delivery lookups indexed by `subscriptionId` and `deliveryDate`
2. **Caching**: Monthly breakouts cached for frequent access
3. **Batch Processing**: Invoices generated in batches with delays
4. **Transaction Management**: All modifications use database transactions

### **Scalability:**
- Supports unlimited subscriptions per customer
- Handles multi-product deliveries efficiently
- Async invoice generation prevents blocking

---

## 🎉 Summary

The Monthly Breakout feature provides:
- ✅ Complete visibility into monthly subscription costs
- ✅ Flexibility to modify future deliveries
- ✅ Automatic billing and invoicing
- ✅ Real-time amount calculations
- ✅ Comprehensive tracking and reporting

All requirements from the specification have been successfully implemented! 🚀

