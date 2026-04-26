const db = require('../config/db');
const logger = require('../utils/logger');
const QRCode = require('qrcode');
const moment = require('moment');

class WhatsAppSessionService {
  /**
   * Generate and save QR code for WhatsApp authentication
   */
  async generateQRCode() {
    try {
      // Get or create the WhatsApp session record
      let session = await db.WhatsAppSession.findOne({
        order: [['createdAt', 'DESC']],
        limit: 1
      });

      if (!session) {
        session = await db.WhatsAppSession.create({
          isConnected: false,
          connectionState: 'disconnected'
        });
      }

      // Generate a unique QR token that includes timestamp and session ID
      const qrToken = `${session.id}_${Date.now()}`;

      // Generate QR code as data URL
      const qrDataUrl = await QRCode.toDataURL(qrToken, {
        errorCorrectionLevel: 'H',
        type: 'image/png',
        quality: 0.95,
        margin: 1,
        width: 300
      });

      // Save QR code and metadata to session
      await session.update({
        sessionQrCode: qrDataUrl,
        lastQrGeneratedAt: new Date(),
        connectionState: 'connecting',
        metadata: {
          ...session.metadata,
          qrToken,
          qrGeneratedBy: 'admin',
          qrValidUntil: moment().add(5, 'minutes').toISOString()
        }
      });

      logger.info('WhatsApp QR code generated successfully');
      return {
        success: true,
        qrCode: qrDataUrl,
        sessionId: session.id,
        expiresIn: 300, // 5 minutes in seconds
        message: 'QR code generated. Scan it within 5 minutes using WhatsApp Linked Devices'
      };
    } catch (error) {
      logger.error('Error generating QR code:', error);
      throw new Error(`Failed to generate QR code: ${error.message}`);
    }
  }

  /**
   * Get current session status
   */
  async getSessionStatus() {
    try {
      const session = await db.WhatsAppSession.findOne({
        order: [['createdAt', 'DESC']],
        limit: 1
      });

      if (!session) {
        return {
          success: true,
          isConnected: false,
          connectionState: 'disconnected',
          message: 'No active session found'
        };
      }

      const status = {
        success: true,
        sessionId: session.id,
        isConnected: session.isConnected,
        connectionState: session.connectionState,
        sessionStartedAt: session.sessionStartedAt,
        sessionExpiresAt: session.sessionExpiresAt,
        lastQrGeneratedAt: session.lastQrGeneratedAt,
        uptime: null,
        timeUntilExpiration: null
      };

      // Calculate uptime if session is started
      if (session.sessionStartedAt) {
        const uptime = moment().diff(moment(session.sessionStartedAt), 'hours');
        status.uptime = uptime;
      }

      // Calculate time until expiration
      if (session.sessionExpiresAt) {
        const expiresIn = moment(session.sessionExpiresAt).diff(moment(), 'hours');
        status.timeUntilExpiration = expiresIn;
      }

      return status;
    } catch (error) {
      logger.error('Error getting session status:', error);
      throw new Error(`Failed to get session status: ${error.message}`);
    }
  }

  /**
   * Update session status when WhatsApp connects
   */
  async updateSessionOnConnect() {
    try {
      const session = await db.WhatsAppSession.findOne({
        order: [['createdAt', 'DESC']],
        limit: 1
      });

      if (!session) {
        return await db.WhatsAppSession.create({
          isConnected: true,
          connectionState: 'open',
          sessionStartedAt: new Date(),
          sessionExpiresAt: moment().add(72, 'hours').toDate() // Session valid for 72 hours
        });
      }

      await session.update({
        isConnected: true,
        connectionState: 'open',
        sessionStartedAt: new Date(),
        sessionExpiresAt: moment().add(72, 'hours').toDate()
      });

      logger.info('WhatsApp session updated - connected');
      return session;
    } catch (error) {
      logger.error('Error updating session on connect:', error);
      throw error;
    }
  }

  /**
   * Update session status when WhatsApp disconnects
   */
  async updateSessionOnDisconnect() {
    try {
      const session = await db.WhatsAppSession.findOne({
        order: [['createdAt', 'DESC']],
        limit: 1
      });

      if (session) {
        await session.update({
          isConnected: false,
          connectionState: 'disconnected',
          sessionExpiresAt: null
        });
      }

      logger.info('WhatsApp session updated - disconnected');
      return session;
    } catch (error) {
      logger.error('Error updating session on disconnect:', error);
      throw error;
    }
  }

  /**
   * Check if session is about to expire (within 1 hour)
   */
  async checkSessionExpiration() {
    try {
      const session = await db.WhatsAppSession.findOne({
        where: { isConnected: true },
        order: [['createdAt', 'DESC']],
        limit: 1
      });

      if (!session || !session.sessionExpiresAt) {
        return null;
      }

      const now = moment();
      const expiresAt = moment(session.sessionExpiresAt);
      const minutesUntilExpiry = expiresAt.diff(now, 'minutes');

      // Return true if session expires within 60 minutes
      if (minutesUntilExpiry <= 60 && minutesUntilExpiry > 0) {
        return {
          expiresAt: session.sessionExpiresAt,
          minutesUntilExpiry,
          shouldNotify: !session.expirationNotificationSentAt ||
                       moment(session.expirationNotificationSentAt).isBefore(moment().subtract(1, 'hour'))
        };
      }

      return null;
    } catch (error) {
      logger.error('Error checking session expiration:', error);
      throw error;
    }
  }

  /**
   * Mark expiration notification as sent
   */
  async markExpirationNotificationSent() {
    try {
      const session = await db.WhatsAppSession.findOne({
        order: [['createdAt', 'DESC']],
        limit: 1
      });

      if (session) {
        await session.update({
          expirationNotificationSentAt: new Date()
        });
      }

      return session;
    } catch (error) {
      logger.error('Error marking expiration notification:', error);
      throw error;
    }
  }

  /**
   * Reset session (clear for new login)
   */
  async resetSession() {
    try {
      const session = await db.WhatsAppSession.findOne({
        order: [['createdAt', 'DESC']],
        limit: 1
      });

      if (session) {
        await session.update({
          sessionQrCode: null,
          lastQrGeneratedAt: null,
          sessionStartedAt: null,
          sessionExpiresAt: null,
          isConnected: false,
          connectionState: 'disconnected',
          expirationNotificationSentAt: null,
          metadata: null
        });
      }

      logger.info('WhatsApp session reset');
      return session;
    } catch (error) {
      logger.error('Error resetting session:', error);
      throw error;
    }
  }
}

module.exports = new WhatsAppSessionService();

