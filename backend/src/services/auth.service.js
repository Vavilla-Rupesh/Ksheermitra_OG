const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const db = require('../config/db');
const logger = require('../utils/logger');
const whatsappService = require('./whatsapp.service');

class AuthService {
  generateOTP() {
    const length = parseInt(process.env.OTP_LENGTH) || 6;
    const min = Math.pow(10, length - 1);
    const max = Math.pow(10, length) - 1;
    return crypto.randomInt(min, max).toString();
  }

  async sendOTP(phone, ipAddress) {
    try {
      const expiryMinutes = parseInt(process.env.OTP_EXPIRY_MINUTES) || 10;
      const otp = this.generateOTP();
      const expiresAt = new Date(Date.now() + expiryMinutes * 60 * 1000);

      const recentOTP = await db.OTPLog.findOne({
        where: {
          phone,
          isVerified: false,
          expiresAt: {
            [db.Sequelize.Op.gt]: new Date()
          }
        },
        order: [['createdAt', 'DESC']]
      });

      if (recentOTP && (Date.now() - new Date(recentOTP.createdAt).getTime()) < 60000) {
        throw new Error('Please wait at least 1 minute before requesting a new OTP');
      }

      let user = await db.User.findOne({ where: { phone } });

      const otpLog = await db.OTPLog.create({
        userId: user ? user.id : null,
        phone,
        otp,
        expiresAt,
        ipAddress
      });

      // Send OTP via WhatsApp - but don't let it block the response
      let whatsappSent = false;
      let whatsappStatus = 'pending';
      try {
        const whatsappResult = await Promise.race([
          whatsappService.sendOTP(phone, otp),
          new Promise((_, reject) =>
            setTimeout(() => reject(new Error('WhatsApp timeout - connection may still be establishing')), 180000)
          )
        ]);
        whatsappSent = whatsappResult && whatsappResult.success;
        whatsappStatus = whatsappSent ? 'sent' : 'failed';
        logger.info(`WhatsApp OTP ${whatsappStatus} for ${phone}`);
      } catch (whatsappError) {
        logger.warn(`WhatsApp OTP failed for ${phone}: ${whatsappError.message}`);
        whatsappStatus = whatsappError.message.includes('not connected') ? 'not_connected' : 'failed';
        // Continue without WhatsApp - OTP is still valid in database
      }

      logger.info(`OTP created for ${phone.replace(/\d(?=\d{2})/g, '*')} (WhatsApp: ${whatsappStatus})`);

      return {
        success: true,
        message: whatsappSent
          ? 'OTP sent successfully via WhatsApp'
          : whatsappStatus === 'not_connected'
          ? 'OTP generated successfully. WhatsApp is connecting - message may arrive shortly.'
          : 'OTP generated successfully. Please check your phone or contact support.',
        expiresAt,
        userExists: !!user,
        whatsappSent,
        whatsappStatus,
        otp: process.env.NODE_ENV === 'development' ? otp : undefined // Only in dev mode
      };
    } catch (error) {
      logger.error('Error sending OTP:', error);
      throw error;
    }
  }

  async verifyOTP(phone, otp, ipAddress) {
    try {
      const otpLog = await db.OTPLog.findOne({
        where: {
          phone,
          otp,
          isVerified: false,
          expiresAt: {
            [db.Sequelize.Op.gt]: new Date()
          }
        },
        order: [['createdAt', 'DESC']]
      });

      if (!otpLog) {
        if (otpLog) {
          otpLog.attempts = (otpLog.attempts || 0) + 1;
          await otpLog.save();
        }
        throw new Error('Invalid or expired OTP');
      }

      if (otpLog.attempts >= 5) {
        throw new Error('Maximum verification attempts exceeded. Please request a new OTP');
      }

      otpLog.isVerified = true;
      otpLog.verifiedAt = new Date();
      await otpLog.save();

      let user = await db.User.findOne({ where: { phone } });

      // Check if user is new (doesn't exist or doesn't have name)
      const isNewUser = !user || !user.name;

      if (!user) {
        // Don't create user yet - let them complete registration
        logger.info(`OTP verified for new user: ${phone}`);
        return {
          success: true,
          isNewUser: true,
          requiresRegistration: true,
          message: 'OTP verified. Please complete your registration.',
          phone: phone
        };
      }

      // Existing user with complete profile
      user.lastLogin = new Date();
      await user.save();

      const token = this.generateToken(user);
      const refreshToken = this.generateRefreshToken(user);

      logger.info(`User authenticated: ${phone}`);

      return {
        success: true,
        isNewUser: false,
        requiresRegistration: false,
        user: {
          id: user.id,
          name: user.name,
          phone: user.phone,
          email: user.email,
          role: user.role,
          address: user.address,
          latitude: user.latitude,
          longitude: user.longitude,
          areaId: user.areaId,
          isActive: user.isActive
        },
        token,
        refreshToken
      };
    } catch (error) {
      logger.error('Error verifying OTP:', error);
      throw error;
    }
  }

  async register(userData, otp, ipAddress) {
    try {
      const { phone, name, email, address, latitude, longitude } = userData;

      // Verify OTP first
      const otpLog = await db.OTPLog.findOne({
        where: {
          phone,
          otp,
          isVerified: false,
          expiresAt: {
            [db.Sequelize.Op.gt]: new Date()
          }
        },
        order: [['createdAt', 'DESC']]
      });

      if (!otpLog) {
        throw new Error('Invalid or expired OTP');
      }

      if (otpLog.attempts >= 5) {
        throw new Error('Maximum verification attempts exceeded. Please request a new OTP');
      }

      // Check if user already exists
      let user = await db.User.findOne({ where: { phone } });

      if (user) {
        throw new Error('User already exists. Please login instead.');
      }

      // Mark OTP as verified
      otpLog.isVerified = true;
      otpLog.verifiedAt = new Date();
      await otpLog.save();

      // Create new user with complete details
      user = await db.User.create({
        phone,
        name,
        email: email || null,
        address: address || null,
        latitude: latitude || null,
        longitude: longitude || null,
        role: 'customer',
        isActive: true,
        lastLogin: new Date()
      });

      logger.info(`New user registered: ${phone}`);

      const token = this.generateToken(user);
      const refreshToken = this.generateRefreshToken(user);

      return {
        success: true,
        message: 'Registration successful',
        user: {
          id: user.id,
          name: user.name,
          phone: user.phone,
          email: user.email,
          role: user.role,
          address: user.address,
          latitude: user.latitude,
          longitude: user.longitude,
          areaId: user.areaId,
          isActive: user.isActive
        },
        token,
        refreshToken
      };
    } catch (error) {
      logger.error('Error in registration:', error);
      throw error;
    }
  }

  generateToken(user) {
    const payload = {
      id: user.id,
      phone: user.phone,
      role: user.role
    };

    return jwt.sign(
      payload,
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );
  }

  generateRefreshToken(user) {
    const payload = {
      id: user.id,
      phone: user.phone
    };

    return jwt.sign(
      payload,
      process.env.JWT_REFRESH_SECRET,
      { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d' }
    );
  }

  async refreshAccessToken(refreshToken) {
    try {
      const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
      
      const user = await db.User.findByPk(decoded.id);
      
      if (!user || !user.isActive) {
        throw new Error('User not found or inactive');
      }

      const newToken = this.generateToken(user);

      return {
        success: true,
        token: newToken
      };
    } catch (error) {
      logger.error('Error refreshing token:', error);
      throw new Error('Invalid refresh token');
    }
  }

  verifyToken(token) {
    try {
      return jwt.verify(token, process.env.JWT_SECRET);
    } catch (error) {
      throw new Error('Invalid or expired token');
    }
  }
}

module.exports = new AuthService();
