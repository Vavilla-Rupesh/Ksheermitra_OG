const express = require('express');
const router = express.Router();
const { body, param } = require('express-validator');
const adminController = require('../controllers/admin.controller');
const { authenticate, authorize } = require('../middleware/auth.middleware');
const validate = require('../middleware/validate.middleware');
const upload = require('../middleware/upload.middleware');

router.use(authenticate);
router.use(authorize('admin'));

router.get('/customers', adminController.getCustomers);

router.get('/customers/map', adminController.getCustomersWithLocations);

router.post(
  '/customers',
  [
    body('name').notEmpty().isLength({ min: 2, max: 100 }).withMessage('Name must be between 2 and 100 characters'),
    body('phone').notEmpty().matches(/^\+?[1-9]\d{1,14}$/).withMessage('Invalid phone number format'),
    body('email').optional().isEmail().withMessage('Invalid email format'),
    body('address').optional().isString(),
    body('latitude').optional().isDecimal().withMessage('Invalid latitude'),
    body('longitude').optional().isDecimal().withMessage('Invalid longitude'),
    validate
  ],
  adminController.createCustomer
);

router.get('/customers/:id', [
  param('id').isUUID().withMessage('Invalid customer ID'),
  validate
], adminController.getCustomerDetails);

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

// New routes for enhanced delivery boy management
router.put(
  '/delivery-boys/:id',
  [
    param('id').isUUID().withMessage('Invalid delivery boy ID'),
    body('name').optional().isLength({ min: 2, max: 100 }).withMessage('Name must be between 2 and 100 characters'),
    body('phone').optional().matches(/^\+?[1-9]\d{1,14}$/).withMessage('Invalid phone number format'),
    body('email').optional().isEmail().withMessage('Invalid email format'),
    body('address').optional().isString(),
    body('latitude').optional().isDecimal().withMessage('Invalid latitude'),
    body('longitude').optional().isDecimal().withMessage('Invalid longitude'),
    body('isActive').optional().isBoolean().withMessage('isActive must be a boolean'),
    validate
  ],
  adminController.updateDeliveryBoy
);

router.get('/delivery-boys/:id', [
  param('id').isUUID().withMessage('Invalid delivery boy ID'),
  validate
], adminController.getDeliveryBoyDetails);

// Area assignment with Google Maps
router.post(
  '/assign-area-with-map',
  [
    body('areaId').notEmpty().isUUID().withMessage('Valid area ID is required'),
    body('deliveryBoyId').notEmpty().isUUID().withMessage('Valid delivery boy ID is required'),
    body('boundaries').optional().isArray().withMessage('Boundaries must be an array'),
    body('centerLatitude').optional().isDecimal().withMessage('Invalid center latitude'),
    body('centerLongitude').optional().isDecimal().withMessage('Invalid center longitude'),
    body('mapLink').optional().isString(),
    validate
  ],
  adminController.assignAreaWithMap
);

router.put(
  '/areas/:id/boundaries',
  [
    param('id').isUUID().withMessage('Invalid area ID'),
    body('boundaries').optional().isArray().withMessage('Boundaries must be an array'),
    body('centerLatitude').optional().isDecimal().withMessage('Invalid center latitude'),
    body('centerLongitude').optional().isDecimal().withMessage('Invalid center longitude'),
    body('mapLink').optional().isString(),
    validate
  ],
  adminController.updateAreaBoundaries
);

router.get('/areas/:id/customers', [
  param('id').isUUID().withMessage('Invalid area ID'),
  validate
], adminController.getAreaWithCustomers);

router.put(
  '/areas/:id/customers',
  [
    param('id').isUUID().withMessage('Invalid area ID'),
    body('customerIds').isArray().withMessage('Customer IDs must be an array'),
    validate
  ],
  adminController.updateAreaCustomers
);

router.get('/areas', adminController.getAreas);

router.post(
  '/areas',
  [
    body('name').notEmpty().isLength({ min: 2, max: 100 }).withMessage('Name must be between 2 and 100 characters'),
    body('description').optional().isString(),
    body('boundaries').optional().isArray().withMessage('Boundaries must be an array'),
    body('centerLatitude').optional().isDecimal().withMessage('Invalid center latitude'),
    body('centerLongitude').optional().isDecimal().withMessage('Invalid center longitude'),
    body('mapLink').optional().isString(),
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
    body('boundaries').optional().isArray().withMessage('Boundaries must be an array'),
    body('centerLatitude').optional().isDecimal().withMessage('Invalid center latitude'),
    body('centerLongitude').optional().isDecimal().withMessage('Invalid center longitude'),
    body('mapLink').optional().isString(),
    body('isActive').optional().isBoolean(),
    body('deliveryBoyId').optional().isUUID().withMessage('Invalid delivery boy ID'),
    validate
  ],
  adminController.updateArea
);

router.delete(
  '/areas/:id',
  [
    param('id').isUUID().withMessage('Invalid area ID'),
    validate
  ],
  adminController.deleteArea
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
    body('customerIds').isArray().withMessage('Customer IDs must be an array'),
    body('areaId').notEmpty().isUUID().withMessage('Valid area ID is required'),
    validate
  ],
  adminController.bulkAssignArea
);

router.get('/dashboard/stats', adminController.getDashboardStats);

router.get('/products', adminController.getProducts);

router.post('/products', upload.single('image'), adminController.createProduct);

router.put('/products/:id', upload.single('image'), adminController.updateProduct);

router.get('/invoices/daily', adminController.getDailyInvoices);

router.get('/invoices/monthly', adminController.getMonthlyInvoices);

router.put('/invoices/:id/payment', [
  param('id').isUUID().withMessage('Invalid invoice ID'),
  validate
], adminController.updateInvoicePaymentStatus);

// WhatsApp management routes
router.get('/whatsapp/status', adminController.getWhatsAppStatus);
router.post('/whatsapp/reset', adminController.resetWhatsAppSession);

// Offline Sales (In-Store) routes
router.post('/offline-sales', [
  body('items').isArray({ min: 1 }).withMessage('At least one item is required'),
  body('items.*.productId').isUUID().withMessage('Valid product ID is required'),
  body('items.*.quantity').isInt({ min: 1 }).withMessage('Quantity must be at least 1'),
  body('customerName').optional({ nullable: true }).isLength({ min: 2, max: 100 }).withMessage('Customer name must be between 2 and 100 characters'),
  body('customerPhone').optional({ nullable: true }).matches(/^\+?[1-9]\d{1,14}$/).withMessage('Invalid phone number format'),
  body('paymentMethod').optional({ nullable: true }).isIn(['cash', 'card', 'upi', 'other']).withMessage('Invalid payment method'),
  body('notes').optional({ nullable: true }).isString(),
  validate
], adminController.createOfflineSale);

router.get('/offline-sales', adminController.getOfflineSales);

router.get('/offline-sales/stats', adminController.getOfflineSalesStats);

router.get('/offline-sales/:id', [
  param('id').isUUID().withMessage('Invalid sale ID'),
  validate
], adminController.getOfflineSaleById);

router.get('/invoices/admin-daily', adminController.getAdminDailyInvoice);

// Invoice Management Routes
router.get('/invoices/pending', adminController.getPendingInvoices);

router.get('/invoices/delivery-boy/:deliveryBoyId', [
  param('deliveryBoyId').isUUID().withMessage('Invalid delivery boy ID'),
  validate
], adminController.getDeliveryBoyInvoices);

router.post('/invoices/:id/approve', [
  param('id').isUUID().withMessage('Invalid invoice ID'),
  validate
], adminController.approveInvoice);

router.post('/invoices/:id/reject', [
  param('id').isUUID().withMessage('Invalid invoice ID'),
  body('reason').notEmpty().withMessage('Rejection reason is required'),
  validate
], adminController.rejectInvoice);

module.exports = router;
