const { Client, LocalAuth } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const logger = require('../utils/logger');
const path = require('path');
const WhatsAppTemplates = require('../templates/whatsapp-templates');

class WhatsAppService {
  constructor() {
    this.client = null;
    this.isReady = false;
    this.messageQueue = [];
    this.processingQueue = false;
    this.initializationTimeout = null;
    this.maxInitTime = 120000; // 2 minutes max for initialization
  }

  async initialize() {
    try {
      // Clear any existing timeout
      if (this.initializationTimeout) {
        clearTimeout(this.initializationTimeout);
      }

      const sessionPath = process.env.WHATSAPP_SESSION_PATH || './whatsapp-session';
      
      this.client = new Client({
        authStrategy: new LocalAuth({
          clientId: 'ksheermitra',
          dataPath: path.resolve(sessionPath)
        }),
        puppeteer: {
          headless: true,
          args: [
            '--no-sandbox',
            '--disable-setuid-sandbox',
            '--disable-dev-shm-usage',
            '--disable-accelerated-2d-canvas',
            '--no-first-run',
            '--no-zygote',
            '--disable-gpu'
          ],
          timeout: 60000 // 60 seconds timeout for puppeteer operations
        }
      });

      // Set initialization timeout
      this.initializationTimeout = setTimeout(() => {
        if (!this.isReady) {
          logger.warn('WhatsApp initialization timeout - continuing without WhatsApp');
          this.isReady = false;
        }
      }, this.maxInitTime);

      this.client.on('qr', (qr) => {
        logger.info('WhatsApp QR Code generated. Scan with your phone:');
        qrcode.generate(qr, { small: true });
      });

      this.client.on('ready', () => {
        this.isReady = true;
        logger.info('WhatsApp client is ready!');
        if (this.initializationTimeout) {
          clearTimeout(this.initializationTimeout);
        }
        this.processMessageQueue();
      });

      this.client.on('authenticated', () => {
        logger.info('WhatsApp client authenticated successfully');
      });

      this.client.on('auth_failure', (msg) => {
        logger.error('WhatsApp authentication failed:', msg);
        this.isReady = false;
        if (this.initializationTimeout) {
          clearTimeout(this.initializationTimeout);
        }
      });

      this.client.on('disconnected', (reason) => {
        logger.warn('WhatsApp client disconnected:', reason);
        this.isReady = false;
        // Attempt to reconnect after 5 seconds
        setTimeout(() => {
          logger.info('Attempting to reconnect WhatsApp...');
          this.initialize().catch(err => {
            logger.error('Reconnection failed:', err);
          });
        }, 5000);
      });

      this.client.on('message', async (message) => {
        logger.info(`Received message from ${message.from}: ${message.body}`);
      });

      await this.client.initialize();
      logger.info('WhatsApp client initialization started');

      return true;
    } catch (error) {
      logger.error('Error initializing WhatsApp client:', error);
      this.isReady = false;
      if (this.initializationTimeout) {
        clearTimeout(this.initializationTimeout);
      }
      throw error;
    }
  }

  formatPhoneNumber(phone) {
    let formatted = phone.replace(/[^\d+]/g, '');
    
    if (formatted.startsWith('+')) {
      formatted = formatted.substring(1);
    }
    
    if (formatted.startsWith('91') && formatted.length === 12) {
      return formatted + '@c.us';
    } else if (formatted.length === 10) {
      return '91' + formatted + '@c.us';
    }
    
    return formatted + '@c.us';
  }

  async sendMessage(phone, message) {
    return new Promise((resolve, reject) => {
      const messageData = {
        phone,
        message,
        resolve,
        reject,
        retries: 0,
        maxRetries: 3,
        timestamp: Date.now()
      };

      this.messageQueue.push(messageData);
      logger.info(`Message queued for ${phone}. Queue length: ${this.messageQueue.length}`);

      // Set a timeout for the message
      setTimeout(() => {
        const index = this.messageQueue.findIndex(m => m.timestamp === messageData.timestamp);
        if (index !== -1) {
          this.messageQueue.splice(index, 1);
          logger.warn(`Message to ${phone} timed out and was removed from queue`);
          reject({
            success: false,
            error: 'Message sending timed out',
            phone: messageData.phone
          });
        }
      }, 60000); // 60 second timeout per message

      if (this.isReady && !this.processingQueue) {
        this.processMessageQueue();
      } else if (!this.isReady) {
        logger.warn(`WhatsApp not ready. Message will be sent when connection is established.`);
      }
    });
  }

  async processMessageQueue() {
    if (this.processingQueue || this.messageQueue.length === 0) {
      return;
    }

    this.processingQueue = true;
    logger.info(`Processing message queue. ${this.messageQueue.length} messages pending.`);

    while (this.messageQueue.length > 0) {
      const messageData = this.messageQueue.shift();
      
      try {
        if (!this.isReady) {
          logger.warn('WhatsApp client not ready, re-queuing message');
          this.messageQueue.push(messageData);
          break;
        }

        const chatId = this.formatPhoneNumber(messageData.phone);
        await this.client.sendMessage(chatId, messageData.message);
        
        logger.info(`Message sent successfully to ${messageData.phone}`);
        messageData.resolve({ success: true, phone: messageData.phone });
      } catch (error) {
        logger.error(`Error sending message to ${messageData.phone}:`, error.message);

        if (messageData.retries < messageData.maxRetries) {
          messageData.retries++;
          this.messageQueue.push(messageData);
          logger.info(`Retrying message to ${messageData.phone} (attempt ${messageData.retries}/${messageData.maxRetries})`);
          await this.delay(3000); // Wait 3 seconds before retry
        } else {
          logger.error(`Failed to send message to ${messageData.phone} after ${messageData.maxRetries} attempts`);
          messageData.reject({
            success: false,
            error: error.message || 'Failed to send message',
            phone: messageData.phone
          });
        }
      }

      // Delay between messages to avoid rate limiting
      await this.delay(2000);
    }

    this.processingQueue = false;
    logger.info('Message queue processing completed');
  }

  // Helper method for delays
  delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  async sendFile(phone, filePath, caption = '') {
    return new Promise(async (resolve, reject) => {
      try {
        if (!this.isReady) {
          throw new Error('WhatsApp client is not ready');
        }

        const chatId = this.formatPhoneNumber(phone);
        const media = require('whatsapp-web.js').MessageMedia.fromFilePath(filePath);
        
        await this.client.sendMessage(chatId, media, { caption });
        
        logger.info(`File sent successfully to ${phone}`);
        resolve({ success: true, phone });
      } catch (error) {
        logger.error(`Error sending file to ${phone}:`, error);
        reject({ success: false, error: error.message, phone });
      }
    });
  }

  async sendOTP(phone, otp, expiryMinutes = 10, userName = null) {
    try {
      logger.info(`Attempting to send OTP to ${phone}`);
      const message = WhatsAppTemplates.generateOTPMessage(otp, expiryMinutes, userName);
      const result = await this.sendMessage(phone, message);
      logger.info(`OTP sent successfully to ${phone}`);
      return result;
    } catch (error) {
      logger.error(`Failed to send OTP to ${phone}:`, error);
      // Don't throw error, return failure result to allow auth to continue
      return {
        success: false,
        error: error.message || 'Failed to send OTP via WhatsApp',
        phone
      };
    }
  }

  async sendWelcomeMessage(phone, userName) {
    const message = WhatsAppTemplates.generateWelcomeMessage(userName, phone);
    return await this.sendMessage(phone, message);
  }

  async sendSubscriptionCreated(phone, customerName, subscriptionDetails) {
    const message = WhatsAppTemplates.generateSubscriptionCreatedMessage({
      customerName,
      ...subscriptionDetails
    });
    return await this.sendMessage(phone, message);
  }

  async sendDeliveryConfirmation(phone, deliveryDetails) {
    const message = WhatsAppTemplates.generateDeliveryConfirmationMessage(deliveryDetails);
    return await this.sendMessage(phone, message);
  }

  async sendInvoice(phone, customerName, invoiceDetails) {
    const message = WhatsAppTemplates.generateInvoiceMessage({
      customerName,
      ...invoiceDetails
    });
    return await this.sendMessage(phone, message);
  }

  async sendPaymentConfirmation(phone, paymentDetails) {
    const message = WhatsAppTemplates.generatePaymentConfirmationMessage(paymentDetails);
    return await this.sendMessage(phone, message);
  }

  async sendSubscriptionPaused(phone, pauseDetails) {
    const message = WhatsAppTemplates.generateSubscriptionPausedMessage(pauseDetails);
    return await this.sendMessage(phone, message);
  }

  async sendSubscriptionModified(phone, modificationDetails) {
    const message = WhatsAppTemplates.generateSubscriptionModifiedMessage(modificationDetails);
    return await this.sendMessage(phone, message);
  }

  async sendPaymentReminder(phone, reminderDetails) {
    const message = WhatsAppTemplates.generatePaymentReminderMessage(reminderDetails);
    return await this.sendMessage(phone, message);
  }

  async sendOutForDelivery(phone, deliveryDetails) {
    const message = WhatsAppTemplates.generateOutForDeliveryMessage(deliveryDetails);
    return await this.sendMessage(phone, message);
  }

  async disconnect() {
    if (this.initializationTimeout) {
      clearTimeout(this.initializationTimeout);
    }
    if (this.client) {
      await this.client.destroy();
      this.isReady = false;
      logger.info('WhatsApp client disconnected');
    }
  }

  // Check WhatsApp readiness status
  getStatus() {
    return {
      isReady: this.isReady,
      queueLength: this.messageQueue.length,
      processing: this.processingQueue
    };
  }
}

module.exports = new WhatsAppService();
