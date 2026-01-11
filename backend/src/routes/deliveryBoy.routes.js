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
 * GET /api/delivery-boy/delivery-map
 * Fetch assigned delivery routes for navigation
 */
router.get('/delivery-map', [
  query('date').optional().isISO8601().withMessage('Invalid date format'),
  validate
], deliveryBoyController.getDeliveryMap);

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
    .isIn(['pending', 'in-progress', 'delivered', 'failed'])
    .withMessage('Status must be one of: pending, in-progress, delivered, failed'),
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

module.exports = router;

