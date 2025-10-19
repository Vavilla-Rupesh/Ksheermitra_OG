const express = require('express');
const router = express.Router();
const { body, param } = require('express-validator');
const customerController = require('../controllers/customer.controller');
const { authenticate, authorize } = require('../middleware/auth.middleware');
const validate = require('../middleware/validate.middleware');

router.use(authenticate);
router.use(authorize('customer'));

router.get('/profile', customerController.getProfile);

router.put(
  '/profile',
  [
    body('name').optional().isLength({ min: 2, max: 100 }).withMessage('Name must be between 2 and 100 characters'),
    body('email').optional().isEmail().withMessage('Invalid email format'),
    body('address').optional().isString(),
    body('latitude').optional().isDecimal().withMessage('Invalid latitude'),
    body('longitude').optional().isDecimal().withMessage('Invalid longitude'),
    validate
  ],
  customerController.updateProfile
);

router.post(
  '/subscriptions',
  [
    body('productId').notEmpty().isUUID().withMessage('Valid product ID is required'),
    body('quantity').notEmpty().isFloat({ min: 0.1 }).withMessage('Quantity must be greater than 0'),
    body('frequency').notEmpty().isIn(['daily', 'weekly', 'monthly', 'custom']).withMessage('Invalid frequency'),
    body('selectedDays').optional().isArray().withMessage('Selected days must be an array'),
    body('startDate').notEmpty().isDate().withMessage('Valid start date is required'),
    body('endDate').optional().isDate().withMessage('Invalid end date'),
    validate
  ],
  customerController.createSubscription
);

router.get('/subscriptions', customerController.getSubscriptions);

router.put(
  '/subscriptions/:id',
  [
    param('id').isUUID().withMessage('Invalid subscription ID'),
    body('quantity').optional().isFloat({ min: 0.1 }).withMessage('Quantity must be greater than 0'),
    body('status').optional().isIn(['active', 'paused', 'cancelled']).withMessage('Invalid status'),
    validate
  ],
  customerController.updateSubscription
);

router.post(
  '/subscriptions/:id/pause',
  [
    param('id').isUUID().withMessage('Invalid subscription ID'),
    body('pauseStartDate').notEmpty().isDate().withMessage('Valid pause start date is required'),
    body('pauseEndDate').notEmpty().isDate().withMessage('Valid pause end date is required'),
    validate
  ],
  customerController.pauseSubscription
);

router.post(
  '/subscriptions/:id/resume',
  [
    param('id').isUUID().withMessage('Invalid subscription ID'),
    validate
  ],
  customerController.resumeSubscription
);

router.get('/deliveries', customerController.getDeliveryHistory);

router.get('/invoices', customerController.getInvoices);

module.exports = router;
