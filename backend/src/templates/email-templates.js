/**
 * Premium HTML Email Templates
 * Professional templates inspired by Amazon, Swiggy, RedBus
 * For email notifications with rich formatting
 */

class EmailTemplates {

  /**
   * Base HTML Template with responsive design
   */
  static getBaseTemplate(content, preheader = '') {
    return `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>Ksheermitra</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif;
            line-height: 1.6;
            color: #333333;
            background-color: #f5f5f5;
        }

        .email-wrapper {
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
        }

        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 30px 20px;
            text-align: center;
            color: white;
        }

        .header-logo {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 5px;
        }

        .header-tagline {
            font-size: 14px;
            opacity: 0.9;
        }

        .content {
            padding: 40px 30px;
        }

        .hero-icon {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 50%;
            margin: 0 auto 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 40px;
        }

        .greeting {
            font-size: 18px;
            color: #333;
            margin-bottom: 20px;
        }

        .message {
            font-size: 16px;
            color: #555;
            margin-bottom: 30px;
            line-height: 1.8;
        }

        .card {
            background: #f8f9fa;
            border-radius: 12px;
            padding: 25px;
            margin: 20px 0;
            border-left: 4px solid #667eea;
        }

        .card-title {
            font-size: 16px;
            font-weight: 600;
            color: #333;
            margin-bottom: 15px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px solid #e0e0e0;
        }

        .info-row:last-child {
            border-bottom: none;
        }

        .info-label {
            color: #666;
            font-size: 14px;
        }

        .info-value {
            color: #333;
            font-weight: 600;
            font-size: 14px;
        }

        .highlight-box {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 12px;
            text-align: center;
            margin: 30px 0;
        }

        .highlight-label {
            font-size: 14px;
            opacity: 0.9;
            margin-bottom: 10px;
        }

        .highlight-value {
            font-size: 36px;
            font-weight: 700;
            letter-spacing: 8px;
        }

        .highlight-subtext {
            font-size: 13px;
            opacity: 0.8;
            margin-top: 10px;
        }

        .button {
            display: inline-block;
            padding: 15px 40px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white !important;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 600;
            font-size: 16px;
            text-align: center;
            margin: 20px 0;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
            transition: transform 0.2s;
        }

        .button:hover {
            transform: translateY(-2px);
        }

        .button-secondary {
            background: white;
            color: #667eea !important;
            border: 2px solid #667eea;
            box-shadow: none;
        }

        .divider {
            height: 1px;
            background: linear-gradient(to right, transparent, #e0e0e0, transparent);
            margin: 30px 0;
        }

        .alert {
            background: #fff3cd;
            border-left: 4px solid #ffc107;
            padding: 15px;
            border-radius: 8px;
            margin: 20px 0;
        }

        .alert-danger {
            background: #f8d7da;
            border-left-color: #dc3545;
        }

        .alert-success {
            background: #d4edda;
            border-left-color: #28a745;
        }

        .alert-info {
            background: #d1ecf1;
            border-left-color: #17a2b8;
        }

        .product-item {
            display: flex;
            align-items: center;
            padding: 15px;
            background: white;
            border-radius: 8px;
            margin: 10px 0;
            border: 1px solid #e0e0e0;
        }

        .product-icon {
            width: 50px;
            height: 50px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            margin-right: 15px;
        }

        .product-details {
            flex: 1;
        }

        .product-name {
            font-weight: 600;
            color: #333;
            margin-bottom: 5px;
        }

        .product-quantity {
            font-size: 14px;
            color: #666;
        }

        .product-price {
            font-weight: 700;
            color: #667eea;
            font-size: 18px;
        }

        .footer {
            background: #2d3748;
            color: white;
            padding: 30px;
            text-align: center;
        }

        .footer-links {
            margin: 20px 0;
        }

        .footer-link {
            color: #a0aec0;
            text-decoration: none;
            margin: 0 15px;
            font-size: 14px;
        }

        .social-links {
            margin: 20px 0;
        }

        .social-link {
            display: inline-block;
            width: 40px;
            height: 40px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 50%;
            margin: 0 5px;
            line-height: 40px;
            text-decoration: none;
            color: white;
        }

        .copyright {
            font-size: 12px;
            color: #a0aec0;
            margin-top: 20px;
        }

        .preheader {
            display: none;
            font-size: 1px;
            color: #ffffff;
            line-height: 1px;
            max-height: 0px;
            max-width: 0px;
            opacity: 0;
            overflow: hidden;
        }

        @media only screen and (max-width: 600px) {
            .content {
                padding: 20px 15px;
            }

            .highlight-value {
                font-size: 28px;
                letter-spacing: 6px;
            }

            .button {
                padding: 12px 30px;
                font-size: 14px;
            }
        }
    </style>
</head>
<body>
    <div class="preheader">${preheader}</div>
    <div class="email-wrapper">
        <div class="header">
            <div class="header-logo">🥛 KSHEERMITRA</div>
            <div class="header-tagline">Fresh Milk, Daily Delivered</div>
        </div>
        ${content}
        <div class="footer">
            <div class="footer-links">
                <a href="#" class="footer-link">Help Center</a>
                <a href="#" class="footer-link">Contact Us</a>
                <a href="#" class="footer-link">Privacy Policy</a>
            </div>
            <div class="social-links">
                <a href="#" class="social-link">f</a>
                <a href="#" class="social-link">t</a>
                <a href="#" class="social-link">i</a>
            </div>
            <div class="copyright">
                &copy; ${new Date().getFullYear()} Ksheermitra. All rights reserved.<br>
                Fresh Milk Delivery Service
            </div>
        </div>
    </div>
</body>
</html>`;
  }

  /**
   * OTP Email Template
   */
  static generateOTPEmail(data) {
    const { userName, otp, expiryMinutes = 10 } = data;

    const content = `
        <div class="content">
            <div class="hero-icon">🔐</div>
            <div class="greeting">Hello ${userName || 'there'}!</div>
            <div class="message">
                We received a request to verify your phone number. Use the code below to complete your verification:
            </div>

            <div class="highlight-box">
                <div class="highlight-label">Your Verification Code</div>
                <div class="highlight-value">${otp}</div>
                <div class="highlight-subtext">Valid for ${expiryMinutes} minutes</div>
            </div>

            <div class="alert alert-danger">
                <strong>⚠️ Security Alert:</strong><br>
                • Never share this OTP with anyone<br>
                • Ksheermitra will never call you asking for OTP<br>
                • If you didn't request this, please ignore this email
            </div>

            <div class="divider"></div>

            <div class="message" style="font-size: 14px; color: #666;">
                This code will expire at <strong>${this.getExpiryTime(expiryMinutes)}</strong>.
                If you didn't request this code, you can safely ignore this email.
            </div>
        </div>
    `;

    return this.getBaseTemplate(content, `Your verification code is ${otp}`);
  }

  /**
   * Welcome Email Template
   */
  static generateWelcomeEmail(data) {
    const { userName, email, phone } = data;

    const content = `
        <div class="content">
            <div class="hero-icon">🎉</div>
            <div class="greeting">Welcome to Ksheermitra, ${userName}!</div>
            <div class="message">
                We're thrilled to have you join our family of happy customers! Get ready to experience
                farm-fresh milk delivered right to your doorstep every day.
            </div>

            <div class="card">
                <div class="card-title">Your Account Details</div>
                <div class="info-row">
                    <span class="info-label">Name:</span>
                    <span class="info-value">${userName}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Phone:</span>
                    <span class="info-value">${phone}</span>
                </div>
                ${email ? `<div class="info-row">
                    <span class="info-label">Email:</span>
                    <span class="info-value">${email}</span>
                </div>` : ''}
            </div>

            <div class="message">
                <strong>What's Next?</strong><br>
                ✅ Browse our fresh products<br>
                ✅ Create your personalized subscription<br>
                ✅ Choose your delivery schedule<br>
                ✅ Enjoy hassle-free daily deliveries
            </div>

            <div style="text-align: center;">
                <a href="#" class="button">Start Shopping Now</a>
            </div>

            <div class="divider"></div>

            <div class="alert alert-success">
                <strong>🎁 Welcome Offer!</strong><br>
                Get 10% off on your first subscription. Use code: <strong>WELCOME10</strong>
            </div>
        </div>
    `;

    return this.getBaseTemplate(content, `Welcome to Ksheermitra! Start your fresh milk journey.`);
  }

  /**
   * Subscription Created Email
   */
  static generateSubscriptionEmail(data) {
    const {
      customerName,
      subscriptionId,
      products,
      frequency,
      startDate,
      totalPerDelivery,
      deliveryTime
    } = data;

    const productsHTML = products.map(p => `
        <div class="product-item">
            <div class="product-icon">🥛</div>
            <div class="product-details">
                <div class="product-name">${p.name}</div>
                <div class="product-quantity">${p.quantity} ${p.unit}</div>
            </div>
            <div class="product-price">₹${(p.quantity * p.price).toFixed(2)}</div>
        </div>
    `).join('');

    const content = `
        <div class="content">
            <div class="hero-icon">✅</div>
            <div class="greeting">Great Choice, ${customerName}!</div>
            <div class="message">
                Your subscription has been successfully created and is now active.
                We'll deliver fresh milk to your doorstep as per your schedule.
            </div>

            <div class="card">
                <div class="card-title">Subscription Details</div>
                <div class="info-row">
                    <span class="info-label">Subscription ID:</span>
                    <span class="info-value">#${subscriptionId}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Frequency:</span>
                    <span class="info-value">${frequency}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Start Date:</span>
                    <span class="info-value">${startDate}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Delivery Time:</span>
                    <span class="info-value">${deliveryTime || '6:00 AM - 8:00 AM'}</span>
                </div>
            </div>

            <div class="card">
                <div class="card-title">Your Products</div>
                ${productsHTML}
            </div>

            <div class="highlight-box">
                <div class="highlight-label">Total Per Delivery</div>
                <div class="highlight-value">₹${totalPerDelivery.toFixed(2)}</div>
                <div class="highlight-subtext">Billed monthly based on actual deliveries</div>
            </div>

            <div style="text-align: center;">
                <a href="#" class="button">View Subscription</a>
                <a href="#" class="button button-secondary">Manage Schedule</a>
            </div>

            <div class="divider"></div>

            <div class="alert alert-info">
                <strong>📱 Pro Tip:</strong> Download our mobile app to track deliveries,
                pause subscriptions, and manage your account on the go!
            </div>
        </div>
    `;

    return this.getBaseTemplate(content, `Your subscription is confirmed! First delivery: ${startDate}`);
  }

  /**
   * Monthly Invoice Email
   */
  static generateInvoiceEmail(data) {
    const {
      customerName,
      invoiceNumber,
      invoiceDate,
      periodStart,
      periodEnd,
      deliveries,
      subtotal,
      tax,
      totalAmount,
      paidAmount,
      remainingAmount,
      dueDate,
      downloadLink
    } = data;

    const deliveryRows = deliveries.map(d => `
        <div class="info-row">
            <span class="info-label">${d.date} - ${d.productName} (${d.quantity} ${d.unit})</span>
            <span class="info-value">₹${d.amount.toFixed(2)}</span>
        </div>
    `).join('');

    const isPaid = remainingAmount === 0;
    const statusClass = isPaid ? 'alert-success' : 'alert-danger';
    const statusIcon = isPaid ? '✅' : '⏳';
    const statusText = isPaid ? 'PAID' : 'PAYMENT PENDING';

    const content = `
        <div class="content">
            <div class="hero-icon">📄</div>
            <div class="greeting">Dear ${customerName},</div>
            <div class="message">
                Your monthly invoice is ready. Thank you for being a valued customer!
            </div>

            <div class="card">
                <div class="card-title">Invoice Information</div>
                <div class="info-row">
                    <span class="info-label">Invoice Number:</span>
                    <span class="info-value">${invoiceNumber}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Invoice Date:</span>
                    <span class="info-value">${invoiceDate}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Billing Period:</span>
                    <span class="info-value">${periodStart} to ${periodEnd}</span>
                </div>
            </div>

            <div class="card">
                <div class="card-title">Delivery Summary</div>
                ${deliveryRows}
            </div>

            <div class="card">
                <div class="card-title">Payment Summary</div>
                <div class="info-row">
                    <span class="info-label">Subtotal:</span>
                    <span class="info-value">₹${subtotal.toFixed(2)}</span>
                </div>
                ${tax ? `<div class="info-row">
                    <span class="info-label">Tax:</span>
                    <span class="info-value">₹${tax.toFixed(2)}</span>
                </div>` : ''}
                <div class="info-row" style="border-top: 2px solid #667eea; padding-top: 15px; margin-top: 10px;">
                    <span class="info-label"><strong>Total Amount:</strong></span>
                    <span class="info-value" style="color: #667eea; font-size: 18px;">₹${totalAmount.toFixed(2)}</span>
                </div>
                ${paidAmount > 0 ? `<div class="info-row">
                    <span class="info-label">Paid:</span>
                    <span class="info-value" style="color: #28a745;">₹${paidAmount.toFixed(2)}</span>
                </div>` : ''}
                ${remainingAmount > 0 ? `<div class="info-row">
                    <span class="info-label"><strong>Balance Due:</strong></span>
                    <span class="info-value" style="color: #dc3545; font-size: 18px;">₹${remainingAmount.toFixed(2)}</span>
                </div>` : ''}
            </div>

            <div class="alert ${statusClass}">
                <strong>${statusIcon} Payment Status: ${statusText}</strong><br>
                ${!isPaid ? `Due Date: <strong>${dueDate}</strong>` : 'Thank you for your payment!'}
            </div>

            <div style="text-align: center;">
                ${downloadLink ? `<a href="${downloadLink}" class="button">Download PDF Invoice</a>` : ''}
                ${!isPaid ? `<a href="#" class="button">Pay Now</a>` : ''}
            </div>

            <div class="divider"></div>

            <div class="message" style="font-size: 14px; color: #666;">
                Questions about your invoice? Contact our support team or reply to this email.
            </div>
        </div>
    `;

    return this.getBaseTemplate(content, `Invoice ${invoiceNumber} - ₹${totalAmount.toFixed(2)} ${isPaid ? 'Paid' : 'Due'}`);
  }

  /**
   * Payment Confirmation Email
   */
  static generatePaymentConfirmationEmail(data) {
    const {
      customerName,
      amount,
      paymentMethod,
      transactionId,
      invoiceNumber,
      date,
      remainingBalance
    } = data;

    const content = `
        <div class="content">
            <div class="hero-icon">✅</div>
            <div class="greeting">Payment Received, ${customerName}!</div>
            <div class="message">
                Thank you! We've successfully received your payment. Here are the details:
            </div>

            <div class="highlight-box">
                <div class="highlight-label">Amount Paid</div>
                <div class="highlight-value" style="letter-spacing: normal;">₹${amount.toFixed(2)}</div>
                <div class="highlight-subtext">${paymentMethod}</div>
            </div>

            <div class="card">
                <div class="card-title">Payment Details</div>
                <div class="info-row">
                    <span class="info-label">Transaction ID:</span>
                    <span class="info-value">${transactionId}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Invoice Number:</span>
                    <span class="info-value">${invoiceNumber}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Date & Time:</span>
                    <span class="info-value">${date}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Payment Method:</span>
                    <span class="info-value">${paymentMethod}</span>
                </div>
                ${remainingBalance !== undefined ? `<div class="info-row">
                    <span class="info-label">Remaining Balance:</span>
                    <span class="info-value">₹${remainingBalance.toFixed(2)}</span>
                </div>` : ''}
            </div>

            <div class="alert alert-success">
                <strong>✅ Payment Status: SUCCESSFUL</strong><br>
                ${remainingBalance === 0 ? 'Your account is fully paid!' : 'Partial payment received.'}
            </div>

            <div style="text-align: center;">
                <a href="#" class="button">Download Receipt</a>
                <a href="#" class="button button-secondary">View Invoice</a>
            </div>

            <div class="divider"></div>

            <div class="message" style="font-size: 14px; color: #666;">
                A copy of this receipt has been sent to your registered email.
                Keep this for your records.
            </div>
        </div>
    `;

    return this.getBaseTemplate(content, `Payment of ₹${amount.toFixed(2)} received successfully!`);
  }

  /**
   * Delivery Confirmation Email
   */
  static generateDeliveryConfirmationEmail(data) {
    const {
      customerName,
      productName,
      quantity,
      unit,
      deliveryTime,
      deliveryDate,
      deliveryBoyName,
      amount,
      imageUrl
    } = data;

    const content = `
        <div class="content">
            <div class="hero-icon">🚚</div>
            <div class="greeting">Delivered Successfully!</div>
            <div class="message">
                Hello ${customerName}, your order has been delivered at your doorstep.
            </div>

            ${imageUrl ? `<div style="text-align: center; margin: 20px 0;">
                <img src="${imageUrl}" alt="Delivery" style="max-width: 100%; border-radius: 12px; border: 2px solid #e0e0e0;">
            </div>` : ''}

            <div class="card">
                <div class="card-title">Delivery Details</div>
                <div class="info-row">
                    <span class="info-label">Product:</span>
                    <span class="info-value">${productName}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Quantity:</span>
                    <span class="info-value">${quantity} ${unit}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Date:</span>
                    <span class="info-value">${deliveryDate}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Time:</span>
                    <span class="info-value">${deliveryTime}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Delivered By:</span>
                    <span class="info-value">${deliveryBoyName}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Amount:</span>
                    <span class="info-value">₹${amount.toFixed(2)}</span>
                </div>
            </div>

            <div class="alert alert-info">
                <strong>💡 Rate Your Experience</strong><br>
                How was your delivery today? Your feedback helps us improve!
            </div>

            <div style="text-align: center;">
                <a href="#" class="button">Rate Delivery</a>
            </div>

            <div class="divider"></div>

            <div class="message" style="font-size: 14px; text-align: center;">
                See you tomorrow! 🥛
            </div>
        </div>
    `;

    return this.getBaseTemplate(content, `Your ${productName} has been delivered!`);
  }

  // Helper method
  static getExpiryTime(minutes) {
    const now = new Date();
    now.setMinutes(now.getMinutes() + minutes);
    return now.toLocaleTimeString('en-IN', {
      hour: '2-digit',
      minute: '2-digit',
      hour12: true
    });
  }
}

module.exports = EmailTemplates;

