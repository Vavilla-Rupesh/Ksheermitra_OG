const logger = require('../utils/logger');

/**
 * Basic authentication middleware for WhatsApp admin login
 * Compares username and password with environment variables
 */
const basicAuthWhatsApp = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Basic ')) {
      return res.status(401).json({
        success: false,
        message: 'Invalid or missing authorization header. Use Basic auth with username:password'
      });
    }

    // Extract credentials from Basic auth header
    const base64Credentials = authHeader.slice(6);
    const credentials = Buffer.from(base64Credentials, 'base64').toString('utf8');
    const [username, password] = credentials.split(':');

    // Get expected credentials from environment variables
    const expectedUsername = process.env.WHATSAPP_ADMIN_USERNAME;
    const expectedPassword = process.env.WHATSAPP_ADMIN_PASSWORD;

    if (!expectedUsername || !expectedPassword) {
      logger.error('WHATSAPP_ADMIN_USERNAME or WHATSAPP_ADMIN_PASSWORD not set in environment variables');
      return res.status(500).json({
        success: false,
        message: 'Server configuration error: Admin credentials not configured'
      });
    }

    // Validate credentials
    if (username !== expectedUsername || password !== expectedPassword) {
      logger.warn(`Failed WhatsApp admin authentication attempt with username: ${username}`);
      return res.status(401).json({
        success: false,
        message: 'Invalid username or password'
      });
    }

    logger.info('WhatsApp admin authenticated successfully');
    req.whatsappAdmin = { username };
    next();
  } catch (error) {
    logger.error('Error in basicAuthWhatsApp middleware:', error);
    res.status(500).json({
      success: false,
      message: 'Authentication error'
    });
  }
};

module.exports = {
  basicAuthWhatsApp
};

