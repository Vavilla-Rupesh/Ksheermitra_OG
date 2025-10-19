# Deployment Guide - Ksheermitra

This guide will help you deploy the Ksheermitra system in a production environment.

## Prerequisites

- Ubuntu/Debian Linux server (or similar)
- PostgreSQL 12+
- Node.js 16+
- Domain name (optional, for HTTPS)
- WhatsApp account
- Google Maps API key

## Part 1: Server Setup

### 1. Update System
```bash
sudo apt update
sudo apt upgrade -y
```

### 2. Install Node.js
```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
node --version  # Should be v18.x or higher
```

### 3. Install PostgreSQL
```bash
sudo apt install -y postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### 4. Install PM2 (Process Manager)
```bash
sudo npm install -g pm2
```

### 5. Install Nginx (Optional, for reverse proxy)
```bash
sudo apt install -y nginx
```

## Part 2: Database Setup

### 1. Create Database User
```bash
sudo -u postgres psql
```

In PostgreSQL console:
```sql
CREATE DATABASE ksheermitra;
CREATE USER ksheermitra_user WITH ENCRYPTED PASSWORD 'your_secure_password';
GRANT ALL PRIVILEGES ON DATABASE ksheermitra TO ksheermitra_user;
\q
```

### 2. Test Connection
```bash
psql -h localhost -U ksheermitra_user -d ksheermitra
```

## Part 3: Backend Deployment

### 1. Clone Repository
```bash
cd /var/www
git clone https://github.com/Vavilla-Mahesh/Ksheer_Mitra.git
cd Ksheer_Mitra/backend
```

### 2. Install Dependencies
```bash
npm install --production
```

### 3. Configure Environment
```bash
cp .env .env
nano .env
```

Update the following in `.env`:
```env
PORT=3000
NODE_ENV=production

DB_HOST=localhost
DB_PORT=5432
DB_NAME=ksheermitra
DB_USER=ksheermitra_user
DB_PASSWORD=your_secure_password

JWT_SECRET=generate_a_very_secure_random_string_here
JWT_REFRESH_SECRET=another_very_secure_random_string_here

GOOGLE_MAPS_API_KEY=your_google_maps_api_key

COMPANY_NAME=Ksheermitra
COMPANY_ADDRESS=Your Business Address
COMPANY_PHONE=+91-XXXXXXXXXX
COMPANY_EMAIL=support@ksheermitra.com
```

### 4. Run Database Migrations
First, create the Sequelize CLI config:
```bash
npm install --save-dev sequelize-cli
npx sequelize-cli init
```

Then run:
```bash
npx sequelize-cli db:migrate
```

### 5. Start Server with PM2
```bash
pm2 start src/server.js --name ksheermitra-backend
pm2 save
pm2 startup
```

### 6. Setup WhatsApp
```bash
pm2 logs ksheermitra-backend
```
Scan the QR code with your WhatsApp to authenticate.

## Part 4: Nginx Configuration (Optional)

### 1. Create Nginx Config
```bash
sudo nano /etc/nginx/sites-available/ksheermitra
```

Add:
```nginx
server {
    listen 80;
    server_name api.ksheermitra.com;  # Replace with your domain

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

### 2. Enable Site
```bash
sudo ln -s /etc/nginx/sites-available/ksheermitra /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 3. Setup SSL (Optional, using Let's Encrypt)
```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d api.ksheermitra.com
```

## Part 5: Flutter App Deployment

### Android

1. **Setup Flutter**
```bash
# On your development machine
flutter doctor
```

2. **Update API URL**
Edit `frontend/lib/config/app_config.dart`:
```dart
static const String baseUrl = 'https://api.ksheermitra.com/api';
```

3. **Build APK**
```bash
cd frontend
flutter build apk --release
```

4. **Sign APK** (for Google Play)
- Create keystore
- Configure `android/app/build.gradle`
- Build signed APK:
```bash
flutter build apk --release
```

5. **Distribute**
- Upload to Google Play Store, or
- Distribute APK directly

### iOS

1. **Build for iOS**
```bash
flutter build ios --release
```

2. **Sign and Deploy**
- Use Xcode to sign
- Upload to App Store Connect

## Part 6: Create Initial Admin User

Since the system uses OTP authentication, you need to create an admin user manually:

```bash
sudo -u postgres psql -d ksheermitra
```

```sql
INSERT INTO "Users" (
    id, 
    name, 
    phone, 
    role, 
    "isActive", 
    "createdAt", 
    "updatedAt"
) VALUES (
    gen_random_uuid(),
    'Admin User',
    '+919876543210',  -- Replace with actual phone
    'admin',
    true,
    NOW(),
    NOW()
);
```

## Part 7: Monitoring & Maintenance

### PM2 Monitoring
```bash
pm2 status
pm2 logs ksheermitra-backend
pm2 monit
```

### Database Backup
Create a daily backup script:
```bash
#!/bin/bash
BACKUP_DIR="/var/backups/ksheermitra"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR
pg_dump -U ksheermitra_user ksheermitra > $BACKUP_DIR/backup_$DATE.sql

# Keep only last 7 days
find $BACKUP_DIR -type f -mtime +7 -delete
```

Save as `/usr/local/bin/backup-ksheermitra.sh` and add to crontab:
```bash
sudo chmod +x /usr/local/bin/backup-ksheermitra.sh
sudo crontab -e
```

Add:
```
0 2 * * * /usr/local/bin/backup-ksheermitra.sh
```

### Log Rotation
Create `/etc/logrotate.d/ksheermitra`:
```
/var/www/Ksheer_Mitra/backend/logs/*.log {
    daily
    rotate 14
    compress
    delaycompress
    missingok
    notifempty
    create 0640 www-data www-data
}
```

## Part 8: Security Checklist

- [ ] Strong passwords for database
- [ ] Secure JWT secrets (long random strings)
- [ ] Firewall configured (UFW)
- [ ] SSH key authentication only
- [ ] HTTPS enabled with valid SSL
- [ ] Regular security updates
- [ ] Database backups automated
- [ ] Rate limiting configured
- [ ] Environment variables secured
- [ ] Logs monitored regularly

## Part 9: Testing Deployment

### Backend Health Check
```bash
curl http://localhost:3000/health
```

Expected response:
```json
{
  "success": true,
  "message": "Server is running",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "whatsapp": true
}
```

### Test API Endpoints
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

## Troubleshooting

### WhatsApp Not Connecting
- Check logs: `pm2 logs ksheermitra-backend`
- Clear WhatsApp session: `rm -rf whatsapp-session`
- Restart server: `pm2 restart ksheermitra-backend`
- Scan QR code again

### Database Connection Errors
- Check PostgreSQL status: `sudo systemctl status postgresql`
- Verify credentials in `.env`
- Check database exists: `psql -l`

### Server Not Starting
- Check logs: `pm2 logs ksheermitra-backend --err`
- Verify all environment variables are set
- Check port 3000 is not in use: `sudo lsof -i :3000`

## Performance Optimization

### PostgreSQL Tuning
Edit `/etc/postgresql/14/main/postgresql.conf`:
```
shared_buffers = 256MB
effective_cache_size = 1GB
maintenance_work_mem = 64MB
max_connections = 100
```

Restart PostgreSQL:
```bash
sudo systemctl restart postgresql
```

### PM2 Cluster Mode
```bash
pm2 delete ksheermitra-backend
pm2 start src/server.js --name ksheermitra-backend -i max
pm2 save
```

## Scaling

For high traffic, consider:
1. PostgreSQL replication
2. Load balancer (Nginx, HAProxy)
3. Redis for session management
4. CDN for static assets
5. Multiple backend instances

## Support

For issues during deployment:
- Check logs in `/var/www/Ksheer_Mitra/backend/logs/`
- Review PM2 logs: `pm2 logs`
- Check Nginx logs: `/var/log/nginx/`
- Database logs: `/var/log/postgresql/`

## Updates

To update the application:
```bash
cd /var/www/Ksheer_Mitra
git pull origin main
cd backend
npm install --production
pm2 restart ksheermitra-backend
```

---

**Deployment Complete!** Your Ksheermitra system should now be running in production.
