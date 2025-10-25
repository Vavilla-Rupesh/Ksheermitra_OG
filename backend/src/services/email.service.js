/**
 * Email Service for sending professional HTML emails
 * Integrates with nodemailer and premium email templates
 */

const nodemailer = require('nodemailer');
const logger = require('../utils/logger');
const EmailTemplates = require('../templates/email-templates');

class EmailService {
  constructor() {
    this.transporter = null;
    this.initialize();
  }

  initialize() {
    try {
      // Configure email transporter
      this.transporter = nodemailer.createTransport({
        host: process.env.SMTP_HOST || 'smtp.gmail.com',
        port: process.env.SMTP_PORT || 587,
        secure: process.env.SMTP_SECURE === 'true',
        auth: {
          user: process.env.SMTP_USER,
          pass: process.env.SMTP_PASS
        }
      });

      logger.info('Email service initialized successfully');
    } catch (error) {
      logger.error('Error initializing email service:', error);
    }
  }

  async sendEmail(to, subject, html, attachments = []) {
    try {
      if (!this.transporter) {
        throw new Error('Email transporter not initialized');
      }

      const mailOptions = {
        from: `"Ksheermitra" <${process.env.SMTP_FROM || process.env.SMTP_USER}>`,
        to,
        subject,
        html,
        attachments
      };

      const info = await this.transporter.sendMail(mailOptions);
      logger.info(`Email sent successfully to ${to}: ${info.messageId}`);

      return { success: true, messageId: info.messageId };
    } catch (error) {
      logger.error(`Error sending email to ${to}:`, error);
      throw error;
    }
  }

  /**
   * Send OTP Email
   */
  async sendOTPEmail(to, data) {
    const html = EmailTemplates.generateOTPEmail(data);
    const subject = `Your Verification Code: ${data.otp}`;
    return await this.sendEmail(to, subject, html);
  }

  /**
   * Send Welcome Email
   */
  async sendWelcomeEmail(to, data) {
    const html = EmailTemplates.generateWelcomeEmail(data);
    const subject = 'Welcome to Ksheermitra - Fresh Milk Daily!';
    return await this.sendEmail(to, subject, html);
  }

  /**
   * Send Subscription Confirmation Email
   */
  async sendSubscriptionEmail(to, data) {
    const html = EmailTemplates.generateSubscriptionEmail(data);
    const subject = `Subscription Confirmed - ID #${data.subscriptionId}`;
    return await this.sendEmail(to, subject, html);
  }

  /**
   * Send Invoice Email
   */
  async sendInvoiceEmail(to, data) {
    const html = EmailTemplates.generateInvoiceEmail(data);
    const subject = `Invoice ${data.invoiceNumber} - ₹${data.totalAmount.toFixed(2)}`;

    // Attach PDF if available
    const attachments = [];
    if (data.pdfPath) {
      attachments.push({
        filename: `Invoice-${data.invoiceNumber}.pdf`,
        path: data.pdfPath
      });
    }

    return await this.sendEmail(to, subject, html, attachments);
  }

  /**
   * Send Payment Confirmation Email
   */
  async sendPaymentConfirmationEmail(to, data) {
    const html = EmailTemplates.generatePaymentConfirmationEmail(data);
    const subject = `Payment Received - ₹${data.amount.toFixed(2)}`;
    return await this.sendEmail(to, subject, html);
  }

  /**
   * Send Delivery Confirmation Email
   */
  async sendDeliveryConfirmationEmail(to, data) {
    const html = EmailTemplates.generateDeliveryConfirmationEmail(data);
    const subject = `Delivered: ${data.productName} - ${data.deliveryDate}`;
    return await this.sendEmail(to, subject, html);
  }

  /**
   * Test email configuration
   */
  async testConnection() {
    try {
      if (!this.transporter) {
        throw new Error('Email transporter not initialized');
      }

      await this.transporter.verify();
      logger.info('Email service connection verified successfully');
      return true;
    } catch (error) {
      logger.error('Email service connection test failed:', error);
      return false;
    }
  }
}

module.exports = new EmailService();

