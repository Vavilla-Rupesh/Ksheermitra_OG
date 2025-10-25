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
    body('products').notEmpty().isArray({ min: 1 }).withMessage('At least one product is required'),
    body('products.*.productId').notEmpty().isUUID().withMessage('Valid product ID is required'),
    body('products.*.quantity').notEmpty().isFloat({ min: 0.1 }).withMessage('Quantity must be greater than 0'),
    body('frequency').notEmpty().isIn(['daily', 'weekly', 'monthly', 'custom', 'daterange']).withMessage('Invalid frequency'),
    body('selectedDays').optional().isArray().withMessage('Selected days must be an array'),
    body('startDate').notEmpty().isDate().withMessage('Valid start date is required'),
    body('endDate').optional().isDate().withMessage('Invalid end date'),
    body('autoRenewal').optional().isBoolean().withMessage('Invalid auto renewal value'),
    validate
  ],
  customerController.createSubscription
);

router.get('/subscriptions', customerController.getSubscriptions);

router.get('/subscriptions/:id',
  [param('id').isUUID().withMessage('Invalid subscription ID'), validate],
  customerController.getSubscriptionDetails
);

router.put(
  '/subscriptions/:id',
  [
    param('id').isUUID().withMessage('Invalid subscription ID'),
    body('products').optional().isArray().withMessage('Products must be an array'),
    body('products.*.productId').optional().isUUID().withMessage('Valid product ID is required'),
    body('products.*.quantity').optional().isFloat({ min: 0.1 }).withMessage('Quantity must be greater than 0'),
    body('frequency').optional().isIn(['daily', 'weekly', 'monthly', 'custom', 'daterange']).withMessage('Invalid frequency'),
    body('selectedDays').optional().isArray().withMessage('Selected days must be an array'),
    body('endDate').optional().isDate().withMessage('Invalid end date'),
    body('autoRenewal').optional().isBoolean().withMessage('Invalid auto renewal value'),
    validate
  ],
  customerController.updateSubscription
);

router.post(
  '/subscriptions/:id/products',
  [
    param('id').isUUID().withMessage('Invalid subscription ID'),
    body('products').notEmpty().isArray({ min: 1 }).withMessage('At least one product is required'),
    body('products.*.productId').notEmpty().isUUID().withMessage('Valid product ID is required'),
    body('products.*.quantity').notEmpty().isFloat({ min: 0.1 }).withMessage('Quantity must be greater than 0'),
    validate
  ],
  customerController.addProductsToSubscription
);

router.delete(
  '/subscriptions/:id/products/:productId',
  [
    param('id').isUUID().withMessage('Invalid subscription ID'),
    param('productId').isUUID().withMessage('Invalid product ID'),
    validate
  ],
  customerController.removeProductFromSubscription
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
  [param('id').isUUID().withMessage('Invalid subscription ID'), validate],
  customerController.resumeSubscription
);

router.post(
  '/subscriptions/:id/cancel',
  [param('id').isUUID().withMessage('Invalid subscription ID'), validate],
  customerController.cancelSubscription
);

router.post(
  '/subscriptions/:id/today',
  [
    param('id').isUUID().withMessage('Invalid subscription ID'),
    body('items').notEmpty().isArray({ min: 1 }).withMessage('At least one item is required'),
    body('items.*.productId').notEmpty().isUUID().withMessage('Valid product ID is required'),
    body('items.*.quantity').notEmpty().isFloat({ min: 0 }).withMessage('Quantity must be 0 or greater'),
    body('items.*.isOneTime').optional().isBoolean().withMessage('Invalid one-time flag'),
    validate
  ],
  customerController.updateTodayDelivery
);

router.get('/deliveries', customerController.getDeliveryHistory);
router.get('/invoices', customerController.getInvoices);
router.get('/products', customerController.getProducts);

// Monthly breakout routes
router.get(
  '/subscriptions/:id/monthly-breakout',
  [
    param('id').isUUID().withMessage('Invalid subscription ID'),
    validate
  ],
  customerController.getSubscriptionMonthlyBreakout
);

router.get(
  '/monthly-breakout/:year/:month',
  [
    param('year').isInt({ min: 2020, max: 2100 }).withMessage('Invalid year'),
    param('month').isInt({ min: 1, max: 12 }).withMessage('Invalid month'),
    validate
  ],
  customerController.getCustomerMonthlyBreakout
);

router.put(
  '/deliveries/:id/products',
  [
    param('id').isUUID().withMessage('Invalid delivery ID'),
    body('products').notEmpty().isArray({ min: 1 }).withMessage('At least one product is required'),
    body('products.*.productId').notEmpty().isUUID().withMessage('Valid product ID is required'),
    body('products.*.quantity').notEmpty().isFloat({ min: 0 }).withMessage('Quantity must be 0 or greater'),
    body('products.*.isOneTime').optional().isBoolean().withMessage('Invalid one-time flag'),
    validate
  ],
  customerController.modifyDeliveryProducts
);

router.post(
  '/monthly-invoice/:year/:month',
  [
    param('year').isInt({ min: 2020, max: 2100 }).withMessage('Invalid year'),
    param('month').isInt({ min: 1, max: 12 }).withMessage('Invalid month'),
    validate
  ],
  customerController.generateMonthlyInvoice
);

router.get(
  '/monthly-invoice/:year/:month',
  [
    param('year').isInt({ min: 2020, max: 2100 }).withMessage('Invalid year'),
    param('month').isInt({ min: 1, max: 12 }).withMessage('Invalid month'),
    validate
  ],
  customerController.getMonthlyInvoice
);

module.exports = router;
