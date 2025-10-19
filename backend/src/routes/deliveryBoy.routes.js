const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const deliveryBoyController = require('../controllers/deliveryBoy.controller');
const { authenticate, authorize } = require('../middleware/auth.middleware');
const validate = require('../middleware/validate.middleware');

router.use(authenticate);
router.use(authorize('delivery_boy'));

router.get('/customers', deliveryBoyController.getAssignedCustomers);

router.get('/route', deliveryBoyController.getOptimizedRoute);

router.put(
  '/delivery-status',
  [
    body('deliveryId').notEmpty().isUUID().withMessage('Valid delivery ID is required'),
    body('status').notEmpty().isIn(['delivered', 'missed']).withMessage('Status must be delivered or missed'),
    body('notes').optional().isString().withMessage('Notes must be a string'),
    validate
  ],
  deliveryBoyController.updateDeliveryStatus
);

router.get('/stats', deliveryBoyController.getDeliveryStats);

router.post(
  '/generate-invoice',
  [
    body('date').optional().isDate().withMessage('Invalid date format'),
    validate
  ],
  deliveryBoyController.generateDailyInvoice
);

module.exports = router;
