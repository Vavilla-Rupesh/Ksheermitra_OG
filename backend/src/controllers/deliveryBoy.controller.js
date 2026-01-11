const db = require('../config/db');
const logger = require('../utils/logger');
const mapsService = require('../services/maps.service');
const { Op } = require('sequelize');

class DeliveryBoyController {
  /**
   * GET /api/delivery-boy/delivery-map
   * Fetch assigned delivery routes for navigation
   */
  async getDeliveryMap(req, res, next) {
    try {
      const deliveryBoyId = req.user.id;
      const { date } = req.query;

      // Default to today if no date provided
      const deliveryDate = date ? new Date(date) : new Date();
      deliveryDate.setHours(0, 0, 0, 0);

      // Fetch all pending and in-progress deliveries for the delivery boy
      const deliveries = await db.Delivery.findAll({
        where: {
          deliveryBoyId,
          deliveryDate,
          status: {
            [Op.in]: ['pending', 'in-progress']
          }
        },
        include: [
          {
            model: db.User,
            as: 'customer',
            attributes: ['id', 'name', 'phone', 'address', 'latitude', 'longitude']
          },
          {
            model: db.DeliveryItem,
            as: 'items',
            include: [{
              model: db.Product,
              as: 'product',
              attributes: ['id', 'name', 'unit', 'imageUrl']
            }]
          }
        ],
        order: [['createdAt', 'ASC']]
      });

      // Format routes for map display
      const routes = deliveries.map(delivery => ({
        deliveryId: delivery.id,
        customerName: delivery.customer.name,
        customerPhone: delivery.customer.phone,
        address: delivery.customer.address,
        latitude: parseFloat(delivery.customer.latitude),
        longitude: parseFloat(delivery.customer.longitude),
        status: delivery.status,
        items: delivery.items.map(item => ({
          productName: item.product.name,
          quantity: parseFloat(item.quantity),
          unit: item.product.unit,
          price: parseFloat(item.price)
        })),
        totalAmount: delivery.amount ? parseFloat(delivery.amount) : 0,
        notes: delivery.notes
      }));

      // Get delivery boy's current location if available
      const deliveryBoy = await db.User.findByPk(deliveryBoyId, {
        attributes: ['latitude', 'longitude']
      });

      res.status(200).json({
        success: true,
        data: {
          deliveryBoyId,
          date: deliveryDate,
          currentLocation: deliveryBoy.latitude && deliveryBoy.longitude ? {
            latitude: parseFloat(deliveryBoy.latitude),
            longitude: parseFloat(deliveryBoy.longitude)
          } : null,
          routes,
          totalDeliveries: routes.length
        }
      });
    } catch (error) {
      logger.error('Error getting delivery map:', error);
      next(error);
    }
  }

  /**
   * POST /api/delivery-boy/generate-invoice
   * Generate daily invoice for completed deliveries
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

      const invoiceDate = new Date(date);
      invoiceDate.setHours(0, 0, 0, 0);

      // Check if invoice already exists for this date
      const existingInvoice = await db.Invoice.findOne({
        where: {
          deliveryBoyId,
          invoiceDate,
          invoiceType: 'delivery_boy_daily'
        }
      });

      if (existingInvoice) {
        return res.status(200).json({
          success: true,
          message: 'Invoice already exists',
          data: {
            invoiceId: existingInvoice.id,
            invoiceNumber: existingInvoice.invoiceNumber,
            totalDeliveries: existingInvoice.metadata?.totalDeliveries || 0,
            totalAmount: parseFloat(existingInvoice.totalAmount),
            generatedAt: existingInvoice.createdAt
          }
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
      const invoiceNumber = `INV-DB-${invoiceDate.getFullYear()}${String(invoiceDate.getMonth() + 1).padStart(2, '0')}${String(invoiceDate.getDate()).padStart(2, '0')}-${deliveryBoyId.substring(0, 8).toUpperCase()}`;

      // Create invoice
      const invoice = await db.Invoice.create({
        invoiceNumber,
        invoiceType: 'delivery_boy_daily',
        deliveryBoyId,
        customerId: null, // Delivery boy invoice
        invoiceDate,
        totalAmount,
        status: 'generated',
        metadata: {
          totalDeliveries: completedDeliveries.length,
          deliveries: completedDeliveries.map(d => ({
            deliveryId: d.id,
            customerName: d.customer.name,
            customerPhone: d.customer.phone,
            amount: parseFloat(d.amount),
            items: d.items.map(item => ({
              productName: item.product.name,
              quantity: parseFloat(item.quantity),
              unit: item.product.unit,
              price: parseFloat(item.price)
            }))
          }))
        }
      });

      logger.info(`Invoice generated for delivery boy ${deliveryBoyId} for date ${date}`);

      res.status(201).json({
        success: true,
        message: 'Invoice generated successfully',
        data: {
          invoiceId: invoice.id,
          invoiceNumber: invoice.invoiceNumber,
          totalDeliveries: completedDeliveries.length,
          totalAmount,
          generatedAt: invoice.createdAt
        }
      });
    } catch (error) {
      logger.error('Error generating invoice:', error);
      next(error);
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
        const dateKey = delivery.deliveryDate.toISOString().split('T')[0];
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
   * Update delivery status
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
      const validStatuses = ['pending', 'in-progress', 'delivered', 'failed'];
      if (!validStatuses.includes(status)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid status. Must be one of: ' + validStatuses.join(', ')
        });
      }

      // Find delivery
      const delivery = await db.Delivery.findOne({
        where: {
          id,
          deliveryBoyId
        }
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

      logger.info(`Delivery ${id} status updated to ${status} by delivery boy ${deliveryBoyId}`);

      res.status(200).json({
        success: true,
        message: 'Delivery status updated successfully',
        data: {
          deliveryId: delivery.id,
          status: delivery.status,
          deliveredAt: delivery.deliveredAt
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
          as: 'assignedAreas',
          through: { attributes: [] }
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
}

module.exports = new DeliveryBoyController();

