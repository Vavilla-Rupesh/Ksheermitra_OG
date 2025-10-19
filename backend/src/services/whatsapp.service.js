const { Client, LocalAuth } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const logger = require('../utils/logger');
const path = require('path');

class WhatsAppService {
  constructor() {
    this.client = null;
    this.isReady = false;
    this.messageQueue = [];
    this.processingQueue = false;
  }

  async initialize() {
    try {
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
          ]
        }
      });

      this.client.on('qr', (qr) => {
        logger.info('WhatsApp QR Code generated. Scan with your phone:');
        qrcode.generate(qr, { small: true });
      });

      this.client.on('ready', () => {
        this.isReady = true;
        logger.info('WhatsApp client is ready!');
        this.processMessageQueue();
      });

      this.client.on('authenticated', () => {
        logger.info('WhatsApp client authenticated successfully');
      });

      this.client.on('auth_failure', (msg) => {
        logger.error('WhatsApp authentication failed:', msg);
        this.isReady = false;
      });

      this.client.on('disconnected', (reason) => {
        logger.warn('WhatsApp client disconnected:', reason);
        this.isReady = false;
      });

      this.client.on('message', async (message) => {
        logger.info(`Received message from ${message.from}: ${message.body}`);
      });

      await this.client.initialize();
      logger.info('WhatsApp client initialization started');

      return true;
    } catch (error) {
      logger.error('Error initializing WhatsApp client:', error);
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
        maxRetries: 3
      };

      this.messageQueue.push(messageData);

      if (this.isReady && !this.processingQueue) {
        this.processMessageQueue();
      }
    });
  }

  async processMessageQueue() {
    if (this.processingQueue || this.messageQueue.length === 0) {
      return;
    }

    this.processingQueue = true;

    while (this.messageQueue.length > 0) {
      const messageData = this.messageQueue.shift();
      
      try {
        if (!this.isReady) {
          throw new Error('WhatsApp client is not ready');
        }

        const chatId = this.formatPhoneNumber(messageData.phone);
        await this.client.sendMessage(chatId, messageData.message);
        
        logger.info(`Message sent successfully to ${messageData.phone}`);
        messageData.resolve({ success: true, phone: messageData.phone });
      } catch (error) {
        logger.error(`Error sending message to ${messageData.phone}:`, error);
        
        if (messageData.retries < messageData.maxRetries) {
          messageData.retries++;
          this.messageQueue.push(messageData);
          logger.info(`Retrying message to ${messageData.phone} (attempt ${messageData.retries})`);
        } else {
          messageData.reject({
            success: false,
            error: error.message,
            phone: messageData.phone
          });
        }
      }

      await this.delay(2000);
    }

    this.processingQueue = false;
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

  async sendOTP(phone, otp) {
    const message = `Your Ksheermitra verification code is: ${otp}\n\nThis code will expire in ${process.env.OTP_EXPIRY_MINUTES || 10} minutes.\n\nDo not share this code with anyone.`;
    return await this.sendMessage(phone, message);
  }

  async sendDeliveryConfirmation(phone, customerName, products, date) {
    const productList = products.map(p => `${p.quantity} ${p.unit} ${p.name}`).join(', ');
    const message = `Dear ${customerName},\n\nYour delivery has been completed ✅\n\nProducts: ${productList}\nDate: ${date}\n\nThank you for choosing Ksheermitra!`;
    return await this.sendMessage(phone, message);
  }

  async sendDeliveryMissed(phone, customerName, products, date) {
    const productList = products.map(p => `${p.quantity} ${p.unit} ${p.name}`).join(', ');
    const message = `Dear ${customerName},\n\nYour delivery was missed ❌\n\nProducts: ${productList}\nDate: ${date}\n\nPlease contact us for assistance.\n\nKsheermitra Support`;
    return await this.sendMessage(phone, message);
  }

  async sendInvoice(phone, customerName, filePath) {
    const caption = `Dear ${customerName},\n\nPlease find your invoice attached.\n\nThank you for choosing Ksheermitra!`;
    return await this.sendFile(phone, filePath, caption);
  }

  delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  async disconnect() {
    if (this.client) {
      await this.client.destroy();
      this.isReady = false;
      logger.info('WhatsApp client disconnected');
    }
  }
}

module.exports = new WhatsAppService();
