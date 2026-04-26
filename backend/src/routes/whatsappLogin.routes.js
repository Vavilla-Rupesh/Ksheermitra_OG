const express = require('express');
const router = express.Router();
const whatsappLoginController = require('../controllers/whatsappLogin.controller');
const { basicAuthWhatsApp } = require('../middleware/whatsapp-auth.middleware');

/**
 * WhatsApp Admin QR Code Login Routes
 * These routes use Basic Authentication (username:password in Authorization header)
 */

// Get QR code for WhatsApp login
router.post('/get-qr', basicAuthWhatsApp, whatsappLoginController.getQRCode);

// Get current session status
router.get('/status', basicAuthWhatsApp, whatsappLoginController.getSessionStatus);

// Reset session and request new QR
router.post('/reset', basicAuthWhatsApp, whatsappLoginController.resetSession);

// Get detailed session info with expiration alert
router.get('/info', basicAuthWhatsApp, whatsappLoginController.getSessionInfo);

module.exports = router;

