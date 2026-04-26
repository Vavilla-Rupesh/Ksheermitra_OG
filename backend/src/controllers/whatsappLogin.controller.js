const logger = require('../utils/logger');
const whatsappSessionService = require('../services/whatsappSession.service');
const whatsappService = require('../services/whatsapp.service');

class WhatsAppLoginController {
  /**
   * Admin Login with username and password
   * POST /api/whatsapp-login/login
   * Body: { username, password }
   */
  async adminLogin(req, res, next) {
    try {
      const { username, password } = req.body;

      // Validate input
      if (!username || !password) {
        return res.status(400).json({
          success: false,
          message: 'Username and password are required'
        });
      }

      // Get expected credentials from environment
      const expectedUsername = process.env.WHATSAPP_ADMIN_USERNAME;
      const expectedPassword = process.env.WHATSAPP_ADMIN_PASSWORD;

      if (!expectedUsername || !expectedPassword) {
        logger.error('WHATSAPP_ADMIN_USERNAME or WHATSAPP_ADMIN_PASSWORD not set in environment');
        return res.status(500).json({
          success: false,
          message: 'Server configuration error'
        });
      }

      // Validate credentials
      if (username !== expectedUsername || password !== expectedPassword) {
        logger.warn(`Failed WhatsApp admin login attempt with username: ${username}`);
        return res.status(401).json({
          success: false,
          message: 'Invalid username or password'
        });
      }

      logger.info('WhatsApp admin login successful');

      // Generate QR code
      const qrResult = await whatsappSessionService.generateQRCode();

      res.status(200).json({
        success: true,
        message: 'Login successful. Here is your QR code',
        data: {
          qrCode: qrResult.qrCode,
          sessionId: qrResult.sessionId,
          expiresIn: qrResult.expiresIn,
          instructions: [
            'Open WhatsApp on your phone',
            'Go to Settings > Linked Devices',
            'Click "Link a device"',
            'Scan the QR code shown above',
            'Confirm on your phone'
          ]
        }
      });
    } catch (error) {
      logger.error('Error in admin login:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Login failed'
      });
    }
  }

  /**
   * Get WhatsApp QR code for admin login
   * POST /api/whatsapp-login/get-qr
   */
  async getQRCode(req, res, next) {
    try {
      logger.info('Admin requesting WhatsApp QR code');

      // Generate new QR code
      const qrResult = await whatsappSessionService.generateQRCode();

      res.status(200).json({
        success: true,
        message: qrResult.message,
        data: {
          qrCode: qrResult.qrCode,
          sessionId: qrResult.sessionId,
          expiresIn: qrResult.expiresIn,
          instructions: [
            'Open WhatsApp on your phone',
            'Go to Settings > Linked Devices',
            'Click "Link a device"',
            'Scan the QR code shown above',
            'Confirm on your phone'
          ]
        }
      });
    } catch (error) {
      logger.error('Error getting QR code:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Failed to generate QR code'
      });
    }
  }

  /**
   * Get WhatsApp session status
   * GET /api/whatsapp-login/status
   */
  async getSessionStatus(req, res, next) {
    try {
      const status = await whatsappSessionService.getSessionStatus();

      res.status(200).json({
        success: true,
        data: status
      });
    } catch (error) {
      logger.error('Error getting session status:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Failed to get session status'
      });
    }
  }

  /**
   * Reset WhatsApp session and request new QR scan
   * POST /api/whatsapp-login/reset
   */
  async resetSession(req, res, next) {
    try {
      logger.info('Admin requesting WhatsApp session reset');

      // Reset the session record in database
      await whatsappSessionService.resetSession();

      // Reset the WhatsApp service
      await whatsappService.resetSession();

      res.status(200).json({
        success: true,
        message: 'WhatsApp session reset. Please scan the new QR code.',
        nextAction: 'GET /api/whatsapp-login/get-qr'
      });
    } catch (error) {
      logger.error('Error resetting session:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Failed to reset session'
      });
    }
  }

  /**
   * Get detailed session info for dashboard
   * GET /api/whatsapp-login/info
   */
  async getSessionInfo(req, res, next) {
    try {
      const status = await whatsappSessionService.getSessionStatus();
      const whatsappStatus = whatsappService.getStatus();

      // Check if session is about to expire
      const expirationInfo = await whatsappSessionService.checkSessionExpiration();

      res.status(200).json({
        success: true,
        data: {
          session: status,
          whatsapp: whatsappStatus,
          expirationAlert: expirationInfo ? {
            isExpiringSoon: true,
            expiresAt: expirationInfo.expiresAt,
            minutesUntilExpiry: expirationInfo.minutesUntilExpiry,
            message: `WhatsApp session will expire in ${expirationInfo.minutesUntilExpiry} minutes. Please scan a new QR code.`
          } : {
            isExpiringSoon: false,
            message: 'WhatsApp session is healthy'
          }
        }
      });
    } catch (error) {
      logger.error('Error getting session info:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Failed to get session info'
      });
    }
  }
}

module.exports = new WhatsAppLoginController();

