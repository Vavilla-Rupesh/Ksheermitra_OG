const db = require('../config/db');
const logger = require('../utils/logger');
const whatsappService = require('./whatsapp.service');
const moment = require('moment');

class DeliveryService {
  async getAssignedDeliveries(deliveryBoyId, date) {
    try {
      const deliveryDate = date || moment().format('YYYY-MM-DD');

      const deliveries = await db.Delivery.findAll({
        where: {
          deliveryBoyId,
          deliveryDate,
          status: {
            [db.Sequelize.Op.in]: ['pending', 'delivered', 'missed']
          }
        },
        include: [
          {
            model: db.User,
            as: 'customer',
            attributes: ['id', 'name', 'phone', 'address', 'latitude', 'longitude']
          },
          {
            model: db.Product,
            as: 'product',
            attributes: ['id', 'name', 'unit', 'pricePerUnit']
          }
        ],
        order: [['createdAt', 'ASC']]
      });

      return deliveries;
    } catch (error) {
      logger.error('Error getting assigned deliveries:', error);
      throw error;
    }
  }

  async updateDeliveryStatus(deliveryId, status, deliveryBoyId, notes = '') {
    const transaction = await db.sequelize.transaction();
    
    try {
      const delivery = await db.Delivery.findByPk(deliveryId, {
        include: [
          {
            model: db.User,
            as: 'customer',
            attributes: ['id', 'name', 'phone']
          },
          {
            model: db.Product,
            as: 'product',
            attributes: ['id', 'name', 'unit']
          }
        ],
        transaction
      });

      if (!delivery) {
        throw new Error('Delivery not found');
      }

      if (delivery.deliveryBoyId !== deliveryBoyId) {
        throw new Error('Unauthorized to update this delivery');
      }

      const updates = {
        status,
        notes
      };

      if (status === 'delivered') {
        updates.deliveredAt = new Date();
      }

      await delivery.update(updates, { transaction });

      if (status === 'delivered' || status === 'missed') {
        await this.sendDeliveryNotification(delivery, status);
        delivery.notificationSent = true;
        await delivery.save({ transaction });
      }

      await transaction.commit();

      logger.info(`Delivery ${deliveryId} updated to ${status}`);
      return delivery;
    } catch (error) {
      await transaction.rollback();
      logger.error('Error updating delivery status:', error);
      throw error;
    }
  }

  async sendDeliveryNotification(delivery, status) {
    try {
      const products = [{
        name: delivery.product.name,
        quantity: delivery.quantity,
        unit: delivery.product.unit
      }];

      const date = moment(delivery.deliveryDate).format('DD-MM-YYYY');

      if (status === 'delivered') {
        await whatsappService.sendDeliveryConfirmation(
          delivery.customer.phone,
          delivery.customer.name,
          products,
          date
        );
      } else if (status === 'missed') {
        await whatsappService.sendDeliveryMissed(
          delivery.customer.phone,
          delivery.customer.name,
          products,
          date
        );
      }

      logger.info(`Notification sent for delivery ${delivery.id}`);
    } catch (error) {
      logger.error(`Error sending notification for delivery ${delivery.id}:`, error);
    }
  }

  async getDeliveryStats(deliveryBoyId, date) {
    try {
      const deliveryDate = date || moment().format('YYYY-MM-DD');

      const stats = await db.Delivery.findAll({
        where: {
          deliveryBoyId,
          deliveryDate
        },
        attributes: [
          'status',
          [db.sequelize.fn('COUNT', db.sequelize.col('id')), 'count'],
          [db.sequelize.fn('SUM', db.sequelize.col('amount')), 'totalAmount']
        ],
        group: ['status'],
        raw: true
      });

      const formattedStats = {
        pending: 0,
        delivered: 0,
        missed: 0,
        cancelled: 0,
        totalDelivered: 0,
        totalAmount: 0
      };

      stats.forEach(stat => {
        formattedStats[stat.status] = parseInt(stat.count);
        if (stat.status === 'delivered') {
          formattedStats.totalAmount = parseFloat(stat.totalAmount || 0);
          formattedStats.totalDelivered = parseInt(stat.count);
        }
      });

      return formattedStats;
    } catch (error) {
      logger.error('Error getting delivery stats:', error);
      throw error;
    }
  }

  async getCustomerDeliveryHistory(customerId, startDate, endDate) {
    try {
      const whereClause = {
        customerId,
        status: 'delivered'
      };

      if (startDate && endDate) {
        whereClause.deliveryDate = {
          [db.Sequelize.Op.between]: [startDate, endDate]
        };
      }

      const deliveries = await db.Delivery.findAll({
        where: whereClause,
        include: [
          {
            model: db.Product,
            as: 'product',
            attributes: ['id', 'name', 'unit', 'pricePerUnit']
          }
        ],
        order: [['deliveryDate', 'DESC']]
      });

      return deliveries;
    } catch (error) {
      logger.error('Error getting customer delivery history:', error);
      throw error;
    }
  }
}

module.exports = new DeliveryService();
