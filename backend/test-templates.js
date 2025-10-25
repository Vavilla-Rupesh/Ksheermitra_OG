/**
 * Test file for Premium WhatsApp and Email Templates
 * Run this to test your template implementation
 */

const whatsappService = require('./src/services/whatsapp.service');
const emailService = require('./src/services/email.service');

// Test data
const testData = {
  phone: '9876543210', // Replace with your test phone number
  email: 'test@example.com', // Replace with your test email
  customerName: 'Rajesh Kumar',

  subscription: {
    subscriptionId: 'SUB-TEST-001',
    products: [
      { name: 'Full Cream Milk', quantity: 1, unit: 'Litre', price: 60 },
      { name: 'Toned Milk', quantity: 0.5, unit: 'Litre', price: 50 }
    ],
    frequency: 'daily',
    startDate: '15 Nov 2024',
    totalPerDelivery: 85,
    deliveryTime: '6:00 AM - 8:00 AM'
  },

  delivery: {
    customerName: 'Rajesh Kumar',
    productName: 'Full Cream Milk',
    quantity: 1,
    unit: 'Litre',
    deliveryTime: '7:15 AM',
    deliveryDate: '15 Nov 2024',
    deliveryBoyName: 'Ramesh Kumar',
    deliveryBoyPhone: '9876543211',
    amount: 60
  },

  invoice: {
    invoiceNumber: 'INV-2024-11-001',
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
      {
        date: '02 Oct',
        productName: 'Full Cream Milk',
        quantity: 1,
        unit: 'Litre',
        amount: 60,
        pricePerUnit: 60
      }
    ],
    subtotal: 1800,
    tax: 0,
    totalAmount: 1800,
    paidAmount: 0,
    remainingAmount: 1800,
    dueDate: '10 Nov 2024',
    paymentLink: 'https://pay.ksheermitra.com/INV-2024-11-001'
  },

  payment: {
    customerName: 'Rajesh Kumar',
    amount: 1800,
    paymentMethod: 'UPI - Google Pay',
    transactionId: 'TXN123456789',
    invoiceNumber: 'INV-2024-11-001',
    date: '08 Nov 2024, 10:30 AM',
    remainingBalance: 0
  }
};

async function testWhatsAppTemplates() {
  console.log('🧪 Testing WhatsApp Templates...\n');

  try {
    // Test 1: OTP
    console.log('1️⃣ Testing OTP Message...');
    await whatsappService.sendOTP(testData.phone, '123456', 10, testData.customerName);
    console.log('✅ OTP message sent!\n');
    await delay(3000);

    // Test 2: Welcome Message
    console.log('2️⃣ Testing Welcome Message...');
    await whatsappService.sendWelcomeMessage(testData.phone, testData.customerName);
    console.log('✅ Welcome message sent!\n');
    await delay(3000);

    // Test 3: Subscription Created
    console.log('3️⃣ Testing Subscription Created...');
    await whatsappService.sendSubscriptionCreated(
      testData.phone,
      testData.customerName,
      testData.subscription
    );
    console.log('✅ Subscription message sent!\n');
    await delay(3000);

    // Test 4: Delivery Confirmation
    console.log('4️⃣ Testing Delivery Confirmation...');
    await whatsappService.sendDeliveryConfirmation(testData.phone, testData.delivery);
    console.log('✅ Delivery confirmation sent!\n');
    await delay(3000);

    // Test 5: Invoice
    console.log('5️⃣ Testing Invoice Message...');
    await whatsappService.sendInvoice(
      testData.phone,
      testData.customerName,
      testData.invoice
    );
    console.log('✅ Invoice message sent!\n');
    await delay(3000);

    // Test 6: Payment Confirmation
    console.log('6️⃣ Testing Payment Confirmation...');
    await whatsappService.sendPaymentConfirmation(testData.phone, testData.payment);
    console.log('✅ Payment confirmation sent!\n');

    console.log('✅ All WhatsApp tests completed successfully!\n');
  } catch (error) {
    console.error('❌ WhatsApp test failed:', error.message);
  }
}

async function testEmailTemplates() {
  console.log('📧 Testing Email Templates...\n');

  try {
    // Test connection first
    console.log('🔌 Testing email connection...');
    const isConnected = await emailService.testConnection();
    if (!isConnected) {
      throw new Error('Email service not configured. Please set SMTP_* environment variables.');
    }
    console.log('✅ Email connection successful!\n');

    // Test 1: OTP Email
    console.log('1️⃣ Testing OTP Email...');
    await emailService.sendOTPEmail(testData.email, {
      userName: testData.customerName,
      otp: '123456',
      expiryMinutes: 10
    });
    console.log('✅ OTP email sent!\n');
    await delay(2000);

    // Test 2: Welcome Email
    console.log('2️⃣ Testing Welcome Email...');
    await emailService.sendWelcomeEmail(testData.email, {
      userName: testData.customerName,
      email: testData.email,
      phone: testData.phone
    });
    console.log('✅ Welcome email sent!\n');
    await delay(2000);

    // Test 3: Subscription Email
    console.log('3️⃣ Testing Subscription Email...');
    await emailService.sendSubscriptionEmail(testData.email, {
      customerName: testData.customerName,
      ...testData.subscription
    });
    console.log('✅ Subscription email sent!\n');
    await delay(2000);

    // Test 4: Invoice Email
    console.log('4️⃣ Testing Invoice Email...');
    await emailService.sendInvoiceEmail(testData.email, {
      customerName: testData.customerName,
      ...testData.invoice
    });
    console.log('✅ Invoice email sent!\n');
    await delay(2000);

    // Test 5: Payment Confirmation Email
    console.log('5️⃣ Testing Payment Confirmation Email...');
    await emailService.sendPaymentConfirmationEmail(testData.email, testData.payment);
    console.log('✅ Payment confirmation email sent!\n');

    console.log('✅ All Email tests completed successfully!\n');
  } catch (error) {
    console.error('❌ Email test failed:', error.message);
  }
}

function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function runTests() {
  console.log('╔═══════════════════════════════════════════╗');
  console.log('║  🧪 Premium Templates Test Suite         ║');
  console.log('╚═══════════════════════════════════════════╝\n');

  console.log('⚠️  Make sure to:');
  console.log('   1. Update test phone number in this file');
  console.log('   2. Update test email in this file');
  console.log('   3. Configure SMTP settings in .env');
  console.log('   4. WhatsApp client is connected\n');

  const readline = require('readline').createInterface({
    input: process.stdin,
    output: process.stdout
  });

  readline.question('Continue with tests? (y/n): ', async (answer) => {
    if (answer.toLowerCase() === 'y') {
      console.log('\n');

      // Test WhatsApp
      await testWhatsAppTemplates();

      console.log('\n─────────────────────────────────────────\n');

      // Test Email
      await testEmailTemplates();

      console.log('\n╔═══════════════════════════════════════════╗');
      console.log('║  ✅ All Tests Completed!                  ║');
      console.log('╚═══════════════════════════════════════════╝\n');
    } else {
      console.log('Tests cancelled.');
    }

    readline.close();
    process.exit(0);
  });
}

// Run if called directly
if (require.main === module) {
  runTests();
}

module.exports = { testWhatsAppTemplates, testEmailTemplates };

