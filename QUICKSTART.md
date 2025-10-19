# Quick Start Guide - Ksheermitra

Get the Ksheermitra system up and running in 5 minutes!

## Prerequisites

- PostgreSQL installed and running
- Node.js 16+ installed
- WhatsApp account (for authentication)
- Google Maps API key (optional, for route optimization)

## Step 1: Database Setup

Create the database:
```bash
# On Linux/Mac
sudo -u postgres createdb ksheermitra

# On Windows (in psql)
CREATE DATABASE ksheermitra;
```

## Step 2: Backend Setup

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Create environment file
cp .env .env

# Edit .env file with your database credentials
# At minimum, update these:
# - DB_PASSWORD
# - JWT_SECRET (use a long random string)
# - JWT_REFRESH_SECRET (use another long random string)
nano .env  # or use your favorite editor
```

## Step 3: Initialize Database

```bash
# Run the seed script to create initial data
npm run seed
```

This will create:
- An admin user (phone: +919876543210)
- Sample products (various milk types)
- Sample delivery areas

## Step 4: Start Backend Server

```bash
# Development mode with auto-reload
npm run dev

# OR Production mode
npm start
```

The server will start on http://localhost:3000

## Step 5: WhatsApp Setup

1. Watch the server console output
2. A QR code will be displayed
3. Open WhatsApp on your phone
4. Go to Settings → Linked Devices → Link a Device
5. Scan the QR code
6. Wait for "WhatsApp client is ready!" message

**Note:** This only needs to be done once. The session is saved for future use.

## Step 6: Test the API

### Health Check
```bash
curl http://localhost:3000/health
```

### Send OTP (replace with your phone number)
```bash
curl -X POST http://localhost:3000/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "+919876543210"}'
```

You should receive an OTP on WhatsApp!

### Verify OTP
```bash
curl -X POST http://localhost:3000/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "+919876543210", "otp": "YOUR_OTP_HERE"}'
```

## Step 7: Flutter App Setup (Optional)

```bash
# Navigate to frontend directory
cd ../frontend

# Install Flutter dependencies
flutter pub get

# Update API URL in lib/config/app_config.dart if needed
# Default is http://localhost:3000/api

# Run the app
flutter run
```

## Default Login Credentials

Since the system uses WhatsApp OTP, there are no passwords. Use these phones:

- **Admin**: +919876543210 (created by seed script)
- **Customer**: Any new phone number will be registered as a customer
- **Delivery Boy**: Create via admin panel after logging in

## What You Can Do Now

### As Admin (+919876543210)
1. Login with OTP
2. Add products
3. Create delivery areas
4. Add delivery boys
5. Assign customers to areas
6. View customer map
7. Check daily invoices

### As Customer (any new number)
1. Login with OTP
2. Update profile with name and address
3. Create subscriptions
4. View delivery history
5. Check monthly invoices

### As Delivery Boy (created by admin)
1. Login with OTP
2. View assigned customers
3. See optimized route
4. Mark deliveries as completed/missed
5. Generate daily invoice

## Testing the Full Workflow

### 1. Create a Test Customer
- Login with a new phone number
- Profile will be created automatically
- Update name and address

### 2. Create a Subscription
- Choose a product (e.g., Full Cream Milk)
- Set quantity (e.g., 1 liter)
- Choose frequency (daily, weekly, etc.)
- Set start date

### 3. Assign to Delivery Area
- Login as admin
- Assign customer to an area
- Assign delivery boy to that area

### 4. Deliveries
- Login as delivery boy
- View today's deliveries
- Mark as delivered
- Customer receives WhatsApp notification

### 5. Generate Invoice
- At end of day, delivery boy generates invoice
- Admin receives invoice on WhatsApp
- Monthly invoices auto-generate on 1st of month

## Troubleshooting

### Server won't start
- Check PostgreSQL is running: `sudo systemctl status postgresql`
- Verify database exists: `psql -l | grep ksheermitra`
- Check .env file has correct database credentials

### WhatsApp QR code not appearing
- Check logs for errors
- Ensure puppeteer dependencies are installed
- On Linux, may need: `sudo apt install -y gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget`

### OTP not received
- Check WhatsApp is connected (look for "WhatsApp client is ready!" in logs)
- Verify phone number format (+country code + number)
- Check server logs for errors

### Database errors
- Run migrations: `npm run migrate`
- Re-run seed: `npm run seed`
- Check PostgreSQL logs

## Next Steps

1. **Configure Google Maps** - Add your API key to .env for route optimization
2. **Customize Products** - Add your actual milk products and prices
3. **Setup Areas** - Create delivery areas matching your geography
4. **Add Delivery Boys** - Create accounts for your delivery personnel
5. **Production Deploy** - See DEPLOYMENT.md for production setup

## Support

For detailed information:
- API Documentation: See `backend/README.md`
- Deployment Guide: See `DEPLOYMENT.md`
- Full README: See `README.md`

## Common Commands

```bash
# Backend
npm run dev          # Start development server
npm run seed         # Seed database with initial data
npm start            # Start production server
pm2 logs             # View logs (if using PM2)

# Frontend
flutter run          # Run app
flutter build apk    # Build Android APK
flutter doctor       # Check Flutter setup
```

---

**You're all set!** Start exploring the Ksheermitra system. 🎉
