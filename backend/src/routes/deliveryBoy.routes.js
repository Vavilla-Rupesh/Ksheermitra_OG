const express = require('express');
const router = express.Router();
const { body, param, query } = require('express-validator');
const deliveryBoyController = require('../controllers/deliveryBoy.controller');
const { authenticate, authorize } = require('../middleware/auth.middleware');
const validate = require('../middleware/validate.middleware');

// Apply authentication middleware to all routes
router.use(authenticate);
router.use(authorize('delivery_boy'));

/**
 * GET /api/delivery-boy/assigned-data/:deliveryBoyId
 * Fetch complete assigned data: area, customers, and today's deliveries
 */
router.get('/assigned-data/:deliveryBoyId', deliveryBoyController.getAssignedData);

/**
 * GET /api/delivery-boy/delivery-map
 * Fetch assigned delivery routes for navigation
 */
router.get('/delivery-map', [
  query('date').optional().isISO8601().withMessage('Invalid date format'),
  validate
], deliveryBoyController.getDeliveryMap);

/**
 * GET /api/delivery-boy/daily-summary
 * Fetch daily summary of deliveries for invoice generation
 */
router.get('/daily-summary', [
  query('date').optional().isISO8601().withMessage('Invalid date format'),
  validate
], deliveryBoyController.dailySummary);

/**
 * POST /api/delivery-boy/generate-invoice
 * Generate daily invoice for completed deliveries
 */
router.post('/generate-invoice', [
  body('date')
    .notEmpty().withMessage('Date is required')
    .isISO8601().withMessage('Invalid date format'),
  validate
], deliveryBoyController.generateInvoice);

/**
 * GET /api/delivery-boy/history
 * View delivery history with pagination
 */
router.get('/history', [
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100'),
  query('startDate').optional().isISO8601().withMessage('Invalid start date format'),
  query('endDate').optional().isISO8601().withMessage('Invalid end date format'),
  validate
], deliveryBoyController.getDeliveryHistory);

/**
 * GET /api/delivery-boy/stats
 * Get performance statistics
 */
router.get('/stats', [
  query('period')
    .optional()
    .isIn(['all', 'today', 'week', 'month'])
    .withMessage('Period must be one of: all, today, week, month'),
  validate
], deliveryBoyController.getStats);

/**
 * PATCH /api/delivery-boy/delivery/:id/status
 * Update delivery status
 */
router.patch('/delivery/:id/status', [
  param('id').isUUID().withMessage('Invalid delivery ID'),
  body('status')
    .notEmpty().withMessage('Status is required')
    .isIn(['pending', 'in-progress', 'delivered', 'missed', 'failed'])
    .withMessage('Status must be one of: pending, in-progress, delivered, missed, failed'),
  body('notes').optional().isString().withMessage('Notes must be a string'),
  body('latitude').optional().isDecimal().withMessage('Invalid latitude'),
  body('longitude').optional().isDecimal().withMessage('Invalid longitude'),
  validate
], deliveryBoyController.updateDeliveryStatus);

/**
 * GET /api/delivery-boy/profile
 * Get delivery boy profile
 */
router.get('/profile', deliveryBoyController.getProfile);

/**
 * PUT /api/delivery-boy/profile
 * Update delivery boy profile
 */
router.put('/profile', [
  body('name')
    .optional()
    .trim()
    .notEmpty().withMessage('Name cannot be empty')
    .isLength({ min: 2 }).withMessage('Name must be at least 2 characters'),
  body('email')
    .optional()
    .isEmail().withMessage('Invalid email format'),
  body('vehicleNumber')
    .optional()
    .trim()
    .isString().withMessage('Vehicle number must be a string'),
  body('licenseNumber')
    .optional()
    .trim()
    .isString().withMessage('License number must be a string'),
  validate
], deliveryBoyController.updateProfile);

/**
 * GET /api/delivery-boy/area
 * Get the delivery boy's assigned area with all details
 */
router.get('/area', deliveryBoyController.getArea);

/**
 * PUT /api/delivery-boy/location
 * Update current location
 */
router.put('/location', [
  body('latitude')
    .notEmpty().withMessage('Latitude is required')
    .isDecimal().withMessage('Invalid latitude'),
  body('longitude')
    .notEmpty().withMessage('Longitude is required')
    .isDecimal().withMessage('Invalid longitude'),
  validate
], deliveryBoyController.updateLocation);

/**
 * POST /api/delivery-boy/verify-delivery
 * Verify delivery location with geofence validation and mark as delivered.
 * Backend validates distance server-side for security.
 */
router.post('/verify-delivery', [
  body('deliveryId')
    .notEmpty().withMessage('Delivery ID is required')
    .isUUID().withMessage('Invalid delivery ID format'),
  body('agentLatitude')
    .notEmpty().withMessage('Agent latitude is required')
    .isDecimal().withMessage('Invalid latitude'),
  body('agentLongitude')
    .notEmpty().withMessage('Agent longitude is required')
    .isDecimal().withMessage('Invalid longitude'),
  body('agentAccuracy')
    .optional()
    .isDecimal().withMessage('Invalid accuracy value'),
  body('timestamp')
    .optional()
    .isISO8601().withMessage('Invalid timestamp format'),
  body('notes')
    .optional()
    .isString().withMessage('Notes must be a string'),
  validate
], deliveryBoyController.verifyDelivery);

/**
 * POST /api/delivery-boy/update-location
 * Update agent's current location (alternative endpoint)
 */
router.post('/update-location', [
  body('latitude')
    .notEmpty().withMessage('Latitude is required')
    .isDecimal().withMessage('Invalid latitude'),
  body('longitude')
    .notEmpty().withMessage('Longitude is required')
    .isDecimal().withMessage('Invalid longitude'),
  body('accuracy')
    .optional()
    .isDecimal().withMessage('Invalid accuracy value'),
  body('timestamp')
    .optional()
    .isISO8601().withMessage('Invalid timestamp format'),
  body('speed')
    .optional()
    .isDecimal().withMessage('Invalid speed value'),
  body('heading')
    .optional()
    .isDecimal().withMessage('Invalid heading value'),
  validate
], deliveryBoyController.updateLocation);

/**
 * GET /api/delivery-boy/config
 * Get delivery configuration including allowed radius
 */
router.get('/config', deliveryBoyController.getConfig);

/**
 * GET /api/delivery-boy/invoices
 * Get all invoices for the current delivery boy
 */
router.get('/invoices', [
  query('startDate').optional().isISO8601().withMessage('Invalid start date'),
  query('endDate').optional().isISO8601().withMessage('Invalid end date'),
  query('status').optional().isIn(['generated', 'submitted', 'approved', 'rejected', 'pending']),
  validate
], deliveryBoyController.getInvoices);

/**
 * GET /api/delivery-boy/invoices/:id
 * Get a specific invoice by ID
 */
router.get('/invoices/:id', [
  param('id').isUUID().withMessage('Invalid invoice ID'),
  validate
], deliveryBoyController.getInvoiceById);

/**
 * POST /api/delivery-boy/invoices/:id/submit
 * Submit an invoice for admin approval
 */
router.post('/invoices/:id/submit', [
  param('id').isUUID().withMessage('Invalid invoice ID'),
  validate
], deliveryBoyController.submitInvoice);

module.exports = router;

