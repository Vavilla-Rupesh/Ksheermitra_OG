const deliveryService = require('../services/delivery.service');
const invoiceService = require('../services/invoice.service');
const mapsService = require('../services/maps.service');
const db = require('../config/db');
const logger = require('../utils/logger');

class DeliveryBoyController {
  async getAssignedCustomers(req, res, next) {
    try {
      const deliveryBoyId = req.user.id;
      const { date } = req.query;

      const deliveries = await deliveryService.getAssignedDeliveries(deliveryBoyId, date);

      const customers = deliveries.reduce((acc, delivery) => {
        if (!acc.find(c => c.id === delivery.customer.id)) {
          acc.push({
            id: delivery.customer.id,
            name: delivery.customer.name,
            phone: delivery.customer.phone,
            address: delivery.customer.address,
            latitude: delivery.customer.latitude,
            longitude: delivery.customer.longitude,
            deliveries: []
          });
        }
        
        const customer = acc.find(c => c.id === delivery.customer.id);
        customer.deliveries.push({
          id: delivery.id,
          productName: delivery.product.name,
          quantity: delivery.quantity,
          unit: delivery.product.unit,
          amount: delivery.amount,
          status: delivery.status
        });

        return acc;
      }, []);

      res.status(200).json({
        success: true,
        data: customers
      });
    } catch (error) {
      logger.error('Error getting assigned customers:', error);
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

      const deliveries = await deliveryService.getAssignedDeliveries(deliveryBoyId, date);

      const uniqueCustomers = Array.from(new Set(deliveries.map(d => d.customer.id)))
        .map(id => deliveries.find(d => d.customer.id === id).customer)
        .filter(c => c.latitude && c.longitude);

      if (uniqueCustomers.length === 0) {
        return res.status(200).json({
          success: true,
          message: 'No customers with valid locations found',
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

      const destinations = uniqueCustomers.map(c => ({
        id: c.id,
        name: c.name,
        latitude: c.latitude,
        longitude: c.longitude
      }));

      const routeData = await mapsService.optimizeRoute(origin, destinations);

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

      res.status(201).json({
        success: true,
        message: 'Daily invoice generated successfully',
        data: invoice
      });
    } catch (error) {
      logger.error('Error generating daily invoice:', error);
      next(error);
    }
  }
}

module.exports = new DeliveryBoyController();
