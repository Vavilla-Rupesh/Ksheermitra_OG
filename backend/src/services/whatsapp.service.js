const qrcode = require('qrcode-terminal');
const logger = require('../utils/logger');
const path = require('path');
const fs = require('fs');
const WhatsAppTemplates = require('../templates/whatsapp-templates');

class WhatsAppService {
  constructor() {
    this.sock = null;
    this.isReady = false;
    this.messageQueue = [];
    this.processingQueue = false;
    this.isInitializing = false;
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 5;
    this.qrRetries = 0;
    this.maxQrRetries = 5;
    this.authState = null;
    this.saveCreds = null;
    this.baileys = null; // Will hold the dynamically imported module
    this.lastQrTime = 0;
    this.connectionState = 'disconnected'; // Track connection state
  }

  // Helper to wait/delay
  delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  // Load Baileys dynamically (ES Module)
  async loadBaileys() {
    if (this.baileys) return this.baileys;

    try {
      this.baileys = await import('@whiskeysockets/baileys');
      return this.baileys;
    } catch (error) {
      logger.error('Failed to load Baileys module:', error.message);
      throw error;
    }
  }

  // Clear session data
  async clearSession(retries = 5) {
    const sessionPath = process.env.WHATSAPP_SESSION_PATH || './baileys_auth';
    const fullPath = path.resolve(sessionPath);

    for (let attempt = 1; attempt <= retries; attempt++) {
      try {
        if (fs.existsSync(fullPath)) {
          await this.delay(1000);
          fs.rmSync(fullPath, { recursive: true, force: true, maxRetries: 3, retryDelay: 1000 });
          logger.info('WhatsApp session cleared successfully');
          return true;
        }
        return true;
      } catch (error) {
        logger.warn(`Attempt ${attempt}/${retries} to clear session failed:`, error.message);
        if (attempt === retries) {
          logger.error('Failed to clear WhatsApp session. Please manually delete:', fullPath);
          return false;
        }
        await this.delay(2000 * attempt);
      }
    }
    return false;
  }

  async initialize(clearSessionFirst = false) {
    if (this.isInitializing) {
      logger.warn('WhatsApp initialization already in progress, skipping...');
      return false;
    }

    if (this.isReady && this.sock && this.connectionState === 'open') {
      logger.info('WhatsApp is already connected, no need to reinitialize');
      return true;
    }

    this.isInitializing = true;

    try {
      // Load Baileys module
      const {
        default: makeWASocket,
        useMultiFileAuthState,
        DisconnectReason,
        fetchLatestBaileysVersion,
        makeCacheableSignalKeyStore
      } = await this.loadBaileys();

      // Also load pino dynamically
      const pino = (await import('pino')).default;

      // Clear session if requested
      if (clearSessionFirst) {
        await this.clearSession();
      }

      const sessionPath = process.env.WHATSAPP_SESSION_PATH || './baileys_auth';
      const fullPath = path.resolve(sessionPath);

      // Ensure directory exists
      if (!fs.existsSync(fullPath)) {
        fs.mkdirSync(fullPath, { recursive: true });
      }

      // Load auth state
      const { state, saveCreds } = await useMultiFileAuthState(fullPath);
      this.authState = state;
      this.saveCreds = saveCreds;

      // Get latest WhatsApp Web version
      const { version } = await fetchLatestBaileysVersion();
      logger.info(`Using WhatsApp Web version: ${version.join('.')}`);

      // Clean up existing socket if any
      if (this.sock) {
        try {
          logger.info('Cleaning up existing socket...');
          this.sock.ev.removeAllListeners();
          this.sock = null;
        } catch (e) {
          logger.warn('Error cleaning up socket:', e.message);
        }
      }

      // Create socket connection
      this.sock = makeWASocket({
        version,
        auth: {
          creds: state.creds,
          keys: makeCacheableSignalKeyStore(state.keys, pino({ level: 'silent' }))
        },
        printQRInTerminal: false,
        logger: pino({ level: 'silent' }),
        browser: ['Ksheer Mitra', 'Chrome', '120.0.0'],
        markOnlineOnConnect: true,
        generateHighQualityLinkPreview: true,
        syncFullHistory: false,
        defaultQueryTimeoutMs: undefined,
      });

      // Connection update handler
      this.sock.ev.on('connection.update', async (update) => {
        const { connection, lastDisconnect, qr } = update;

        // Handle QR code with rate limiting
        if (qr) {
          const now = Date.now();
          // Prevent QR spam - at least 10 seconds between QR codes
          if (now - this.lastQrTime < 10000) {
            logger.warn('QR code generated too quickly, throttling...');
            return;
          }
          this.lastQrTime = now;

          this.qrRetries++;
          logger.info('');
          logger.info('='.repeat(60));
          logger.info(`WhatsApp QR Code (${this.qrRetries}/${this.maxQrRetries}) - Scan with your phone:`);
          logger.info('='.repeat(60));
          qrcode.generate(qr, { small: true });
          logger.info('');
          logger.info('On your phone: WhatsApp > Linked Devices > Link a Device');
          logger.info('='.repeat(60));

          if (this.qrRetries >= this.maxQrRetries) {
            logger.error(`QR code generated ${this.qrRetries} times without successful scan!`);
            logger.info('Please check:');
            logger.info('1. Your phone has internet connection');
            logger.info('2. WhatsApp is up to date');
            logger.info('3. You are scanning from Linked Devices menu');
            logger.info('');
            logger.info('The server will continue waiting for QR scan...');
          }
        }

        // Track connection state changes
        if (connection) {
          this.connectionState = connection;
          logger.info(`Connection state: ${connection}`);
        }

        // Handle connection status
        if (connection === 'open') {
          this.isReady = true;
          this.isInitializing = false;
          this.reconnectAttempts = 0;
          this.qrRetries = 0;
          this.connectionState = 'open';
          logger.info('✅ WhatsApp connected successfully!');
          logger.info('Session saved. No need to scan QR code again on restart.');

          // Process any queued messages
          if (this.messageQueue.length > 0) {
            logger.info(`📤 Processing ${this.messageQueue.length} queued message(s)...`);
            this.processMessageQueue();
          } else {
            logger.info('No queued messages to process.');
          }
        }

        if (connection === 'close') {
          this.isReady = false;
          const statusCode = lastDisconnect?.error?.output?.statusCode;
          const shouldReconnect = statusCode !== DisconnectReason.loggedOut;

          logger.warn(`WhatsApp connection closed. Status code: ${statusCode}`);

          if (statusCode === DisconnectReason.loggedOut) {
            logger.error('❌ Device logged out from WhatsApp');
            logger.info('Session will be cleared. You need to scan QR code again.');
            await this.clearSession();
            this.reconnectAttempts = 0;
            this.isInitializing = false;

            // Wait 5 seconds then try to reconnect with fresh session
            logger.info('Waiting 5 seconds before requesting new QR code...');
            await this.delay(5000);
            this.isInitializing = false;
            await this.initialize(true);

          } else if (statusCode === DisconnectReason.restartRequired) {
            logger.info('WhatsApp requires restart - reconnecting...');
            this.isInitializing = false;
            await this.delay(2000);
            await this.initialize(false);

          } else if (statusCode === DisconnectReason.timedOut) {
            logger.warn('Connection timed out - reconnecting...');
            if (this.reconnectAttempts < this.maxReconnectAttempts) {
              this.reconnectAttempts++;
              await this.delay(3000);
              this.isInitializing = false;
              await this.initialize(false);
            } else {
              logger.error('Max reconnection attempts reached due to timeout');
              this.isInitializing = false;
            }

          } else if (shouldReconnect) {
            if (this.reconnectAttempts < this.maxReconnectAttempts) {
              this.reconnectAttempts++;
              const delayTime = Math.min(3000 * this.reconnectAttempts, 15000);
              logger.info(`Reconnecting in ${delayTime/1000}s (attempt ${this.reconnectAttempts}/${this.maxReconnectAttempts})...`);
              await this.delay(delayTime);
              this.isInitializing = false;
              await this.initialize(false);
            } else {
              logger.error('Max reconnection attempts reached');
              logger.info('Please restart the server to reconnect');
              this.isInitializing = false;
            }
          } else {
            logger.info('Connection closed - not reconnecting');
            this.isInitializing = false;
          }
        }
      });

      // Credentials update handler
      this.sock.ev.on('creds.update', saveCreds);

      // Message handler
      this.sock.ev.on('messages.upsert', async ({ messages, type }) => {
        if (type === 'notify') {
          for (const msg of messages) {
            if (!msg.key.fromMe && msg.message) {
              const from = msg.key.remoteJid;
              const text = msg.message.conversation ||
                          msg.message.extendedTextMessage?.text || '';
              logger.info(`Message from ${from}: ${text}`);
            }
          }
        }
      });

      logger.info('WhatsApp initialization started with Baileys');
      return true;

    } catch (error) {
      logger.error('Error initializing WhatsApp:', error.message);
      this.isReady = false;
      this.isInitializing = false;
      throw error;
    }
  }

  formatPhoneNumber(phone) {
    let formatted = phone.replace(/[^\d+]/g, '');

    if (formatted.startsWith('+')) {
      formatted = formatted.substring(1);
    }

    if (formatted.startsWith('91') && formatted.length === 12) {
      return formatted + '@s.whatsapp.net';
    } else if (formatted.length === 10) {
      return '91' + formatted + '@s.whatsapp.net';
    }

    return formatted + '@s.whatsapp.net';
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

      // Set a timeout for the message - increased to 3 minutes
      setTimeout(() => {
        const index = this.messageQueue.findIndex(m => m.timestamp === messageData.timestamp);
        if (index !== -1) {
          this.messageQueue.splice(index, 1);
          logger.warn(`Message to ${phone} timed out after 3 minutes`);
          reject({
            success: false,
            error: 'Message sending timed out - WhatsApp not connected',
            phone: messageData.phone
          });
        }
      }, 180000); // 3 minutes timeout

      if (this.isReady && !this.processingQueue) {
        logger.info('WhatsApp is ready, processing message immediately');
        this.processMessageQueue();
      } else if (!this.isReady) {
        if (this.isInitializing) {
          logger.warn('WhatsApp is connecting. Message will be sent once connection is ready.');
        } else {
          logger.error('WhatsApp is not connected! Please scan QR code or restart the server.');
          logger.info('Run: npm run dev and scan the QR code');
        }
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
        if (!this.isReady || !this.sock) {
          logger.warn('WhatsApp not ready, re-queuing message');
          this.messageQueue.push(messageData);
          break;
        }

        const jid = this.formatPhoneNumber(messageData.phone);
        await this.sock.sendMessage(jid, { text: messageData.message });

        logger.info(`✅ Message sent to ${messageData.phone}`);
        messageData.resolve({ success: true, phone: messageData.phone });
      } catch (error) {
        logger.error(`Error sending message to ${messageData.phone}:`, error.message);

        if (messageData.retries < messageData.maxRetries) {
          messageData.retries++;
          this.messageQueue.push(messageData);
          logger.info(`Retrying message to ${messageData.phone} (attempt ${messageData.retries}/${messageData.maxRetries})`);
          await this.delay(3000);
        } else {
          logger.error(`Failed to send message to ${messageData.phone} after ${messageData.maxRetries} attempts`);
          messageData.reject({
            success: false,
            error: error.message || 'Failed to send message',
            phone: messageData.phone
          });
        }
      }

      await this.delay(2000);
    }

    this.processingQueue = false;
    logger.info('Message queue processing completed');
  }

  async sendFile(phone, filePath, caption = '') {
    return new Promise(async (resolve, reject) => {
      try {
        if (!this.isReady || !this.sock) {
          throw new Error('WhatsApp client is not ready');
        }

        const jid = this.formatPhoneNumber(phone);
        const fileBuffer = fs.readFileSync(filePath);
        const fileName = path.basename(filePath);

        await this.sock.sendMessage(jid, {
          document: fileBuffer,
          fileName: fileName,
          caption: caption
        });

        logger.info(`File sent successfully to ${phone}`);
        resolve({ success: true, phone });
      } catch (error) {
        logger.error(`Error sending file to ${phone}:`, error.message);
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
    if (this.sock) {
      try {
        await this.sock.logout();
        logger.info('WhatsApp disconnected');
      } catch (error) {
        logger.warn('Error during disconnect:', error.message);
      }
      this.sock = null;
      this.isReady = false;
      this.isInitializing = false;
    }
  }

  async resetSession() {
    logger.info('Resetting WhatsApp session...');
    await this.disconnect();
    await this.clearSession();
    this.reconnectAttempts = 0;
    this.qrRetries = 0;
    return await this.initialize(false);
  }

  getStatus() {
    return {
      isReady: this.isReady,
      isInitializing: this.isInitializing,
      queueLength: this.messageQueue.length,
      processing: this.processingQueue,
      reconnectAttempts: this.reconnectAttempts,
      maxReconnectAttempts: this.maxReconnectAttempts
    };
  }
}

module.exports = new WhatsAppService();

