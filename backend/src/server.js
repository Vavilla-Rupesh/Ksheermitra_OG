require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const path = require('path');
const logger = require('./utils/logger');
const db = require('./config/db');
const whatsappService = require('./services/whatsapp.service');
const cronService = require('./services/cron.service');
const { errorHandler, notFound } = require('./middleware/error.middleware');

const authRoutes = require('./routes/auth.routes');
const customerRoutes = require('./routes/customer.routes');
const deliveryBoyRoutes = require('./routes/deliveryBoy.routes');
const adminRoutes = require('./routes/admin.routes');

const app = express();
const PORT = process.env.PORT || 3000;

// Trust proxy - required for rate limiting and getting correct IP addresses
app.set('trust proxy', 1);

// Configure helmet with relaxed CSP for ngrok
app.use(helmet({
  contentSecurityPolicy: false,
  crossOriginEmbedderPolicy: false,
  crossOriginResourcePolicy: { policy: "cross-origin" }
}));

// Configure CORS with permissive settings for ngrok
app.use(cors({
  origin: true,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'ngrok-skip-browser-warning']
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Middleware to handle ngrok browser warning bypass
app.use((req, res, next) => {
  res.setHeader('ngrok-skip-browser-warning', 'true');
  next();
});

// Serve static files from uploads directory
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));
app.use('/api/uploads', express.static(path.join(__dirname, '../uploads')));

const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000,
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,
  message: 'Too many requests from this IP, please try again later.'
});

app.use('/api/', limiter);

app.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Server is running',
    timestamp: new Date().toISOString(),
    whatsapp: whatsappService.isReady
  });
});

app.use('/api/auth', authRoutes);
app.use('/api/customer', customerRoutes);
app.use('/api/delivery-boy', deliveryBoyRoutes);
app.use('/api/admin', adminRoutes);

app.use(notFound);
app.use(errorHandler);

const startServer = async () => {
  try {
    await db.sequelize.authenticate();
    logger.info('Database connection established successfully');

    // Sync database with minimal changes - don't alter existing constraints
    try {
      await db.sequelize.sync({ alter: false, force: false });
      logger.info('Database synchronized');
    } catch (syncError) {
      logger.warn('Database sync warning (this is usually safe to ignore):', syncError.message);
      logger.info('Continuing with existing database schema');
    }

    // Initialize WhatsApp with timeout - don't let it block server startup
    const whatsappTimeout = setTimeout(() => {
      logger.warn('WhatsApp initialization timeout - server will continue without WhatsApp');
    }, 30000); // 30 second timeout for WhatsApp init

    whatsappService.initialize()
      .then(() => {
        clearTimeout(whatsappTimeout);
        logger.info('WhatsApp service initialized successfully');
      })
      .catch(error => {
        clearTimeout(whatsappTimeout);
        logger.error('WhatsApp service initialization failed:', error);
        logger.warn('Server will continue without WhatsApp functionality');
        logger.info('OTPs will still be stored in database for manual verification');
      });

    cronService.start();

    app.listen(PORT, () => {
      logger.info(`Server is running on port ${PORT}`);
      logger.info(`Environment: ${process.env.NODE_ENV || 'development'}`);
      logger.info(`Health check: http://localhost:${PORT}/health`);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
};

process.on('SIGINT', async () => {
  logger.info('Shutting down gracefully...');
  
  try {
    await whatsappService.disconnect();
    await db.sequelize.close();
    logger.info('Connections closed');
    process.exit(0);
  } catch (error) {
    logger.error('Error during shutdown:', error);
    process.exit(1);
  }
});

process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

process.on('uncaughtException', (error) => {
  logger.error('Uncaught Exception:', error);
  process.exit(1);
});

startServer();

module.exports = app;
