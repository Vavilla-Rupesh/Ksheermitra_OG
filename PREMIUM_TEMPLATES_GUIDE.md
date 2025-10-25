# Premium WhatsApp & Email Templates - Complete Guide

## 🎨 Professional Templates Inspired by Industry Leaders

This implementation provides **super premium, professional messaging templates** similar to those used by **RedBus, Swiggy, and Amazon** for WhatsApp and Email communications.

---

## 📦 What's Included

### 1. WhatsApp Templates (`whatsapp-templates.js`)
Professional text-based templates with Unicode art and rich formatting:

- ✅ **OTP Verification** - Secure code delivery with security warnings
- 🎉 **Welcome Messages** - Onboarding new customers
- 📦 **Subscription Confirmations** - Detailed order confirmations
- 🚚 **Delivery Notifications** - Real-time delivery updates
- 📄 **Invoice Messages** - Monthly billing with breakdown
- 💳 **Payment Confirmations** - Receipt and transaction details
- ⏸️ **Subscription Management** - Pause/Resume/Modify notifications
- ⏰ **Payment Reminders** - Professional payment due notifications
- 🚚 **Out for Delivery** - Live tracking updates

### 2. Email Templates (`email-templates.js`)
Rich HTML/CSS templates with responsive design:

- Beautiful gradient headers
- Card-based layouts
- Responsive mobile design
- Professional typography (Inter font)
- Action buttons with hover effects
- Product cards with icons
- Payment summaries
- Invoice breakdowns
- Branded footer with social links

### 3. Service Integrations
- **WhatsApp Service** - Updated with new templates
- **Email Service** - Nodemailer integration with HTML templates

---

## 🚀 Quick Start

### Installation

```bash
cd backend
npm install nodemailer
```

### Environment Variables

Add to your `.env` file:

```env
# SMTP Configuration for Email
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
SMTP_FROM="Ksheermitra <noreply@ksheermitra.com>"

# OTP Configuration
OTP_LENGTH=6
OTP_EXPIRY_MINUTES=10
```

---

## 💻 Usage Examples

### WhatsApp Messages

#### 1. Send OTP

```javascript
const whatsappService = require('./services/whatsapp.service');

// Simple OTP
await whatsappService.sendOTP('9876543210', '123456', 10);

// OTP with user name
await whatsappService.sendOTP('9876543210', '123456', 10, 'Rajesh Kumar');
```

**Output Preview:**
```
┏━━━━━━━━━━━━━━━━━━━━━━━┓
┃   🥛 KSHEERMITRA      ┃
┗━━━━━━━━━━━━━━━━━━━━━━━┛

Dear Rajesh Kumar,

🔐 Your Verification Code

╔═══════════════════════╗
║                       ║
║      123456           ║
║                       ║
╚═══════════════════════╝

⏰ Valid for 10 minutes
...
```

#### 2. Welcome New Customer

```javascript
await whatsappService.sendWelcomeMessage(
  '9876543210',
  'Rajesh Kumar'
);
```

#### 3. Subscription Created

```javascript
await whatsappService.sendSubscriptionCreated(
  '9876543210',
  'Rajesh Kumar',
  {
    subscriptionId: 'SUB-001',
    products: [
      { name: 'Full Cream Milk', quantity: 1, unit: 'Litre', price: 60 },
      { name: 'Toned Milk', quantity: 0.5, unit: 'Litre', price: 25 }
    ],
    frequency: 'daily',
    startDate: '15 Nov 2024',
    totalPerDelivery: 85,
    deliveryTime: '6:00 AM - 8:00 AM'
  }
);
```

**Output Preview:**
```
┏━━━━━━━━━━━━━━━━━━━━━━━┓
┃  ✅ SUBSCRIPTION       ┃
┃     CONFIRMED!        ┃
┗━━━━━━━━━━━━━━━━━━━━━━━┛

Dear Rajesh Kumar,

🎊 Great choice! Your subscription
is now active.

━━━━━━━━━━━━━━━━━━━━━━━
📦 SUBSCRIPTION DETAILS
━━━━━━━━━━━━━━━━━━━━━━━

  🥛 Full Cream Milk
     └─ 1 Litre × ₹60 = ₹60.00

  🥛 Toned Milk
     └─ 0.5 Litre × ₹25 = ₹12.50

━━━━━━━━━━━━━━━━━━━━━━━
📋 ORDER SUMMARY
...
```

#### 4. Delivery Confirmation

```javascript
await whatsappService.sendDeliveryConfirmation(
  '9876543210',
  {
    customerName: 'Rajesh Kumar',
    productName: 'Full Cream Milk',
    quantity: 1,
    unit: 'Litre',
    deliveryTime: '7:15 AM',
    deliveryDate: '15 Nov 2024',
    deliveryBoyName: 'Ramesh',
    deliveryBoyPhone: '9876543211',
    amount: 60
  }
);
```

#### 5. Monthly Invoice

```javascript
await whatsappService.sendInvoice(
  '9876543210',
  'Rajesh Kumar',
  {
    invoiceNumber: 'INV-2024-001',
    invoiceDate: '01 Nov 2024',
    periodStart: '01 Oct 2024',
    periodEnd: '31 Oct 2024',
    deliveries: [
      {
        date: '01 Oct',
        productName: 'Full Cream Milk',
        quantity: 1,
        unit: 'Litre',
        amount: 60,
        pricePerUnit: 60
      },
      // ... more deliveries
    ],
    subtotal: 1800,
    tax: 0,
    totalAmount: 1800,
    paidAmount: 0,
    remainingAmount: 1800,
    dueDate: '10 Nov 2024',
    paymentLink: 'https://pay.ksheermitra.com/INV-2024-001'
  }
);
```

#### 6. Payment Confirmation

```javascript
await whatsappService.sendPaymentConfirmation(
  '9876543210',
  {
    customerName: 'Rajesh Kumar',
    amount: 1800,
    paymentMethod: 'UPI - Google Pay',
    transactionId: 'TXN123456789',
    invoiceNumber: 'INV-2024-001',
    date: '08 Nov 2024, 10:30 AM',
    remainingBalance: 0
  }
);
```

#### 7. Payment Reminder

```javascript
await whatsappService.sendPaymentReminder(
  '9876543210',
  {
    customerName: 'Rajesh Kumar',
    invoiceNumber: 'INV-2024-001',
    amount: 1800,
    dueDate: '10 Nov 2024',
    daysOverdue: 2,
    paymentLink: 'https://pay.ksheermitra.com/INV-2024-001'
  }
);
```

#### 8. Out for Delivery

```javascript
await whatsappService.sendOutForDelivery(
  '9876543210',
  {
    customerName: 'Rajesh Kumar',
    productName: 'Full Cream Milk',
    quantity: 1,
    unit: 'Litre',
    estimatedTime: '7:15 AM - 7:30 AM',
    deliveryBoyName: 'Ramesh',
    deliveryBoyPhone: '9876543211',
    trackingLink: 'https://track.ksheermitra.com/delivery/123'
  }
);
```

---

### Email Templates

#### 1. Send OTP Email

```javascript
const emailService = require('./services/email.service');

await emailService.sendOTPEmail(
  'customer@example.com',
  {
    userName: 'Rajesh Kumar',
    otp: '123456',
    expiryMinutes: 10
  }
);
```

#### 2. Send Welcome Email

```javascript
await emailService.sendWelcomeEmail(
  'customer@example.com',
  {
    userName: 'Rajesh Kumar',
    email: 'customer@example.com',
    phone: '9876543210'
  }
);
```

#### 3. Send Subscription Email

```javascript
await emailService.sendSubscriptionEmail(
  'customer@example.com',
  {
    customerName: 'Rajesh Kumar',
    subscriptionId: 'SUB-001',
    products: [
      { name: 'Full Cream Milk', quantity: 1, unit: 'Litre', price: 60 }
    ],
    frequency: 'Daily',
    startDate: '15 Nov 2024',
    totalPerDelivery: 60,
    deliveryTime: '6:00 AM - 8:00 AM'
  }
);
```

#### 4. Send Invoice Email

```javascript
await emailService.sendInvoiceEmail(
  'customer@example.com',
  {
    customerName: 'Rajesh Kumar',
    invoiceNumber: 'INV-2024-001',
    invoiceDate: '01 Nov 2024',
    periodStart: '01 Oct 2024',
    periodEnd: '31 Oct 2024',
    deliveries: [
      {
        date: '01 Oct',
        productName: 'Full Cream Milk',
        quantity: 1,
        unit: 'Litre',
        amount: 60
      }
    ],
    subtotal: 1800,
    tax: 0,
    totalAmount: 1800,
    paidAmount: 0,
    remainingAmount: 1800,
    dueDate: '10 Nov 2024',
    downloadLink: 'https://invoices.ksheermitra.com/INV-2024-001.pdf',
    pdfPath: './invoices/INV-2024-001.pdf' // Optional for attachment
  }
);
```

#### 5. Send Payment Confirmation Email

```javascript
await emailService.sendPaymentConfirmationEmail(
  'customer@example.com',
  {
    customerName: 'Rajesh Kumar',
    amount: 1800,
    paymentMethod: 'UPI - Google Pay',
    transactionId: 'TXN123456789',
    invoiceNumber: 'INV-2024-001',
    date: '08 Nov 2024, 10:30 AM',
    remainingBalance: 0
  }
);
```

#### 6. Send Delivery Confirmation Email

```javascript
await emailService.sendDeliveryConfirmationEmail(
  'customer@example.com',
  {
    customerName: 'Rajesh Kumar',
    productName: 'Full Cream Milk',
    quantity: 1,
    unit: 'Litre',
    deliveryTime: '7:15 AM',
    deliveryDate: '15 Nov 2024',
    deliveryBoyName: 'Ramesh',
    amount: 60,
    imageUrl: 'https://images.ksheermitra.com/delivery/123.jpg' // Optional
  }
);
```

---

## 🎯 Integration Examples

### In Auth Service (OTP)

```javascript
// File: backend/src/services/auth.service.js

async sendOTP(phone, ipAddress) {
  try {
    const otp = this.generateOTP();
    const expiryMinutes = 10;
    
    // ... save to database ...
    
    // Send via WhatsApp
    await whatsappService.sendOTP(phone, otp, expiryMinutes);
    
    // Also send via Email if available
    const user = await db.User.findOne({ where: { phone } });
    if (user && user.email) {
      await emailService.sendOTPEmail(user.email, {
        userName: user.name,
        otp,
        expiryMinutes
      });
    }
    
    return { success: true };
  } catch (error) {
    throw error;
  }
}
```

### In Subscription Controller

```javascript
// File: backend/src/controllers/customer.controller.js

async createSubscription(req, res) {
  try {
    // ... create subscription logic ...
    
    const customer = await db.User.findByPk(userId);
    
    // Prepare data
    const subscriptionData = {
      subscriptionId: subscription.id,
      products: subscription.products.map(p => ({
        name: p.product.name,
        quantity: p.quantity,
        unit: p.product.unit,
        price: p.pricePerUnit
      })),
      frequency: subscription.frequency,
      startDate: moment(subscription.startDate).format('DD MMM YYYY'),
      totalPerDelivery: subscription.totalPerDelivery,
      deliveryTime: subscription.deliveryTime
    };
    
    // Send WhatsApp notification
    await whatsappService.sendSubscriptionCreated(
      customer.phone,
      customer.name,
      subscriptionData
    );
    
    // Send Email notification
    if (customer.email) {
      await emailService.sendSubscriptionEmail(
        customer.email,
        {
          customerName: customer.name,
          ...subscriptionData
        }
      );
    }
    
    res.json({ success: true, subscription });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}
```

### In Invoice Service

```javascript
// File: backend/src/services/invoice.service.js

async generateMonthlyInvoice(customerId, month, year) {
  try {
    // ... generate invoice logic ...
    
    const customer = await db.User.findByPk(customerId);
    
    // Prepare invoice data
    const invoiceData = {
      customerName: customer.name,
      invoiceNumber: invoice.invoiceNumber,
      invoiceDate: moment(invoice.invoiceDate).format('DD MMM YYYY'),
      periodStart: moment(invoice.periodStart).format('DD MMM YYYY'),
      periodEnd: moment(invoice.periodEnd).format('DD MMM YYYY'),
      deliveries: invoice.deliveryDetails.deliveries,
      subtotal: invoice.totalAmount,
      tax: 0,
      totalAmount: invoice.totalAmount,
      paidAmount: invoice.paidAmount,
      remainingAmount: invoice.remainingAmount,
      dueDate: moment(invoice.dueDate).format('DD MMM YYYY'),
      paymentLink: `${process.env.PAYMENT_BASE_URL}/${invoice.invoiceNumber}`
    };
    
    // Send WhatsApp notification
    await whatsappService.sendInvoice(
      customer.phone,
      customer.name,
      invoiceData
    );
    
    // Send Email with PDF attachment
    if (customer.email) {
      await emailService.sendInvoiceEmail(customer.email, {
        ...invoiceData,
        pdfPath: invoice.pdfPath,
        downloadLink: `${process.env.INVOICE_DOWNLOAD_URL}/${invoice.invoiceNumber}`
      });
    }
    
    return invoice;
  } catch (error) {
    throw error;
  }
}
```

---

## 🎨 Design Features

### WhatsApp Templates
- ✅ Unicode box drawing for professional borders
- ✅ Emoji-rich content for visual appeal
- ✅ Hierarchical information structure
- ✅ Security warnings for OTP
- ✅ Call-to-action prompts
- ✅ Branded headers and footers
- ✅ Readable formatting with proper spacing

### Email Templates
- ✅ **Responsive Design** - Works on all devices
- ✅ **Gradient Headers** - Beautiful purple gradient branding
- ✅ **Card-based Layouts** - Clean, organized information
- ✅ **Professional Typography** - Inter font family
- ✅ **Action Buttons** - Prominent CTAs with hover effects
- ✅ **Product Cards** - Visual product displays with icons
- ✅ **Payment Summaries** - Clear financial breakdowns
- ✅ **Branded Footer** - Social links and copyright
- ✅ **Mobile Optimized** - Responsive breakpoints
- ✅ **Accessibility** - Proper color contrast and structure

---

## 🔧 Customization

### Changing Brand Colors

Edit `email-templates.js`:

```javascript
// Find gradient definitions and replace:
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);

// With your brand colors:
background: linear-gradient(135deg, #your-color-1 0%, #your-color-2 100%);
```

### Changing Logo/Branding

```javascript
// In email template header:
<div class="header-logo">🥛 YOUR BRAND NAME</div>
<div class="header-tagline">Your Tagline Here</div>

// In WhatsApp templates:
const header = `┏━━━━━━━━━━━━━━━━━━━━━━━┓
┃   🥛 YOUR BRAND       ┃
┗━━━━━━━━━━━━━━━━━━━━━━━┛`;
```

### Adding Custom Templates

```javascript
// In whatsapp-templates.js
static generateCustomMessage(data) {
  return `┏━━━━━━━━━━━━━━━━━━━━━━━┓
┃   YOUR CUSTOM MSG     ┃
┗━━━━━━━━━━━━━━━━━━━━━━━┛

${data.content}

━━━━━━━━━━━━━━━━━━━━━━━
🥛 Ksheermitra
━━━━━━━━━━━━━━━━━━━━━━━`;
}
```

---

## 📊 Testing

### Test WhatsApp Connection

```javascript
const whatsappService = require('./services/whatsapp.service');

await whatsappService.initialize();
// Scan QR code with WhatsApp
// Once connected, test:
await whatsappService.sendOTP('your-phone', '123456', 10);
```

### Test Email Configuration

```javascript
const emailService = require('./services/email.service');

await emailService.testConnection();
// Should log: Email service connection verified successfully
```

---

## 🚀 Production Deployment

### Environment Setup

1. **SMTP Configuration** - Use professional email service:
   - Gmail (with App Password)
   - SendGrid
   - AWS SES
   - Mailgun

2. **WhatsApp Business API** - For production scale:
   - Switch from `whatsapp-web.js` to official Business API
   - Better reliability and delivery rates

### Best Practices

1. **Rate Limiting** - Don't spam customers
2. **Opt-in/Opt-out** - Respect customer preferences
3. **Personalization** - Use customer names
4. **Timing** - Send at appropriate times
5. **Testing** - Always test before going live
6. **Monitoring** - Track delivery rates
7. **Fallback** - Have backup notification methods

---

## 📝 License

These templates are part of the Ksheermitra project.

---

## 💬 Support

For issues or questions:
- Check the implementation in `whatsapp.service.js`
- Review template files for customization
- Test with sample data first

---

**Created with ❤️ for Ksheermitra**
*Professional messaging templates inspired by industry leaders*

