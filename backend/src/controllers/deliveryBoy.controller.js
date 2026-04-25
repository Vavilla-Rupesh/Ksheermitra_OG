const db = require('../config/db');
const logger = require('../utils/logger');
const mapsService = require('../services/maps.service');
const { Op } = require('sequelize');

class DeliveryBoyController {
  /**
   * GET /api/delivery-boy/delivery-map
   * Fetch assigned delivery area with customers and real-time delivery status
   */
  async getDeliveryMap(req, res, next) {
    try {
      const deliveryBoyId = req.user.id;
      const { date } = req.query;

      // Default to today if no date provided - use YYYY-MM-DD string for DATEONLY
      const now = new Date();
      const deliveryDate = date || `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;

      // Get delivery boy with assigned area
      // First get the delivery boy and area
      const deliveryBoy = await db.User.findByPk(deliveryBoyId, {
        attributes: ['id', 'name', 'phone', 'email', 'latitude', 'longitude'],
        include: [{
          model: db.Area,
          as: 'assignedArea',
          attributes: ['id', 'name', 'description', 'boundaries', 'centerLatitude', 'centerLongitude', 'mapLink', 'isActive']
        }]
      });

      if (!deliveryBoy || !deliveryBoy.assignedArea) {
        return res.status(404).json({
          success: true,
          message: 'No area assigned yet',
          data: {
            area: null,
            customers: []
          }
        });
      }

      const area = deliveryBoy.assignedArea;

      // Verify area is active
      if (!area.isActive) {
        return res.status(404).json({
          success: true,
          message: 'Assigned area is inactive',
          data: {
            area: null,
            customers: []
          }
        });
      }

      // Get all customers in the assigned area with their active subscriptions
      // Using separate query to avoid LEFT JOIN filtering issues
      const areaCustomers = await db.User.findAll({
        where: {
          areaId: area.id,
          isActive: true,
          role: 'customer'
        },
        attributes: ['id', 'name', 'phone', 'address', 'latitude', 'longitude', 'areaId'],
        include: [{
          model: db.Subscription,
          as: 'subscriptions',
          attributes: ['id', 'frequency', 'status', 'startDate'],
          where: { status: 'active' },
          required: false,
          include: [{
            model: db.SubscriptionProduct,
            as: 'products',
            attributes: ['id', 'quantity', 'productId'],
            required: false,
            include: [{
              model: db.Product,
              as: 'product',
              attributes: ['id', 'name', 'unit', 'pricePerUnit', 'imageUrl'],
              required: false
            }]
          }]
        }]
      });

      logger.info(`Delivery map - Area: ${area.id}, Found ${areaCustomers.length} customers in area`);

      // Auto-create delivery records for customers with active subscriptions but no delivery for today
      for (const customer of areaCustomers) {
        if (!customer.subscriptions || customer.subscriptions.length === 0) continue;

        // Check if a delivery already exists for this customer today
        const existingDelivery = await db.Delivery.findOne({
          where: {
            customerId: customer.id,
            deliveryBoyId,
            deliveryDate
          }
        });

        if (!existingDelivery) {
          // Create delivery for each active subscription
          for (const subscription of customer.subscriptions) {
            if (subscription.status !== 'active') continue;

            // Calculate total amount from subscription products
            let totalAmount = 0;
            const products = subscription.products || [];
            for (const sp of products) {
              const quantity = parseFloat(sp.quantity || 0);
              const pricePerUnit = sp.product ? parseFloat(sp.product.pricePerUnit || 0) : 0;
              totalAmount += quantity * pricePerUnit;
            }

            if (totalAmount <= 0) continue;

            try {
              const delivery = await db.Delivery.create({
                customerId: customer.id,
                deliveryBoyId,
                subscriptionId: subscription.id,
                productId: products.length > 0 ? products[0].productId : null,
                deliveryDate,
                quantity: products.length > 0 ? products[0].quantity : 0,
                amount: totalAmount,
                status: 'pending'
              });

              // Create delivery items for each product
              for (const sp of products) {
                const quantity = parseFloat(sp.quantity || 0);
                const pricePerUnit = sp.product ? parseFloat(sp.product.pricePerUnit || 0) : 0;
                await db.DeliveryItem.create({
                  deliveryId: delivery.id,
                  productId: sp.productId,
                  quantity: quantity,
                  price: quantity * pricePerUnit,
                  isOneTime: false
                });
              }

              logger.info(`Auto-created delivery ${delivery.id} for customer ${customer.id} on ${deliveryDate}`);
            } catch (createError) {
              logger.error(`Error auto-creating delivery for customer ${customer.id}:`, createError);
            }
          }
        }
      }

      const deliveries = await db.Delivery.findAll({
        where: {
          deliveryBoyId,
          deliveryDate,
          status: {
            [Op.in]: ['pending', 'in-progress', 'delivered', 'missed']
          }
        },
        attributes: ['id', 'customerId', 'status', 'amount'],
        raw: true
      });

      // Create a map of customer deliveries for quick lookup
      const deliveryMap = {};
      let totalTodayAmount = 0;

      deliveries.forEach(delivery => {
        if (!deliveryMap[delivery.customerId]) {
          deliveryMap[delivery.customerId] = [];
        }
        deliveryMap[delivery.customerId].push({
          deliveryId: delivery.id,
          status: delivery.status,
          amount: delivery.amount ? parseFloat(delivery.amount) : 0
        });
        if (delivery.status === 'delivered') {
          totalTodayAmount += delivery.amount ? parseFloat(delivery.amount) : 0;
        }
      });

      // Format customers with delivery status and today's subscriptions
      const customers = (areaCustomers || []).map(customer => {
        const customerDeliveries = deliveryMap[customer.id] || [];

        // Determine delivery status (prioritize: delivered, missed, in-progress, pending)
        let deliveryStatus = 'pending';
        let activeDeliveryId = null;
        if (customerDeliveries.some(d => d.status === 'delivered')) {
          deliveryStatus = 'delivered';
          const deliveredEntry = customerDeliveries.find(d => d.status === 'delivered');
          activeDeliveryId = deliveredEntry ? deliveredEntry.deliveryId : null;
        } else if (customerDeliveries.some(d => d.status === 'missed')) {
          deliveryStatus = 'missed';
          const missedEntry = customerDeliveries.find(d => d.status === 'missed');
          activeDeliveryId = missedEntry ? missedEntry.deliveryId : null;
        } else if (customerDeliveries.some(d => d.status === 'in-progress')) {
          deliveryStatus = 'in-progress';
          const inProgressEntry = customerDeliveries.find(d => d.status === 'in-progress');
          activeDeliveryId = inProgressEntry ? inProgressEntry.deliveryId : null;
        } else if (customerDeliveries.length > 0) {
          const pendingEntry = customerDeliveries.find(d => d.status === 'pending');
          activeDeliveryId = pendingEntry ? pendingEntry.deliveryId : customerDeliveries[0].deliveryId;
        }

        // Calculate today's amount
        const todayAmount = customerDeliveries.reduce((sum, d) => sum + d.amount, 0);

        return {
          id: customer.id,
          deliveryId: activeDeliveryId,
          name: customer.name,
          phone: customer.phone,
          address: customer.address,
          latitude: customer.latitude ? parseFloat(customer.latitude) : null,
          longitude: customer.longitude ? parseFloat(customer.longitude) : null,
          deliveryStatus,
          todayAmount,
          subscriptions: (customer.subscriptions || []).map(sub => ({
            id: sub.id,
            frequency: sub.frequency,
            status: sub.status,
            startDate: sub.startDate,
            products: (sub.products || []).map(sp => ({
              id: sp.id,
              quantity: parseFloat(sp.quantity),
              product: sp.product ? {
                id: sp.product.id,
                name: sp.product.name,
                unit: sp.product.unit,
                pricePerUnit: parseFloat(sp.product.pricePerUnit),
                imageUrl: sp.product.imageUrl
              } : null
            }))
          }))
        };
      });

      // Format area boundaries
      const formattedArea = {
        id: area.id,
        name: area.name,
        description: area.description,
        boundaries: area.boundaries || [],
        centerLatitude: area.centerLatitude ? parseFloat(area.centerLatitude) : null,
        centerLongitude: area.centerLongitude ? parseFloat(area.centerLongitude) : null,
        mapLink: area.mapLink,
        deliveryBoyId: area.deliveryBoyId
      };

      res.status(200).json({
        success: true,
        data: {
          date: deliveryDate,
          currentLocation: deliveryBoy.latitude && deliveryBoy.longitude ? {
            latitude: parseFloat(deliveryBoy.latitude),
            longitude: parseFloat(deliveryBoy.longitude)
          } : null,
          area: formattedArea,
          customers: customers,
          totalCustomers: customers.length,
          deliveryStats: {
            total: customers.length,
            completed: customers.filter(c => c.deliveryStatus === 'delivered').length,
            pending: customers.filter(c => c.deliveryStatus === 'pending').length,
            inProgress: customers.filter(c => c.deliveryStatus === 'in-progress').length,
            missed: customers.filter(c => c.deliveryStatus === 'missed').length,
            totalAmount: totalTodayAmount
          }
        }
      });
    } catch (error) {
      logger.error('Error getting delivery map:', error);
      next(error);
    }
  }

  /**
   * GET /api/delivery-boy/daily-summary
   * Fetch daily summary of deliveries for invoice generation
   */
  async dailySummary(req, res, next) {
    try {
      const deliveryBoyId = req.user.id;
      const { date } = req.query;

      // Default to today if no date provided - use YYYY-MM-DD string for DATEONLY
      const now = new Date();
      const summaryDateStr = date || `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;
      const summaryDate = new Date(summaryDateStr + 'T00:00:00');

      // Get delivery boy details
      const deliveryBoy = await db.User.findByPk(deliveryBoyId, {
        attributes: ['id', 'name', 'phone', 'email']
      });

      if (!deliveryBoy) {
        return res.status(404).json({
          success: false,
          message: 'Delivery boy not found'
        });
      }

      // Fetch all deliveries for the date (all statuses for summary)
      const deliveries = await db.Delivery.findAll({
        where: {
          deliveryBoyId,
          deliveryDate: summaryDateStr
        },
        include: [
          {
            model: db.User,
            as: 'customer',
            attributes: ['id', 'name', 'phone', 'address']
          },
          {
            model: db.DeliveryItem,
            as: 'items',
            include: [{
              model: db.Product,
              as: 'product',
              attributes: ['id', 'name', 'unit']
            }]
          }
        ],
        order: [['createdAt', 'ASC']]
      });

      // Format deliveries data for invoice generation
      const formattedDeliveries = deliveries.map(delivery => {
        const products = delivery.items
          .map(item => `${item.product?.name || 'Product'} ${item.quantity}${item.product?.unit || ''}`)
          .join(', ') || 'N/A';

        return {
          id: delivery.id,
          customerName: delivery.customer?.name || 'Unknown',
          customerPhone: delivery.customer?.phone || 'N/A',
          customerAddress: delivery.customer?.address || 'N/A',
          products,
          amount: parseFloat(delivery.amount || 0),
          collected: delivery.paymentMode === 'cash' && delivery.status === 'delivered' ? parseFloat(delivery.amount || 0) : 0,
          paymentMode: delivery.paymentMode || 'pending',
          status: delivery.status || 'pending',
          time: delivery.deliveredAt ? new Date(delivery.deliveredAt).toLocaleTimeString('en-IN', {
            hour: '2-digit',
            minute: '2-digit',
            hour12: true
          }) : '-',
          deliveredAt: delivery.deliveredAt
        };
      });

      // Calculate totals
      const totalAmount = formattedDeliveries.reduce((sum, d) => sum + d.amount, 0);
      const totalCollected = formattedDeliveries.reduce((sum, d) => sum + d.collected, 0);
      const deliveredCount = deliveries.filter(d => d.status === 'delivered').length;

      logger.info(`Daily summary - Delivery boy: ${deliveryBoyId}, Date: ${summaryDateStr}, Total deliveries: ${deliveries.length}`);

      res.status(200).json({
        success: true,
        data: {
          date: summaryDateStr,
          deliveryBoyId,
          deliveryBoyName: deliveryBoy.name,
          deliveryBoyPhone: deliveryBoy.phone,
          deliveries: formattedDeliveries,
          summary: {
            totalDeliveries: deliveries.length,
            completedDeliveries: deliveredCount,
            pendingDeliveries: deliveries.length - deliveredCount,
            totalAmount: parseFloat(totalAmount.toFixed(2)),
            totalCollected: parseFloat(totalCollected.toFixed(2)),
            pending: parseFloat((totalAmount - totalCollected).toFixed(2))
          }
        }
      });
    } catch (error) {
      logger.error('Error getting daily summary:', error);
      next(error);
    }
  }

  /**
   * POST /api/delivery-boy/generate-invoice
   * Generate daily invoice for completed deliveries with PDF and WhatsApp notification
   */
  async generateInvoice(req, res, next) {
    try {
      const deliveryBoyId = req.user.id;
      const { date } = req.body;

      if (!date) {
        return res.status(400).json({
          success: false,
          message: 'Date is required'
        });
      }

      const invoiceDate = date; // Keep as 'YYYY-MM-DD' string for DATEONLY comparison

      // Check if invoice already exists for this date
      const existingInvoice = await db.Invoice.findOne({
        where: {
          deliveryBoyId,
          invoiceDate,
          invoiceType: 'delivery_boy_daily'
        }
      });

      if (existingInvoice) {
        const fs = require('fs');
        const pdfExists = existingInvoice.pdfPath && fs.existsSync(existingInvoice.pdfPath);

        // If PDF was already generated and file exists, resend via WhatsApp and return
        if (pdfExists) {
          logger.info(`Invoice already exists with valid PDF: ${existingInvoice.invoiceNumber}`);

          // Fire-and-forget WhatsApp send so HTTP response is immediate
          const adminPhone = process.env.ADMIN_WHATSAPP_NUMBER || process.env.ADMIN_PHONE || process.env.COMPANY_PHONE;
          if (adminPhone && adminPhone !== '+91-XXXXXXXXXX') {
            this._sendInvoiceViaWhatsApp(existingInvoice, deliveryBoyId, adminPhone, invoiceDate)
              .catch(err => logger.error('[BG] Existing invoice WhatsApp send failed:', err.message || err.error || 'unknown'));
          }

          return res.status(200).json({
            success: true,
            message: 'Invoice already exists',
            data: {
              invoiceId: existingInvoice.id,
              invoiceNumber: existingInvoice.invoiceNumber,
              totalDeliveries: existingInvoice.metadata?.totalDeliveries || 0,
              totalAmount: parseFloat(existingInvoice.totalAmount),
              generatedAt: existingInvoice.createdAt,
              status: existingInvoice.status,
              pdfGenerated: true,
              whatsappNotificationSent: true
            }
          });
        }

        // PDF is missing - regenerate it and send via WhatsApp
        logger.info(`Invoice ${existingInvoice.invoiceNumber} exists but PDF is missing. Regenerating...`);

        try {
          const pdfService = require('../services/pdf.service');
          const deliveryBoy = await db.User.findByPk(deliveryBoyId, {
            attributes: ['id', 'name', 'phone']
          });

          // Build PDF data from stored metadata
          const storedDeliveries = existingInvoice.metadata?.deliveries || [];
          const pdfDeliveries = storedDeliveries.map(d => {
            const items = d.items || [];
            return {
              customerName: d.customerName || 'N/A',
              productName: items.length > 0 ? items.map(i => i.productName || 'Product').join(', ') : (d.productName || 'N/A'),
              quantity: items.length > 0 ? items.reduce((sum, i) => sum + (parseFloat(i.quantity) || 0), 0) : (parseFloat(d.quantity) || 0),
              unit: (items[0]?.unit) || d.unit || '',
              amount: parseFloat(d.amount) || 0
            };
          });

          const invoiceDateForDisplay = new Date(invoiceDate + 'T00:00:00').toLocaleDateString('en-IN');
          const pdfData = {
            invoiceNumber: existingInvoice.invoiceNumber,
            deliveryBoy: {
              name: deliveryBoy?.name || 'Delivery Boy',
              phone: deliveryBoy?.phone || 'N/A'
            },
            date: invoiceDateForDisplay,
            deliveries: pdfDeliveries,
            totalAmount: parseFloat(existingInvoice.totalAmount)
          };

          const newPdfPath = await pdfService.generateDailyInvoice(pdfData);

          if (newPdfPath && fs.existsSync(newPdfPath)) {
            existingInvoice.pdfPath = newPdfPath;
            await existingInvoice.save();
            logger.info(`PDF regenerated for existing invoice: ${newPdfPath}`);

            // Send via WhatsApp in background (fire-and-forget)
            const adminPhone = process.env.ADMIN_WHATSAPP_NUMBER || process.env.ADMIN_PHONE || process.env.COMPANY_PHONE;
            if (adminPhone && adminPhone !== '+91-XXXXXXXXXX') {
              this._sendInvoiceViaWhatsApp(existingInvoice, deliveryBoyId, adminPhone, invoiceDate)
                .catch(err => logger.error('[BG] Regen WhatsApp send failed:', err.message || err.error || 'unknown'));
            }

            return res.status(200).json({
              success: true,
              message: 'Invoice PDF regenerated successfully',
              data: {
                invoiceId: existingInvoice.id,
                invoiceNumber: existingInvoice.invoiceNumber,
                totalDeliveries: existingInvoice.metadata?.totalDeliveries || storedDeliveries.length,
                totalAmount: parseFloat(existingInvoice.totalAmount),
                generatedAt: existingInvoice.createdAt,
                status: existingInvoice.status,
                pdfGenerated: true,
                whatsappNotificationSent: true
              }
            });
          }
        } catch (regenError) {
          logger.error('Error regenerating PDF for existing invoice:', regenError.message, regenError.stack);
        }

        // If regeneration failed, still return the existing invoice data
        return res.status(200).json({
          success: true,
          message: 'Invoice exists but PDF generation failed',
          data: {
            invoiceId: existingInvoice.id,
            invoiceNumber: existingInvoice.invoiceNumber,
            totalDeliveries: existingInvoice.metadata?.totalDeliveries || 0,
            totalAmount: parseFloat(existingInvoice.totalAmount),
            generatedAt: existingInvoice.createdAt,
            status: existingInvoice.status,
            pdfGenerated: false,
            whatsappNotificationSent: false
          }
        });
      }

      // Fetch delivery boy details for invoice
      const deliveryBoy = await db.User.findByPk(deliveryBoyId, {
        attributes: ['id', 'name', 'phone']
      });

      if (!deliveryBoy) {
        return res.status(404).json({
          success: false,
          message: 'Delivery boy not found'
        });
      }

      // Fetch all completed deliveries for the date
      const completedDeliveries = await db.Delivery.findAll({
        where: {
          deliveryBoyId,
          deliveryDate: invoiceDate,
          status: 'delivered'
        },
        include: [
          {
            model: db.User,
            as: 'customer',
            attributes: ['name', 'phone', 'address']
          },
          {
            model: db.DeliveryItem,
            as: 'items',
            include: [{
              model: db.Product,
              as: 'product',
              attributes: ['name', 'unit']
            }]
          }
        ]
      });

      if (completedDeliveries.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'No completed deliveries found for this date'
        });
      }

      // Calculate total amount
      const totalAmount = completedDeliveries.reduce((sum, delivery) => {
        return sum + parseFloat(delivery.amount || 0);
      }, 0);

      // Generate invoice number
      const dateParts = invoiceDate.split('-'); // 'YYYY-MM-DD'
      const invoiceNumber = `INV-DB-${dateParts[0]}${dateParts[1]}${dateParts[2]}-${deliveryBoyId.substring(0, 8).toUpperCase()}`;

      // Format delivery details for PDF and metadata
      const deliveryDetails = completedDeliveries.map(d => ({
        deliveryId: d.id,
        customerName: d.customer?.name || 'N/A',
        customerPhone: d.customer?.phone || 'N/A',
        customerAddress: d.customer?.address || 'N/A',
        amount: parseFloat(d.amount || 0),
        items: (d.items || []).map(item => ({
          productName: item.product?.name || 'Product',
          quantity: parseFloat(item.quantity || 0),
          unit: item.product?.unit || '',
          price: parseFloat(item.price || 0)
        }))
      }));

      // Generate PDF invoice
      const pdfService = require('../services/pdf.service');
      const invoiceDateForDisplay = new Date(invoiceDate + 'T00:00:00').toLocaleDateString('en-IN');

      // Prepare deliveries data for PDF - handle cases where items might be empty
      const pdfDeliveries = deliveryDetails.map(d => {
        const items = d.items || [];
        return {
          customerName: d.customerName || 'N/A',
          productName: items.length > 0 ? items.map(i => i.productName || 'Product').join(', ') : 'N/A',
          quantity: items.length > 0 ? items.reduce((sum, i) => sum + (parseFloat(i.quantity) || 0), 0) : 0,
          unit: (items[0]?.unit) || '',
          amount: parseFloat(d.amount) || 0
        };
      });

      const pdfData = {
        invoiceNumber,
        deliveryBoy: {
          name: deliveryBoy.name || 'Delivery Boy',
          phone: deliveryBoy.phone || 'N/A'
        },
        date: invoiceDateForDisplay,
        deliveries: pdfDeliveries,
        totalAmount
      };

      logger.info(`PDF data prepared: ${JSON.stringify({ invoiceNumber, deliveriesCount: pdfDeliveries.length, totalAmount })}`);

      let pdfPath = null;
      try {
        pdfPath = await pdfService.generateDailyInvoice(pdfData);
        // Verify the file exists
        const fs = require('fs');
        if (pdfPath && fs.existsSync(pdfPath)) {
          logger.info(`PDF generated successfully at: ${pdfPath}`);
        } else {
          logger.error(`PDF path returned but file does not exist: ${pdfPath}`);
          pdfPath = null;
        }
      } catch (pdfError) {
        logger.error('Error generating PDF invoice:', pdfError.message, pdfError.stack);
        pdfPath = null;
      }

      // Create invoice in database
      const invoice = await db.Invoice.create({
        invoiceNumber,
        invoiceType: 'delivery_boy_daily',
        deliveryBoyId,
        customerId: null,
        invoiceDate,
        totalAmount,
        pdfPath: pdfPath || null,
        status: 'generated',
        metadata: {
          totalDeliveries: completedDeliveries.length,
          deliveries: deliveryDetails
        }
      });

      // Send WhatsApp notification + PDF to admin (fire-and-forget, don't block response)
      const adminPhone = process.env.ADMIN_WHATSAPP_NUMBER || process.env.ADMIN_PHONE || process.env.COMPANY_PHONE;
      if (adminPhone && adminPhone !== '+91-XXXXXXXXXX' && pdfPath) {
        // Fire and forget
        this._sendNewInvoiceViaWhatsApp(invoice, deliveryBoy, completedDeliveries, deliveryDetails, adminPhone, invoiceDate, pdfPath, invoiceNumber)
          .catch(err => logger.error('Background WhatsApp send failed:', err.message || err.error || 'unknown'));
      }

      logger.info(`Invoice ${invoiceNumber} generated successfully for delivery boy ${deliveryBoyId}`);

      res.status(201).json({
        success: true,
        message: 'Invoice generated successfully',
        data: {
          invoiceId: invoice.id,
          invoiceNumber: invoice.invoiceNumber,
          totalDeliveries: completedDeliveries.length,
          totalAmount: parseFloat(totalAmount.toFixed(2)),
          status: invoice.status,
          generatedAt: invoice.createdAt,
          pdfGenerated: !!pdfPath,
          whatsappNotificationSent: !!(adminPhone && adminPhone !== '+91-XXXXXXXXXX')
        }
      });
    } catch (error) {
      logger.error('Error generating invoice:', error);
      next(error);
    }
  }

  /**
   * Background helper: Send existing invoice text + PDF to admin via WhatsApp
   */
  async _sendInvoiceViaWhatsApp(existingInvoice, deliveryBoyId, adminPhone, invoiceDate) {
    try {
      const whatsappService = require('../services/whatsapp.service');
      const WhatsAppTemplates = require('../templates/whatsapp-templates');

      const deliveryBoy = await db.User.findByPk(deliveryBoyId, { attributes: ['id', 'name', 'phone'] });
      const storedDeliveries = existingInvoice.metadata?.deliveries || [];
      const invoiceDateForDisplay = new Date(invoiceDate + 'T00:00:00').toLocaleDateString('en-IN');

      logger.info(`[BG] Sending invoice ${existingInvoice.invoiceNumber} to admin ${adminPhone}`);

      const invoiceMessage = WhatsAppTemplates.generateInvoiceMessage({
        customerName: deliveryBoy?.name || 'Delivery Boy',
        invoiceNumber: existingInvoice.invoiceNumber,
        totalDeliveries: existingInvoice.metadata?.totalDeliveries || storedDeliveries.length,
        totalAmount: parseFloat(existingInvoice.totalAmount).toFixed(2),
        date: invoiceDateForDisplay,
        deliveries: storedDeliveries
      });

      await whatsappService.sendMessage(adminPhone, invoiceMessage);
      logger.info('[BG] Invoice text sent to admin');

      if (existingInvoice.pdfPath) {
        const fs = require('fs');
        if (fs.existsSync(existingInvoice.pdfPath)) {
          await whatsappService.sendFile(
            adminPhone,
            existingInvoice.pdfPath,
            `Invoice ${existingInvoice.invoiceNumber} - ${deliveryBoy?.name || 'Delivery Boy'}`
          );
          logger.info('[BG] Invoice PDF sent to admin via WhatsApp');
        }
      }

      existingInvoice.sentViaWhatsApp = true;
      existingInvoice.sentAt = new Date();
      await existingInvoice.save();
      logger.info(`[BG] Invoice ${existingInvoice.invoiceNumber} WhatsApp send complete`);
    } catch (error) {
      logger.error('[BG] Error sending invoice via WhatsApp:', error.message || error.error || 'unknown');
    }
  }

  /**
   * Background helper: Send newly created invoice text + PDF to admin via WhatsApp
   */
  async _sendNewInvoiceViaWhatsApp(invoice, deliveryBoy, completedDeliveries, deliveryDetails, adminPhone, invoiceDate, pdfPath, invoiceNumber) {
    try {
      const whatsappService = require('../services/whatsapp.service');
      const WhatsAppTemplates = require('../templates/whatsapp-templates');
      const fs = require('fs');

      logger.info(`[BG] Sending new invoice ${invoiceNumber} to admin ${adminPhone}`);

      const invoiceMessage = WhatsAppTemplates.generateInvoiceMessage({
        customerName: deliveryBoy.name,
        invoiceNumber: invoiceNumber,
        totalDeliveries: completedDeliveries.length,
        totalAmount: parseFloat(invoice.totalAmount).toFixed(2),
        date: new Date(invoiceDate + 'T00:00:00').toLocaleDateString('en-IN'),
        deliveries: deliveryDetails
      });

      await whatsappService.sendMessage(adminPhone, invoiceMessage);
      logger.info('[BG] Invoice text sent to admin');

      if (pdfPath && fs.existsSync(pdfPath)) {
        await whatsappService.sendFile(
          adminPhone,
          pdfPath,
          `Invoice ${invoiceNumber} - ${deliveryBoy.name}`
        );
        logger.info('[BG] Invoice PDF sent to admin via WhatsApp');
      }

      invoice.sentViaWhatsApp = true;
      invoice.sentAt = new Date();
      await invoice.save();
      logger.info(`[BG] New invoice ${invoiceNumber} WhatsApp send complete`);
    } catch (error) {
      logger.error('[BG] Error sending new invoice via WhatsApp:', error.message || error.error || 'unknown');
    }
  }

  /**
   * GET /api/delivery-boy/history
   * View delivery history
   */
  async getDeliveryHistory(req, res, next) {
    try {
      const deliveryBoyId = req.user.id;
      const { page = 1, limit = 30, startDate, endDate } = req.query;
      const offset = (page - 1) * limit;

      const whereClause = {
        deliveryBoyId
      };

      // Add date filters if provided
      if (startDate || endDate) {
        whereClause.deliveryDate = {};
        if (startDate) {
          whereClause.deliveryDate[Op.gte] = new Date(startDate);
        }
        if (endDate) {
          const end = new Date(endDate);
          end.setHours(23, 59, 59, 999);
          whereClause.deliveryDate[Op.lte] = end;
        }
      }

      // Fetch deliveries
      const { count, rows: deliveries } = await db.Delivery.findAndCountAll({
        where: whereClause,
        include: [
          {
            model: db.User,
            as: 'customer',
            attributes: ['name', 'phone', 'address']
          },
          {
            model: db.DeliveryItem,
            as: 'items',
            include: [{
              model: db.Product,
              as: 'product',
              attributes: ['name', 'unit', 'imageUrl']
            }]
          }
        ],
        order: [['deliveryDate', 'DESC'], ['createdAt', 'DESC']],
        limit: parseInt(limit),
        offset: parseInt(offset)
      });

      // Group by date for better presentation
      const groupedHistory = {};
      deliveries.forEach(delivery => {
        // DATEONLY returns a string 'YYYY-MM-DD', not a Date object
        const dateKey = typeof delivery.deliveryDate === 'string'
          ? delivery.deliveryDate
          : new Date(delivery.deliveryDate).toISOString().split('T')[0];
        if (!groupedHistory[dateKey]) {
          groupedHistory[dateKey] = {
            date: dateKey,
            deliveries: [],
            totalAmount: 0,
            completedCount: 0,
            pendingCount: 0
          };
        }

        groupedHistory[dateKey].deliveries.push({
          deliveryId: delivery.id,
          customerName: delivery.customer.name,
          customerPhone: delivery.customer.phone,
          address: delivery.customer.address,
          status: delivery.status,
          amount: parseFloat(delivery.amount || 0),
          deliveredAt: delivery.deliveredAt,
          items: delivery.items.map(item => ({
            productName: item.product.name,
            quantity: parseFloat(item.quantity),
            unit: item.product.unit,
            price: parseFloat(item.price)
          }))
        });

        groupedHistory[dateKey].totalAmount += parseFloat(delivery.amount || 0);
        if (delivery.status === 'delivered') {
          groupedHistory[dateKey].completedCount++;
        } else {
          groupedHistory[dateKey].pendingCount++;
        }
      });

      const history = Object.values(groupedHistory);

      res.status(200).json({
        success: true,
        data: {
          deliveryBoyId,
          history,
          pagination: {
            total: count,
            page: parseInt(page),
            limit: parseInt(limit),
            totalPages: Math.ceil(count / limit)
          }
        }
      });
    } catch (error) {
      logger.error('Error getting delivery history:', error);
      next(error);
    }
  }

  /**
   * GET /api/delivery-boy/stats
   * Get performance statistics
   */
  async getStats(req, res, next) {
    try {
      const deliveryBoyId = req.user.id;
      const { period = 'all' } = req.query; // all, today, week, month

      let dateFilter = {};
      const now = new Date();

      switch (period) {
        case 'today':
          const today = new Date();
          today.setHours(0, 0, 0, 0);
          dateFilter = { deliveryDate: { [Op.gte]: today } };
          break;
        case 'week':
          const weekAgo = new Date();
          weekAgo.setDate(weekAgo.getDate() - 7);
          dateFilter = { deliveryDate: { [Op.gte]: weekAgo } };
          break;
        case 'month':
          const monthAgo = new Date();
          monthAgo.setMonth(monthAgo.getMonth() - 1);
          dateFilter = { deliveryDate: { [Op.gte]: monthAgo } };
          break;
      }

      // Get total deliveries and earnings
      const deliveries = await db.Delivery.findAll({
        where: {
          deliveryBoyId,
          ...dateFilter
        },
        attributes: [
          [db.sequelize.fn('COUNT', db.sequelize.col('id')), 'totalCount'],
          [db.sequelize.fn('SUM', db.sequelize.col('amount')), 'totalEarnings'],
          'status'
        ],
        group: ['status'],
        raw: true
      });

      // Calculate statistics
      let totalDeliveries = 0;
      let totalEarnings = 0;
      let completedDeliveries = 0;
      let pendingDeliveries = 0;

      deliveries.forEach(stat => {
        const count = parseInt(stat.totalCount);
        const earnings = parseFloat(stat.totalEarnings || 0);
        totalDeliveries += count;
        totalEarnings += earnings;

        if (stat.status === 'delivered') {
          completedDeliveries = count;
        } else if (stat.status === 'pending' || stat.status === 'in-progress') {
          pendingDeliveries += count;
        }
      });

      // Calculate average delivery time for completed deliveries
      const completedWithTime = await db.Delivery.findAll({
        where: {
          deliveryBoyId,
          status: 'delivered',
          deliveredAt: { [Op.ne]: null },
          ...dateFilter
        },
        attributes: ['createdAt', 'deliveredAt']
      });

      let averageDeliveryTime = 0;
      if (completedWithTime.length > 0) {
        const totalTime = completedWithTime.reduce((sum, delivery) => {
          const created = new Date(delivery.createdAt).getTime();
          const delivered = new Date(delivery.deliveredAt).getTime();
          return sum + (delivered - created);
        }, 0);
        averageDeliveryTime = Math.round(totalTime / completedWithTime.length / 1000 / 60); // in minutes
      }

      // Get today's deliveries
      const todayStart = new Date();
      todayStart.setHours(0, 0, 0, 0);

      const todayDeliveries = await db.Delivery.count({
        where: {
          deliveryBoyId,
          deliveryDate: { [Op.gte]: todayStart }
        }
      });

      const todayCompleted = await db.Delivery.count({
        where: {
          deliveryBoyId,
          deliveryDate: { [Op.gte]: todayStart },
          status: 'delivered'
        }
      });

      res.status(200).json({
        success: true,
        data: {
          deliveryBoyId,
          period,
          totalDeliveries,
          completedDeliveries,
          pendingDeliveries,
          totalEarnings: parseFloat(totalEarnings.toFixed(2)),
          averageDeliveryTime: `${averageDeliveryTime} mins`,
          today: {
            total: todayDeliveries,
            completed: todayCompleted,
            pending: todayDeliveries - todayCompleted
          },
          completionRate: totalDeliveries > 0
            ? parseFloat(((completedDeliveries / totalDeliveries) * 100).toFixed(2))
            : 0
        }
      });
    } catch (error) {
      logger.error('Error getting delivery boy stats:', error);
      next(error);
    }
  }

  /**
   * PATCH /api/delivery-boy/delivery/:id/status
   * Update delivery status and send customer notifications
   */
  async updateDeliveryStatus(req, res, next) {
    try {
      const deliveryBoyId = req.user.id;
      const { id } = req.params;
      const { status, notes, latitude, longitude } = req.body;

      if (!status) {
        return res.status(400).json({
          success: false,
          message: 'Status is required'
        });
      }

      // Validate status
      const validStatuses = ['pending', 'in-progress', 'delivered', 'missed', 'failed'];
      if (!validStatuses.includes(status)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid status. Must be one of: ' + validStatuses.join(', ')
        });
      }

      // Find delivery with customer details
      const delivery = await db.Delivery.findOne({
        where: {
          id,
          deliveryBoyId
        },
        include: [{
          model: db.User,
          as: 'customer',
          attributes: ['id', 'name', 'phone']
        }, {
          model: db.DeliveryItem,
          as: 'items',
          include: [{
            model: db.Product,
            as: 'product',
            attributes: ['name', 'unit']
          }]
        }]
      });

      if (!delivery) {
        return res.status(404).json({
          success: false,
          message: 'Delivery not found or not assigned to you'
        });
      }

      // Update delivery
      const updateData = { status };
      if (notes) updateData.notes = notes;
      if (status === 'delivered') {
        updateData.deliveredAt = new Date();
      }

      await delivery.update(updateData);

      // Update delivery boy location if provided
      if (latitude && longitude) {
        await db.User.update(
          { latitude, longitude },
          { where: { id: deliveryBoyId } }
        );
      }

      // Send WhatsApp notification to customer based on status
      const whatsappService = require('../services/whatsapp.service');
      const WhatsAppTemplates = require('../templates/whatsapp-templates');

      if (status === 'delivered' && delivery.customer) {
        try {
          const productList = (delivery.items || []).map(item => ({
            name: item.product?.name || 'Product',
            quantity: item.quantity,
            unit: item.product?.unit || ''
          }));

          // Get delivery boy name for the notification
          const deliveryBoyUser = await db.User.findByPk(deliveryBoyId, {
            attributes: ['name']
          });

          const deliveryConfirmationData = {
            customerName: delivery.customer.name,
            products: productList,
            deliveryDate: new Date(delivery.deliveryDate + 'T00:00:00').toLocaleDateString('en-IN'),
            amount: parseFloat(delivery.amount || 0),
            deliveryBoyName: deliveryBoyUser?.name || 'Delivery Boy'
          };

          const message = WhatsAppTemplates.generateDeliveryConfirmed(deliveryConfirmationData);
          await whatsappService.sendMessage(delivery.customer.phone, message);

          logger.info(`Delivery confirmation WhatsApp sent to customer ${delivery.customer.id}`);
        } catch (whatsappError) {
          logger.error('Error sending WhatsApp to customer:', whatsappError);
          // Don't fail the request if WhatsApp fails
        }
      } else if (status === 'missed' && delivery.customer) {
        try {
          const missedDeliveryData = {
            customerName: delivery.customer.name,
            date: new Date(delivery.deliveryDate + 'T00:00:00').toLocaleDateString('en-IN'),
            amount: parseFloat(delivery.amount || 0),
            reason: notes || 'Not available'
          };

          const message = WhatsAppTemplates.generateDeliveryMissed(missedDeliveryData);
          await whatsappService.sendMessage(delivery.customer.phone, message);

          logger.info(`Missed delivery notification sent to customer ${delivery.customer.id}`);
        } catch (whatsappError) {
          logger.error('Error sending missed delivery notification:', whatsappError);
        }
      }

      logger.info(`Delivery ${id} status updated to ${status} by delivery boy ${deliveryBoyId}`);

      res.status(200).json({
        success: true,
        message: 'Delivery status updated successfully',
        data: {
          deliveryId: delivery.id,
          status: delivery.status,
          deliveredAt: delivery.deliveredAt,
          whatsappSent: (status === 'delivered' || status === 'missed') && delivery.customer ? true : false
        }
      });
    } catch (error) {
      logger.error('Error updating delivery status:', error);
      next(error);
    }
  }

  /**
   * GET /api/delivery-boy/profile
   * Get delivery boy profile
   */
  async getProfile(req, res, next) {
    try {
      const deliveryBoyId = req.user.id;

      const deliveryBoy = await db.User.findByPk(deliveryBoyId, {
        attributes: { exclude: ['passwordHash'] },
        include: [{
          model: db.Area,
          as: 'assignedArea'
        }]
      });

      if (!deliveryBoy) {
        return res.status(404).json({
          success: false,
          message: 'Delivery boy not found'
        });
      }

      res.status(200).json({
        success: true,
        data: deliveryBoy
      });
    } catch (error) {
      logger.error('Error getting delivery boy profile:', error);
      next(error);
    }
  }

  /**
   * PUT /api/delivery-boy/profile
   * Update delivery boy profile
   */
  async updateProfile(req, res, next) {
    try {
      const deliveryBoyId = req.user.id;
      const { name, email, vehicleNumber, licenseNumber } = req.body;

      // Validate input
      if (!name || name.trim().length === 0) {
        return res.status(400).json({
          success: false,
          message: 'Name is required'
        });
      }

      // Find delivery boy
      const deliveryBoy = await db.User.findByPk(deliveryBoyId);

      if (!deliveryBoy) {
        return res.status(404).json({
          success: false,
          message: 'Delivery boy not found'
        });
      }

      // Update profile
      const updateData = {
        name: name.trim()
      };

      if (email) {
        updateData.email = email.trim();
      }

      // Store vehicle and license info in metadata if they exist
      if (vehicleNumber || licenseNumber) {
        const metadata = deliveryBoy.metadata || {};
        if (vehicleNumber) {
          metadata.vehicleNumber = vehicleNumber.trim();
        }
        if (licenseNumber) {
          metadata.licenseNumber = licenseNumber.trim();
        }
        updateData.metadata = metadata;
      }

      await deliveryBoy.update(updateData);

      logger.info(`Delivery boy ${deliveryBoyId} profile updated`);

      res.status(200).json({
        success: true,
        message: 'Profile updated successfully',
        data: {
          id: deliveryBoy.id,
          name: deliveryBoy.name,
          phone: deliveryBoy.phone,
          email: deliveryBoy.email,
          address: deliveryBoy.address,
          metadata: deliveryBoy.metadata
        }
      });
    } catch (error) {
      logger.error('Error updating delivery boy profile:', error);
      next(error);
    }
  }

  /**
   * GET /api/delivery-boy/area
   * Get the delivery boy's assigned area with all details
   */
  async getArea(req, res, next) {
    try {
      const deliveryBoyId = req.user.id;

      const deliveryBoy = await db.User.findByPk(deliveryBoyId, {
        attributes: ['id'],
        include: [{
          model: db.Area,
          as: 'assignedArea',
          attributes: ['id', 'name', 'description', 'boundaries', 'centerLatitude', 'centerLongitude', 'mapLink', 'deliveryBoyId', 'isActive']
        }]
      });

      if (!deliveryBoy) {
        return res.status(404).json({
          success: false,
          message: 'Delivery boy not found'
        });
      }

      if (!deliveryBoy.assignedArea) {
        return res.status(404).json({
          success: true,
          message: 'No area assigned yet',
          data: null
        });
      }

      // Verify area is active
      if (!deliveryBoy.assignedArea.isActive) {
        return res.status(404).json({
          success: true,
          message: 'Assigned area is inactive',
          data: null
        });
      }

      res.status(200).json({
        success: true,
        data: deliveryBoy.assignedArea
      });
    } catch (error) {
      logger.error('Error getting assigned area:', error);
      next(error);
    }
  }

  /**
   * PUT /api/delivery-boy/location
   * Update current location
   */
  async updateLocation(req, res, next) {
    try {
      const deliveryBoyId = req.user.id;
      const { latitude, longitude } = req.body;

      if (!latitude || !longitude) {
        return res.status(400).json({
          success: false,
          message: 'Latitude and longitude are required'
        });
      }

      await db.User.update(
        {
          latitude: parseFloat(latitude),
          longitude: parseFloat(longitude)
        },
        { where: { id: deliveryBoyId } }
      );

      res.status(200).json({
        success: true,
        message: 'Location updated successfully',
        data: {
          latitude: parseFloat(latitude),
          longitude: parseFloat(longitude)
        }
      });
    } catch (error) {
      logger.error('Error updating location:', error);
      next(error);
    }
  }

  /**
   * POST /api/delivery-boy/verify-delivery
   * Verify delivery location and mark as delivered with geofence validation.
   *
   * SECURITY: This endpoint re-validates the distance server-side.
   * Do NOT trust client-side validation alone.
   */
  async verifyDelivery(req, res, next) {
    try {
      const deliveryBoyId = req.user.id;
      const {
        deliveryId,
        agentLatitude,
        agentLongitude,
        agentAccuracy,
        timestamp,
        notes
      } = req.body;

      // Validate required fields
      if (!deliveryId || agentLatitude === undefined || agentLongitude === undefined) {
        return res.status(400).json({
          success: false,
          message: 'Delivery ID, agent latitude, and agent longitude are required',
          errorCode: 'MISSING_FIELDS'
        });
      }

      // Fetch the delivery with customer location
      const delivery = await db.Delivery.findOne({
        where: {
          id: deliveryId,
          deliveryBoyId: deliveryBoyId,
          status: {
            [Op.in]: ['pending', 'in-progress']
          }
        },
        include: [{
          model: db.User,
          as: 'customer',
          attributes: ['id', 'name', 'latitude', 'longitude', 'address']
        }]
      });

      if (!delivery) {
        return res.status(404).json({
          success: false,
          message: 'Delivery not found or already completed',
          errorCode: 'DELIVERY_NOT_FOUND'
        });
      }

      // Get customer destination coordinates
      const destLatitude = parseFloat(delivery.customer.latitude);
      const destLongitude = parseFloat(delivery.customer.longitude);

      if (!destLatitude || !destLongitude) {
        return res.status(400).json({
          success: false,
          message: 'Customer location not configured',
          errorCode: 'NO_DESTINATION'
        });
      }

      // Calculate distance using Haversine formula (server-side validation)
      const distance = this._calculateDistance(
        parseFloat(agentLatitude),
        parseFloat(agentLongitude),
        destLatitude,
        destLongitude
      );

      // Get allowed radius (default 100 meters)
      const allowedRadius = delivery.allowedRadius || 100;

      // Log the verification attempt
      logger.info('Delivery verification attempt', {
        deliveryId,
        deliveryBoyId,
        agentLocation: { lat: agentLatitude, lng: agentLongitude, accuracy: agentAccuracy },
        destinationLocation: { lat: destLatitude, lng: destLongitude },
        distance: distance.toFixed(2),
        allowedRadius,
        timestamp,
        isWithinRadius: distance <= allowedRadius
      });

      // Validate distance - SECURITY CHECK
      if (distance > allowedRadius) {
        return res.status(400).json({
          success: false,
          message: `You are ${distance.toFixed(0)}m away from the delivery location. Please move within ${allowedRadius}m to complete delivery.`,
          errorCode: 'OUTSIDE_RADIUS',
          data: {
            distance: distance,
            allowedRadius: allowedRadius,
            destinationLatitude: destLatitude,
            destinationLongitude: destLongitude
          }
        });
      }

      // Distance is valid - update delivery status
      const now = new Date();
      await delivery.update({
        status: 'delivered',
        deliveredAt: now,
        deliveryNotes: notes,
        verificationLatitude: parseFloat(agentLatitude),
        verificationLongitude: parseFloat(agentLongitude),
        verificationAccuracy: agentAccuracy ? parseFloat(agentAccuracy) : null,
        verificationTimestamp: timestamp ? new Date(timestamp) : now,
        verificationDistance: distance
      });

      // Update delivery boy's current location
      await db.User.update(
        {
          latitude: parseFloat(agentLatitude),
          longitude: parseFloat(agentLongitude)
        },
        { where: { id: deliveryBoyId } }
      );

      logger.info('Delivery verified and completed', {
        deliveryId,
        deliveryBoyId,
        customerId: delivery.customer.id,
        distance: distance.toFixed(2),
        completedAt: now
      });

      res.status(200).json({
        success: true,
        message: 'Delivery verified and marked as complete',
        data: {
          deliveryId: delivery.id,
          status: 'delivered',
          distance: distance,
          allowedRadius: allowedRadius,
          destinationLatitude: destLatitude,
          destinationLongitude: destLongitude,
          verifiedAt: now
        }
      });
    } catch (error) {
      logger.error('Error verifying delivery:', error);
      next(error);
    }
  }

  /**
   * GET /api/delivery-boy/config
   * Get delivery configuration including allowed radius
   */
  async getConfig(req, res, next) {
    try {
      // Configuration values (could be moved to database/env)
      const config = {
        allowedDeliveryRadius: 100, // meters
        locationUpdateInterval: 5000, // milliseconds
        highAccuracyThreshold: 20, // meters
        acceptableAccuracyThreshold: 100 // meters
      };

      res.status(200).json({
        success: true,
        data: config
      });
    } catch (error) {
      logger.error('Error getting config:', error);
      next(error);
    }
  }

  /**
   * GET /api/delivery-boy/invoices
   * Get all invoices for the current delivery boy
   */
  async getInvoices(req, res, next) {
    try {
      const deliveryBoyId = req.user.id;
      const { startDate, endDate, status } = req.query;

      const where = { deliveryBoyId };

      if (startDate && endDate) {
        where.invoiceDate = {
          [Op.between]: [new Date(startDate), new Date(endDate)]
        };
      } else if (startDate) {
        where.invoiceDate = { [Op.gte]: new Date(startDate) };
      } else if (endDate) {
        where.invoiceDate = { [Op.lte]: new Date(endDate) };
      }

      if (status) {
        where.status = status;
      }

      const invoices = await db.Invoice.findAll({
        where,
        order: [['invoiceDate', 'DESC']],
        attributes: [
          'id', 'invoiceNumber', 'invoiceType', 'status',
          'invoiceDate', 'totalAmount', 'metadata',
          'submittedAt', 'approvedAt', 'approvedBy', 'rejectionReason',
          'createdAt', 'updatedAt'
        ]
      });

      res.status(200).json({
        success: true,
        data: invoices.map(invoice => ({
          ...invoice.toJSON(),
          items: invoice.metadata?.deliveries || []
        }))
      });
    } catch (error) {
      logger.error('Error getting invoices:', error);
      next(error);
    }
  }

  /**
   * GET /api/delivery-boy/invoices/:id
   * Get a specific invoice by ID
   */
  async getInvoiceById(req, res, next) {
    try {
      const deliveryBoyId = req.user.id;
      const { id } = req.params;

      const invoice = await db.Invoice.findOne({
        where: { id, deliveryBoyId }
      });

      if (!invoice) {
        return res.status(404).json({
          success: false,
          message: 'Invoice not found'
        });
      }

      res.status(200).json({
        success: true,
        data: {
          ...invoice.toJSON(),
          items: invoice.metadata?.deliveries || []
        }
      });
    } catch (error) {
      logger.error('Error getting invoice:', error);
      next(error);
    }
  }

  /**
   * POST /api/delivery-boy/invoices/:id/submit
   * Submit an invoice for admin approval
   */
  async submitInvoice(req, res, next) {
    try {
      const deliveryBoyId = req.user.id;
      const { id } = req.params;

      const invoice = await db.Invoice.findOne({
        where: { id, deliveryBoyId }
      });

      if (!invoice) {
        return res.status(404).json({
          success: false,
          message: 'Invoice not found'
        });
      }

      if (invoice.status !== 'generated') {
        return res.status(400).json({
          success: false,
          message: `Cannot submit invoice with status: ${invoice.status}`
        });
      }

      await invoice.update({
        status: 'submitted',
        submittedAt: new Date()
      });

      logger.info(`Invoice ${invoice.invoiceNumber} submitted by delivery boy ${deliveryBoyId}`);

      res.status(200).json({
        success: true,
        message: 'Invoice submitted for approval',
        data: {
          ...invoice.toJSON(),
          items: invoice.metadata?.deliveries || []
        }
      });
    } catch (error) {
      logger.error('Error submitting invoice:', error);
      next(error);
    }
  }

  /**
   * GET /api/delivery-boy/assigned-data/:deliveryBoyId
   * Fetch complete assigned data: area, customers, and today's deliveries
   * Used primarily for dashboard initialization and data reflection
   */
  async getAssignedData(req, res, next) {
    try {
      const deliveryBoyId = req.params.deliveryBoyId || req.user.id;

      if (req.user.id !== deliveryBoyId && req.user.role !== 'admin') {
        return res.status(403).json({
          success: false,
          message: 'Unauthorized to access this delivery boy data'
        });
      }

      // Get delivery boy with assigned area
      const deliveryBoy = await db.User.findByPk(deliveryBoyId, {
        attributes: ['id', 'name', 'phone', 'email', 'latitude', 'longitude', 'address'],
        include: [{
          model: db.Area,
          as: 'assignedArea',
          attributes: ['id', 'name', 'description', 'boundaries', 'centerLatitude', 'centerLongitude', 'mapLink', 'isActive']
        }]
      });

      if (!deliveryBoy) {
        return res.status(404).json({
          success: false,
          message: 'Delivery boy not found'
        });
      }

      // Get today's date
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      let assignedCustomers = [];
      let todaysDeliveries = [];

      if (deliveryBoy.assignedArea && deliveryBoy.assignedArea.isActive) {
        // Get all customers in the assigned area
        assignedCustomers = await db.User.findAll({
          where: {
            areaId: deliveryBoy.assignedArea.id,
            isActive: true,
            role: 'customer'
          },
          attributes: ['id', 'name', 'phone', 'address', 'latitude', 'longitude', 'areaId'],
          include: [{
            model: db.Subscription,
            as: 'subscriptions',
            attributes: ['id', 'frequency', 'status', 'startDate'],
            where: { status: 'active' },
            required: false,
            include: [{
              model: db.SubscriptionProduct,
              as: 'products',
              attributes: ['id', 'quantity'],
              required: false,
              include: [{
                model: db.Product,
                as: 'product',
                attributes: ['id', 'name', 'unit', 'pricePerUnit', 'imageUrl'],
                required: false
              }]
            }]
          }],
          order: [['name', 'ASC']]
        });

        // Get today's deliveries
        todaysDeliveries = await db.Delivery.findAll({
          where: {
            deliveryBoyId,
            deliveryDate: { [Op.gte]: today },
            status: { [Op.in]: ['pending', 'in-progress', 'delivered', 'missed'] }
          },
          attributes: ['id', 'customerId', 'status', 'amount', 'deliveryDate', 'deliveredAt'],
          raw: true
        });
      }

      // Aggregate data by customer
      const deliveryMap = {};
      let totalCollected = 0;

      todaysDeliveries.forEach(delivery => {
        if (!deliveryMap[delivery.customerId]) {
          deliveryMap[delivery.customerId] = {
            total: 0,
            deliveries: []
          };
        }
        deliveryMap[delivery.customerId].deliveries.push({
          id: delivery.id,
          status: delivery.status,
          amount: parseFloat(delivery.amount || 0),
          deliveredAt: delivery.deliveredAt
        });
        deliveryMap[delivery.customerId].total += parseFloat(delivery.amount || 0);

        if (delivery.status === 'delivered') {
          totalCollected += parseFloat(delivery.amount || 0);
        }
      });

      // Format response
      const formattedCustomers = assignedCustomers.map(customer => {
        const customerDeliveries = deliveryMap[customer.id];
        const todayAmount = customerDeliveries ? customerDeliveries.total : 0;
        const deliveryStatus = customerDeliveries && customerDeliveries.deliveries.length > 0
          ? customerDeliveries.deliveries[0].status
          : 'pending';

        return {
          id: customer.id,
          name: customer.name,
          phone: customer.phone,
          address: customer.address,
          latitude: customer.latitude ? parseFloat(customer.latitude) : null,
          longitude: customer.longitude ? parseFloat(customer.longitude) : null,
          todayAmount,
          deliveryStatus,
          subscriptions: (customer.subscriptions || []).map(sub => ({
            id: sub.id,
            frequency: sub.frequency,
            status: sub.status,
            startDate: sub.startDate,
            products: (sub.products || []).map(sp => ({
              id: sp.id,
              quantity: parseFloat(sp.quantity),
              product: sp.product ? {
                id: sp.product.id,
                name: sp.product.name,
                unit: sp.product.unit,
                pricePerUnit: parseFloat(sp.product.pricePerUnit),
                imageUrl: sp.product.imageUrl
              } : null
            }))
          }))
        };
      });

      const stats = {
        totalCustomers: formattedCustomers.length,
        totalDeliveries: todaysDeliveries.length,
        completedDeliveries: todaysDeliveries.filter(d => d.status === 'delivered').length,
        pendingDeliveries: todaysDeliveries.filter(d => d.status === 'pending').length,
        inProgressDeliveries: todaysDeliveries.filter(d => d.status === 'in-progress').length,
        missedDeliveries: todaysDeliveries.filter(d => d.status === 'missed').length,
        totalCollected
      };

      logger.info(`Assigned data retrieved for delivery boy ${deliveryBoyId}. Customers: ${formattedCustomers.length}`);

      res.status(200).json({
        success: true,
        data: {
          deliveryBoy: {
            id: deliveryBoy.id,
            name: deliveryBoy.name,
            phone: deliveryBoy.phone,
            email: deliveryBoy.email,
            latitude: deliveryBoy.latitude ? parseFloat(deliveryBoy.latitude) : null,
            longitude: deliveryBoy.longitude ? parseFloat(deliveryBoy.longitude) : null,
            address: deliveryBoy.address
          },
          area: deliveryBoy.assignedArea,
          customers: formattedCustomers,
          stats: stats,
          date: today.toISOString().split('T')[0]
        }
      });
    } catch (error) {
      logger.error('Error getting assigned data:', error);
      next(error);
    }
  }

  /**
   * Calculate distance between two coordinates using Haversine formula.
   * @param {number} lat1 - Latitude of first point
   * @param {number} lon1 - Longitude of first point
   * @param {number} lat2 - Latitude of second point
   * @param {number} lon2 - Longitude of second point
   * @returns {number} Distance in meters
   * @private
   */
  _calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371000; // Earth's radius in meters
    const dLat = this._toRadians(lat2 - lat1);
    const dLon = this._toRadians(lon2 - lon1);

    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this._toRadians(lat1)) * Math.cos(this._toRadians(lat2)) *
      Math.sin(dLon / 2) * Math.sin(dLon / 2);

    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c; // Distance in meters
  }

  /**
   * Convert degrees to radians
   * @param {number} degrees
   * @returns {number} radians
   * @private
   */
  _toRadians(degrees) {
    return degrees * (Math.PI / 180);
  }
}

module.exports = new DeliveryBoyController();

