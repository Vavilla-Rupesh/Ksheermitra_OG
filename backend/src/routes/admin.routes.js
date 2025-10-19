const express = require('express');
const router = express.Router();
const { body, param } = require('express-validator');
const adminController = require('../controllers/admin.controller');
const { authenticate, authorize } = require('../middleware/auth.middleware');
const validate = require('../middleware/validate.middleware');

router.use(authenticate);
router.use(authorize('admin'));

router.get('/customers', adminController.getCustomers);

router.get('/customers/map', adminController.getCustomersWithLocations);

router.get('/delivery-boys', adminController.getDeliveryBoys);

router.post(
  '/delivery-boys',
  [
    body('name').notEmpty().isLength({ min: 2, max: 100 }).withMessage('Name must be between 2 and 100 characters'),
    body('phone').notEmpty().matches(/^\+?[1-9]\d{1,14}$/).withMessage('Invalid phone number format'),
    body('email').optional().isEmail().withMessage('Invalid email format'),
    body('address').optional().isString(),
    body('latitude').optional().isDecimal().withMessage('Invalid latitude'),
    body('longitude').optional().isDecimal().withMessage('Invalid longitude'),
    validate
  ],
  adminController.createDeliveryBoy
);

router.post(
  '/assign-area',
  [
    body('customerId').notEmpty().isUUID().withMessage('Valid customer ID is required'),
    body('areaId').notEmpty().isUUID().withMessage('Valid area ID is required'),
    validate
  ],
  adminController.assignArea
);

router.post(
  '/bulk-assign-area',
  [
    body('customerIds').notEmpty().isArray({ min: 1 }).withMessage('Customer IDs must be a non-empty array'),
    body('areaId').notEmpty().isUUID().withMessage('Valid area ID is required'),
    validate
  ],
  adminController.bulkAssignArea
);

router.get('/areas', adminController.getAreas);

router.post(
  '/areas',
  [
    body('name').notEmpty().isLength({ min: 2, max: 100 }).withMessage('Name must be between 2 and 100 characters'),
    body('description').optional().isString(),
    body('deliveryBoyId').optional().isUUID().withMessage('Invalid delivery boy ID'),
    validate
  ],
  adminController.createArea
);

router.put(
  '/areas/:id',
  [
    param('id').isUUID().withMessage('Invalid area ID'),
    body('name').optional().isLength({ min: 2, max: 100 }).withMessage('Name must be between 2 and 100 characters'),
    body('description').optional().isString(),
    body('deliveryBoyId').optional().isUUID().withMessage('Invalid delivery boy ID'),
    body('isActive').optional().isBoolean().withMessage('isActive must be a boolean'),
    validate
  ],
  adminController.updateArea
);

router.get('/invoices/daily', adminController.getDailyInvoices);

router.get('/products', adminController.getProducts);

router.post(
  '/products',
  [
    body('name').notEmpty().isLength({ min: 2, max: 100 }).withMessage('Name must be between 2 and 100 characters'),
    body('description').optional().isString(),
    body('unit').notEmpty().isIn(['liter', 'ml', 'kg', 'gm', 'piece']).withMessage('Invalid unit'),
    body('pricePerUnit').notEmpty().isFloat({ min: 0 }).withMessage('Price per unit must be greater than 0'),
    body('stock').optional().isInt({ min: 0 }).withMessage('Stock must be a non-negative integer'),
    validate
  ],
  adminController.createProduct
);

router.put(
  '/products/:id',
  [
    param('id').isUUID().withMessage('Invalid product ID'),
    body('name').optional().isLength({ min: 2, max: 100 }).withMessage('Name must be between 2 and 100 characters'),
    body('description').optional().isString(),
    body('unit').optional().isIn(['liter', 'ml', 'kg', 'gm', 'piece']).withMessage('Invalid unit'),
    body('pricePerUnit').optional().isFloat({ min: 0 }).withMessage('Price per unit must be greater than 0'),
    body('stock').optional().isInt({ min: 0 }).withMessage('Stock must be a non-negative integer'),
    body('isActive').optional().isBoolean().withMessage('isActive must be a boolean'),
    validate
  ],
  adminController.updateProduct
);

module.exports = router;
