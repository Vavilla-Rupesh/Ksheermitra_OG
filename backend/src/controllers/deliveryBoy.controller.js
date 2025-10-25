const deliveryService = require('../services/delivery.service');
const invoiceService = require('../services/invoice.service');
const mapsService = require('../services/maps.service');
const whatsappService = require('../services/whatsapp.service');
const WhatsAppTemplates = require('../templates/whatsapp-templates');
const db = require('../config/db');
const logger = require('../utils/logger');
const moment = require('moment');

class DeliveryBoyController {
  async getAssignedCustomers(req, res, next) {
    try {
      const deliveryBoyId = req.user.id;
      const { date } = req.query;

      const customerDeliveries = await deliveryService.getDeliveriesWithSubscriptionDetails(deliveryBoyId, date);

      res.status(200).json({
        success: true,
        data: customerDeliveries
      });
    } catch (error) {
      logger.error('Error getting assigned customers:', error);
      next(error);
    }
  }

  async getCustomerDetails(req, res, next) {
    try {
      const deliveryBoyId = req.user.id;
      const { customerId } = req.params;
      const { date } = req.query;

      const details = await deliveryService.getCustomerDeliveryDetails(customerId, deliveryBoyId, date);

      res.status(200).json({
        success: true,
        data: details
      });
    } catch (error) {
      logger.error('Error getting customer details:', error);
      next(error);
    }
  }

  async getDeliveryMap(req, res, next) {
    try {
      const deliveryBoyId = req.user.id;
      const { date } = req.query;

      // Get delivery boy's assigned area
      const area = await db.Area.findOne({
        where: { deliveryBoyId },
        include: [{
          model: db.User,
          as: 'customers',
          attributes: ['id', 'name', 'phone', 'address', 'latitude', 'longitude'],
          where: {
            isActive: true,
            latitude: { [db.Sequelize.Op.ne]: null },
            longitude: { [db.Sequelize.Op.ne]: null }
          },
          required: false,
          include: [{
            model: db.Subscription,
            as: 'subscriptions',
            where: { status: 'active' },
            required: false,
            include: [{
              model: db.SubscriptionProduct,
              as: 'products',
              include: [{
                model: db.Product,
                as: 'product'
              }]
            }]
          }]
        }]
      });

      if (!area) {
        return res.status(404).json({
          success: false,
          message: 'No area assigned to you'
        });
      }

      // Get today's delivery statuses
      const deliveryDate = date || moment().format('YYYY-MM-DD');
      const deliveries = await db.Delivery.findAll({
        where: {
          deliveryBoyId,
          deliveryDate
        },
        attributes: ['customerId', 'status', 'amount']
      });

      // Map delivery statuses to customers
      const customerMap = {};
      deliveries.forEach(d => {
        if (!customerMap[d.customerId]) {
          customerMap[d.customerId] = {
            status: d.status,
            amount: parseFloat(d.amount || 0)
          };
        } else {
          customerMap[d.customerId].amount += parseFloat(d.amount || 0);
          // Priority: delivered > missed > pending
          if (d.status === 'delivered' ||
              (d.status === 'missed' && customerMap[d.customerId].status === 'pending')) {
            customerMap[d.customerId].status = d.status;
          }
        }
      });

      // Enrich customers with delivery status and subscription details
      const customersWithStatus = area.customers.map(customer => {
        const customerData = customer.toJSON();
        const deliveryInfo = customerMap[customer.id] || { status: 'pending', amount: 0 };

        // Calculate total amount from subscriptions if not in deliveries
        let totalAmount = deliveryInfo.amount;
        if (totalAmount === 0 && customerData.subscriptions) {
          customerData.subscriptions.forEach(sub => {
            sub.products.forEach(sp => {
              totalAmount += parseFloat(sp.quantity) * parseFloat(sp.product.pricePerUnit);
            });
          });
        }

        return {
          ...customerData,
          deliveryStatus: deliveryInfo.status,
          todayAmount: totalAmount
        };
      });

      res.status(200).json({
        success: true,
        data: {
          area: {
            id: area.id,
            name: area.name,
            boundaries: area.boundaries,
            centerLatitude: area.centerLatitude,
            centerLongitude: area.centerLongitude
          },
          customers: customersWithStatus
        }
      });
    } catch (error) {
      logger.error('Error getting delivery map:', error);
      next(error);
    }
  }

  async getOptimizedRoute(req, res, next) {
    try {
      const deliveryBoyId = req.user.id;
      const { date } = req.query;

      const deliveryBoy = await db.User.findByPk(deliveryBoyId);
      
      if (!deliveryBoy.latitude || !deliveryBoy.longitude) {
        return res.status(400).json({
          success: false,
          message: 'Delivery boy location not set'
        });
      }

      const customerDeliveries = await deliveryService.getDeliveriesWithSubscriptionDetails(deliveryBoyId, date);

      const customersWithLocation = customerDeliveries
        .filter(cd => cd.customer.latitude && cd.customer.longitude && cd.status !== 'delivered')
        .map(cd => ({
          id: cd.customer.id,
          name: cd.customer.name,
          latitude: cd.customer.latitude,
          longitude: cd.customer.longitude,
          address: cd.customer.address
        }));

      if (customersWithLocation.length === 0) {
        return res.status(200).json({
          success: true,
          message: 'No pending deliveries with valid locations',
          data: {
            optimizedOrder: [],
            routes: []
          }
        });
      }

      const origin = {
        latitude: deliveryBoy.latitude,
        longitude: deliveryBoy.longitude
      };

      const routeData = await mapsService.optimizeRoute(origin, customersWithLocation);

      res.status(200).json({
        success: true,
        data: routeData
      });
    } catch (error) {
      logger.error('Error getting optimized route:', error);
      next(error);
    }
  }

  async updateDeliveryStatus(req, res, next) {
    try {
      const deliveryBoyId = req.user.id;
      const { customerId, status, notes } = req.body;
      const { date } = req.query;

      // Update all deliveries for this customer on this date
      const deliveries = await deliveryService.updateMultipleDeliveryStatuses(
        customerId,
        deliveryBoyId,
        date,
        status,
        notes
      );

      res.status(200).json({
        success: true,
        message: `Delivery status updated to ${status}`,
        data: deliveries
      });
    } catch (error) {
      logger.error('Error updating delivery status:', error);
      next(error);
    }
  }

  async updateSingleDeliveryStatus(req, res, next) {
    try {
      const deliveryBoyId = req.user.id;
      const { deliveryId, status, notes } = req.body;

      const delivery = await deliveryService.updateDeliveryStatus(deliveryId, status, deliveryBoyId, notes);

      res.status(200).json({
        success: true,
        message: 'Delivery status updated successfully',
        data: delivery
      });
    } catch (error) {
      logger.error('Error updating delivery status:', error);
      next(error);
    }
  }

  async getDeliveryStats(req, res, next) {
    try {
      const deliveryBoyId = req.user.id;
      const { date } = req.query;

      const stats = await deliveryService.getDeliveryStats(deliveryBoyId, date);

      res.status(200).json({
        success: true,
        data: stats
      });
    } catch (error) {
      logger.error('Error getting delivery stats:', error);
      next(error);
    }
  }

  async generateDailyInvoice(req, res, next) {
    try {
      const deliveryBoyId = req.user.id;
      const { date } = req.body;

      const invoice = await invoiceService.generateDailyInvoice(deliveryBoyId, date);

      // Send WhatsApp notification to admin with PDF
      try {
        const adminUsers = await db.User.findAll({
          where: { role: 'admin', isActive: true },
          attributes: ['phone']
        });

        const deliveryBoy = await db.User.findByPk(deliveryBoyId, {
          attributes: ['name', 'phone']
        });

        const invoiceUrl = `${process.env.BASE_URL || 'http://localhost:3000'}/invoices/${invoice.pdfPath}`;

        for (const admin of adminUsers) {
          const message = WhatsAppTemplates.generateDailyInvoiceToAdmin({
            deliveryBoyName: deliveryBoy.name,
            deliveryBoyPhone: deliveryBoy.phone,
            date: moment(invoice.invoiceDate).format('DD MMM YYYY'),
            totalDelivered: invoice.totalDelivered || 0,
            totalMissed: invoice.totalMissed || 0,
            totalCollected: invoice.totalAmount || 0,
            deliveries: invoice.deliveries || [],
            pdfUrl: invoiceUrl
          });

          await whatsappService.sendMessage(admin.phone, message);

          // Send PDF file if available
          if (invoice.pdfPath) {
            const fs = require('fs');
            const path = require('path');
            const pdfFullPath = path.join(__dirname, '../../', invoice.pdfPath);

            if (fs.existsSync(pdfFullPath)) {
              await whatsappService.sendFile(admin.phone, pdfFullPath, `Daily Invoice - ${deliveryBoy.name} - ${moment(invoice.invoiceDate).format('DD-MM-YYYY')}`);
            }
          }
        }

        logger.info(`Daily invoice generated and sent to admin for delivery boy ${deliveryBoyId}`);
      } catch (whatsappError) {
        logger.error('Error sending invoice to admin via WhatsApp:', whatsappError);
        // Don't fail the request if WhatsApp fails
      }

      res.status(201).json({
        success: true,
        message: 'Daily invoice generated successfully and sent to admin',
        data: invoice
      });
    } catch (error) {
      logger.error('Error generating daily invoice:', error);
      next(error);
    }
  }

  async getMyArea(req, res, next) {
    try {
      const deliveryBoyId = req.user.id;

      const area = await db.Area.findOne({
        where: { deliveryBoyId },
        include: [{
          model: db.User,
          as: 'customers',
          attributes: ['id', 'name', 'phone', 'address', 'latitude', 'longitude']
        }]
      });

      if (!area) {
        return res.status(404).json({
          success: false,
          message: 'No area assigned to you'
        });
      }

      res.status(200).json({
        success: true,
        data: area
      });
    } catch (error) {
      logger.error('Error getting delivery boy area:', error);
      next(error);
    }
  }

  async getMyProfile(req, res, next) {
    try {
      const deliveryBoyId = req.user.id;

      const deliveryBoy = await db.User.findByPk(deliveryBoyId, {
        attributes: { exclude: ['passwordHash'] },
        include: [{
          model: db.Area,
          as: 'area',
          foreignKey: 'deliveryBoyId'
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

  async updateMyLocation(req, res, next) {
    try {
      const deliveryBoyId = req.user.id;
      const { latitude, longitude } = req.body;

      const deliveryBoy = await db.User.findByPk(deliveryBoyId);

      if (!deliveryBoy) {
        return res.status(404).json({
          success: false,
          message: 'Delivery boy not found'
        });
      }

      await deliveryBoy.update({ latitude, longitude });

      res.status(200).json({
        success: true,
        message: 'Location updated successfully',
        data: { latitude, longitude }
      });
    } catch (error) {
      logger.error('Error updating location:', error);
      next(error);
    }
  }

  async getTodaysSummary(req, res, next) {
    try {
      const deliveryBoyId = req.user.id;
      const today = moment().format('YYYY-MM-DD');

      const [stats, deliveries] = await Promise.all([
        deliveryService.getDeliveryStats(deliveryBoyId, today),
        db.Delivery.findAll({
          where: {
            deliveryBoyId,
            deliveryDate: today
          },
          include: [
            {
              model: db.User,
              as: 'customer',
              attributes: ['id', 'name', 'phone', 'address']
            }
          ],
          order: [['deliveredAt', 'DESC']]
        })
      ]);

      res.status(200).json({
        success: true,
        data: {
          stats,
          recentDeliveries: deliveries.slice(0, 10)
        }
      });
    } catch (error) {
      logger.error('Error getting today summary:', error);
      next(error);
    }
  }
}

module.exports = new DeliveryBoyController();
