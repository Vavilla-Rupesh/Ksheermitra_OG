const authService = require('../services/auth.service');
const logger = require('../utils/logger');
const qrcode = require('qrcode');
const path = require('path');
const whatsappService = require('../services/whatsapp.service');
require('dotenv').config();

class AuthController {
  async sendOTP(req, res, next) {
    try {
      const { phone } = req.body;
      const ipAddress = req.ip || req.connection.remoteAddress;

      const result = await authService.sendOTP(phone, ipAddress);

      res.status(200).json(result);
    } catch (error) {
      logger.error('Error in sendOTP controller:', error);
      next(error);
    }
  }

  async verifyOTP(req, res, next) {
    try {
      const { phone, otp } = req.body;
      const ipAddress = req.ip || req.connection.remoteAddress;

      const result = await authService.verifyOTP(phone, otp, ipAddress);

      res.status(200).json(result);
    } catch (error) {
      logger.error('Error in verifyOTP controller:', error);
      next(error);
    }
  }

  async register(req, res, next) {
    try {
      const { phone, name, email, address, latitude, longitude, otp } = req.body;
      const ipAddress = req.ip || req.connection.remoteAddress;

      const userData = {
        phone,
        name,
        email,
        address,
        latitude,
        longitude
      };

      const result = await authService.register(userData, otp, ipAddress);

      res.status(201).json(result);
    } catch (error) {
      logger.error('Error in register controller:', error);
      next(error);
    }
  }

  async refreshToken(req, res, next) {
    try {
      const { refreshToken } = req.body;

      const result = await authService.refreshAccessToken(refreshToken);

      res.status(200).json(result);
    } catch (error) {
      logger.error('Error in refreshToken controller:', error);
      next(error);
    }
  }

  async logout(req, res, next) {
    try {
      res.status(200).json({
        success: true,
        message: 'Logged out successfully'
      });
    } catch (error) {
      logger.error('Error in logout controller:', error);
      next(error);
    }
  }

  // Serve a beautiful login page
  async serveLoginPage(req, res) {
    res.sendFile(path.join(__dirname, '../templates/login.html'));
  }

  // Handle login and generate QR code
  async handleLogin(req, res) {
    try {
      const { username, password } = req.body;

      logger.info(`Login attempt for username: ${username}`);

      // Validate credentials from .env
      if (
        username === process.env.WHATSAPP_ADMIN_USERNAME &&
        password === process.env.WHATSAPP_ADMIN_PASSWORD
      ) {
        logger.info('✅ Admin login successful. Checking for QR code...');

        // Get the latest QR code
        let qrCodeData = whatsappService.getLatestQrCode();

        // If no QR code is available, initialize WhatsApp to generate one
        if (!qrCodeData) {
          logger.info('No QR code available. Initializing WhatsApp...');

          try {
            // Initialize WhatsApp with login flag to generate QR code
            logger.info('Starting WhatsApp initialization...');
            const initResult = await whatsappService.initialize(false, true);

            if (!initResult) {
              logger.warn('WhatsApp initialization returned false');
              throw new Error('Failed to initialize WhatsApp');
            }

            logger.info('WhatsApp initialized successfully');

            // Wait a moment for QR code to be generated
            await new Promise(resolve => setTimeout(resolve, 2000));

            // Try to get QR code again
            qrCodeData = whatsappService.getLatestQrCode();

            if (qrCodeData) {
              logger.info('✅ QR code obtained after initialization');
            } else {
              logger.warn('QR code still not available after initialization');
            }
          } catch (error) {
            logger.error('Error during WhatsApp initialization:', error.message);
            logger.warn('QR code generation may still be in progress in background');
            // Continue anyway - QR code might still be generated in background
          }
        } else {
          logger.info('✅ Using previously generated QR code');
        }

        if (qrCodeData) {
          try {
            const qrCodeImage = await qrcode.toDataURL(qrCodeData);
            logger.info('✅ QR code converted to data URL successfully');

            res.status(200).json({
              success: true,
              message: 'Login successful. QR code generated.',
              qrCode: qrCodeImage
            });
          } catch (error) {
            logger.error('Error converting QR code to image:', error.message);
            res.status(500).json({
              success: false,
              message: 'Error generating QR code image',
              error: error.message
            });
          }
        } else {
          logger.warn('QR code not available after all attempts');
          res.status(503).json({
            success: false,
            message: 'QR code not available. WhatsApp connection is being established. Please try again in a few seconds.',
            retryAfter: 5
          });
        }
      } else {
        logger.warn(`Invalid login attempt with username: ${username}`);
        res.status(401).json({
          success: false,
          message: 'Invalid username or password'
        });
      }
    } catch (error) {
      logger.error('Error in handleLogin:', error.message, error.stack);
      res.status(500).json({
        success: false,
        message: 'Server error during login',
        error: error.message
      });
    }
  }
}

module.exports = new AuthController();
