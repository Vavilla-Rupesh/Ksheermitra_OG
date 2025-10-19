# Ksheermitra Backend

Smart Milk Delivery System - Backend API

## Features

- **WhatsApp OTP Authentication** - Passwordless authentication for all users
- **Subscription Management** - Flexible milk delivery subscriptions
- **Delivery Tracking** - Real-time delivery status updates
- **Route Optimization** - Google Maps integration for optimal delivery routes
- **Automated Invoicing** - Daily and monthly invoice generation with WhatsApp delivery
- **Role-based Access** - Admin, Customer, and Delivery Boy roles

## Setup

### Prerequisites

- Node.js (v16 or higher)
- PostgreSQL (v12 or higher)
- Google Maps API Key
- WhatsApp account for WhatsApp Web integration

### Installation

1. Install dependencies:
```bash
npm install
```

2. Create `.env` file:
```bash
cp .env .env
```

3. Update the `.env` file with your configuration:
   - Database credentials
   - JWT secrets
   - Google Maps API key
   - Other settings

4. Create database:
```bash
createdb ksheermitra
```

5. Run migrations:
```bash
npm run migrate
```

6. Start the server:
```bash
# Development mode with auto-reload
npm run dev

# Production mode
npm start
```

## API Endpoints

### Authentication
- `POST /api/auth/send-otp` - Send OTP to phone
- `POST /api/auth/verify-otp` - Verify OTP and login
- `POST /api/auth/refresh-token` - Refresh access token
- `POST /api/auth/logout` - Logout user

### Customer
- `GET /api/customer/profile` - Get customer profile
- `PUT /api/customer/profile` - Update customer profile
- `POST /api/customer/subscriptions` - Create subscription
- `GET /api/customer/subscriptions` - Get all subscriptions
- `PUT /api/customer/subscriptions/:id` - Update subscription
- `POST /api/customer/subscriptions/:id/pause` - Pause subscription
- `POST /api/customer/subscriptions/:id/resume` - Resume subscription
- `GET /api/customer/deliveries` - Get delivery history
- `GET /api/customer/invoices` - Get monthly invoices

### Delivery Boy
- `GET /api/delivery/customers` - Get assigned customers
- `GET /api/delivery/route` - Get optimized delivery route
- `PUT /api/delivery/delivery-status` - Update delivery status
- `GET /api/delivery/stats` - Get delivery statistics
- `POST /api/delivery/generate-invoice` - Generate daily invoice

### Admin
- `GET /api/admin/customers` - List all customers
- `GET /api/admin/customers/map` - Get customers with locations
- `GET /api/admin/delivery-boys` - List delivery boys
- `POST /api/admin/delivery-boys` - Create delivery boy
- `POST /api/admin/assign-area` - Assign customer to area
- `POST /api/admin/bulk-assign-area` - Bulk assign customers
- `GET /api/admin/areas` - List areas
- `POST /api/admin/areas` - Create area
- `PUT /api/admin/areas/:id` - Update area
- `GET /api/admin/invoices/daily` - Get daily invoices
- `GET /api/admin/products` - List products
- `POST /api/admin/products` - Create product
- `PUT /api/admin/products/:id` - Update product

## WhatsApp Setup

On first run, the server will generate a QR code in the console. Scan this QR code with WhatsApp to authenticate the WhatsApp Web session.

## Cron Jobs

- **Monthly Invoices**: Runs on the 1st of every month at 7:00 AM (configurable via `MONTHLY_INVOICE_CRON` env variable)

## Security

- JWT-based authentication
- Role-based access control
- Rate limiting
- Input validation
- SQL injection protection
- XSS protection

## License

ISC
