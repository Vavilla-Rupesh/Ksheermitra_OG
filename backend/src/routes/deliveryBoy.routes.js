const express = require('express');
const router = express.Router();
const { body, param } = require('express-validator');
const deliveryBoyController = require('../controllers/deliveryBoy.controller');
const { authenticate, authorize } = require('../middleware/auth.middleware');
const validate = require('../middleware/validate.middleware');

router.use(authenticate);
router.use(authorize('delivery_boy'));

// Get my profile
router.get('/profile', deliveryBoyController.getMyProfile);

// Get assigned area with map details
router.get('/area', deliveryBoyController.getMyArea);

// Get delivery map with customer pins and statuses
router.get('/delivery-map', deliveryBoyController.getDeliveryMap);

// Get assigned customers with subscription details
router.get('/customers', deliveryBoyController.getAssignedCustomers);

// Get specific customer details with subscriptions
router.get('/customers/:customerId', [
  param('customerId').isUUID().withMessage('Invalid customer ID'),
  validate
], deliveryBoyController.getCustomerDetails);

// Get optimized route
router.get('/route', deliveryBoyController.getOptimizedRoute);

// Update delivery status for all customer deliveries
router.post(
  '/update-status',
  [
    body('customerId').notEmpty().isUUID().withMessage('Valid customer ID is required'),
    body('status').notEmpty().isIn(['delivered', 'missed']).withMessage('Status must be delivered or missed'),
    body('notes').optional().isString().withMessage('Notes must be a string'),
    validate
  ],
  deliveryBoyController.updateDeliveryStatus
);

// Update single delivery status
router.post(
  '/update-single-status',
  [
    body('deliveryId').notEmpty().isUUID().withMessage('Valid delivery ID is required'),
    body('status').notEmpty().isIn(['delivered', 'missed']).withMessage('Status must be delivered or missed'),
    body('notes').optional().isString().withMessage('Notes must be a string'),
    validate
  ],
  deliveryBoyController.updateSingleDeliveryStatus
);

// Get delivery statistics
router.get('/stats', deliveryBoyController.getDeliveryStats);

// Get today's summary
router.get('/summary', deliveryBoyController.getTodaysSummary);

// Update my current location
router.post(
  '/update-location',
  [
    body('latitude').notEmpty().isDecimal().withMessage('Valid latitude is required'),
    body('longitude').notEmpty().isDecimal().withMessage('Valid longitude is required'),
    validate
  ],
  deliveryBoyController.updateMyLocation
);

// Generate end-of-day invoice (sends to admin via WhatsApp)
router.post(
  '/generate-invoice',
  [
    body('date').optional().isDate().withMessage('Invalid date format'),
    validate
  ],
  deliveryBoyController.generateDailyInvoice
);

module.exports = router;
