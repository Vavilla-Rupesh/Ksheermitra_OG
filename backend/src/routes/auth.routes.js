const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const authController = require('../controllers/auth.controller');
const validate = require('../middleware/validate.middleware');

router.post(
  '/send-otp',
  [
    body('phone')
      .notEmpty()
      .withMessage('Phone number is required')
      .matches(/^\+?[1-9]\d{1,14}$/)
      .withMessage('Invalid phone number format'),
    validate
  ],
  authController.sendOTP
);

router.post(
  '/verify-otp',
  [
    body('phone')
      .notEmpty()
      .withMessage('Phone number is required')
      .matches(/^\+?[1-9]\d{1,14}$/)
      .withMessage('Invalid phone number format'),
    body('otp')
      .notEmpty()
      .withMessage('OTP is required')
      .isLength({ min: 6, max: 6 })
      .withMessage('OTP must be 6 digits'),
    validate
  ],
  authController.verifyOTP
);

router.post(
  '/register',
  [
    body('phone')
      .notEmpty()
      .withMessage('Phone number is required')
      .matches(/^\+?[1-9]\d{1,14}$/)
      .withMessage('Invalid phone number format'),
    body('name')
      .notEmpty()
      .withMessage('Name is required')
      .isLength({ min: 2, max: 100 })
      .withMessage('Name must be between 2 and 100 characters'),
    body('email')
      .optional()
      .isEmail()
      .withMessage('Invalid email format'),
    body('address')
      .optional()
      .isString(),
    body('latitude')
      .optional()
      .isDecimal()
      .withMessage('Invalid latitude'),
    body('longitude')
      .optional()
      .isDecimal()
      .withMessage('Invalid longitude'),
    body('otp')
      .notEmpty()
      .withMessage('OTP is required')
      .isLength({ min: 6, max: 6 })
      .withMessage('OTP must be 6 digits'),
    validate
  ],
  authController.register
);

router.post(
  '/refresh-token',
  [
    body('refreshToken')
      .notEmpty()
      .withMessage('Refresh token is required'),
    validate
  ],
  authController.refreshToken
);

router.post('/logout', authController.logout);

module.exports = router;
