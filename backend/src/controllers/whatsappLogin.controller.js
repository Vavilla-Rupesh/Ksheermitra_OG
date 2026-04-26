const logger = require('../utils/logger');
const whatsappSessionService = require('../services/whatsappSession.service');
const whatsappService = require('../services/whatsapp.service');

class WhatsAppLoginController {
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

