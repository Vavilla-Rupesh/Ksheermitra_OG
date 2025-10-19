const db = require('../config/db');
const logger = require('../utils/logger');
const moment = require('moment');

class SubscriptionService {
  async createSubscription(subscriptionData) {
    const transaction = await db.sequelize.transaction();
    
    try {
      const { customerId, productId, quantity, frequency, selectedDays, startDate, endDate } = subscriptionData;

      const customer = await db.User.findByPk(customerId, { transaction });
      if (!customer || customer.role !== 'customer') {
        throw new Error('Invalid customer');
      }

      const product = await db.Product.findByPk(productId, { transaction });
      if (!product || !product.isActive) {
        throw new Error('Product not available');
      }

      const subscription = await db.Subscription.create({
        customerId,
        productId,
        quantity,
        frequency,
        selectedDays,
        startDate,
        endDate,
        status: 'active'
      }, { transaction });

      await this.generateDeliveriesForSubscription(subscription, transaction);

      await transaction.commit();

      logger.info(`Subscription created: ${subscription.id}`);
      return subscription;
    } catch (error) {
      await transaction.rollback();
      logger.error('Error creating subscription:', error);
      throw error;
    }
  }

  async updateSubscription(subscriptionId, updateData) {
    const transaction = await db.sequelize.transaction();
    
    try {
      const subscription = await db.Subscription.findByPk(subscriptionId, { transaction });
      
      if (!subscription) {
        throw new Error('Subscription not found');
      }

      const allowedUpdates = ['quantity', 'status', 'pauseStartDate', 'pauseEndDate', 'endDate', 'selectedDays'];
      const updates = {};
      
      for (const key of allowedUpdates) {
        if (updateData[key] !== undefined) {
          updates[key] = updateData[key];
        }
      }

      await subscription.update(updates, { transaction });

      if (updates.quantity || updates.selectedDays) {
        await this.updatePendingDeliveries(subscription, transaction);
      }

      await transaction.commit();

      logger.info(`Subscription updated: ${subscriptionId}`);
      return subscription;
    } catch (error) {
      await transaction.rollback();
      logger.error('Error updating subscription:', error);
      throw error;
    }
  }

  async generateDeliveriesForSubscription(subscription, transaction) {
    try {
      const startDate = moment(subscription.startDate);
      const endDate = subscription.endDate ? moment(subscription.endDate) : moment(startDate).add(1, 'year');
      const product = await db.Product.findByPk(subscription.productId);

      const customer = await db.User.findByPk(subscription.customerId, {
        include: [{
          model: db.Area,
          as: 'area',
          include: [{
            model: db.User,
            as: 'deliveryBoy'
          }]
        }]
      });

      if (!customer.area || !customer.area.deliveryBoy) {
        logger.warn(`No delivery boy assigned for customer ${customer.id}`);
        return;
      }

      const deliveries = [];
      let currentDate = startDate.clone();

      while (currentDate.isSameOrBefore(endDate) && deliveries.length < 365) {
        let shouldDeliver = false;

        if (subscription.frequency === 'daily') {
          shouldDeliver = true;
        } else if (subscription.frequency === 'weekly' && subscription.selectedDays && subscription.selectedDays.length > 0) {
          const dayOfWeek = currentDate.day();
          shouldDeliver = subscription.selectedDays.includes(dayOfWeek);
        } else if (subscription.frequency === 'monthly') {
          shouldDeliver = currentDate.date() === startDate.date();
        } else if (subscription.frequency === 'custom' && subscription.selectedDays && subscription.selectedDays.length > 0) {
          const dayOfWeek = currentDate.day();
          shouldDeliver = subscription.selectedDays.includes(dayOfWeek);
        }

        if (shouldDeliver) {
          const existingDelivery = await db.Delivery.findOne({
            where: {
              subscriptionId: subscription.id,
              deliveryDate: currentDate.format('YYYY-MM-DD')
            },
            transaction
          });

          if (!existingDelivery) {
            deliveries.push({
              customerId: subscription.customerId,
              deliveryBoyId: customer.area.deliveryBoy.id,
              subscriptionId: subscription.id,
              productId: subscription.productId,
              deliveryDate: currentDate.format('YYYY-MM-DD'),
              quantity: subscription.quantity,
              amount: parseFloat(subscription.quantity) * parseFloat(product.pricePerUnit),
              status: 'pending'
            });
          }
        }

        currentDate.add(1, 'day');
      }

      if (deliveries.length > 0) {
        await db.Delivery.bulkCreate(deliveries, { transaction });
        logger.info(`Generated ${deliveries.length} deliveries for subscription ${subscription.id}`);
      }
    } catch (error) {
      logger.error('Error generating deliveries:', error);
      throw error;
    }
  }

  async updatePendingDeliveries(subscription, transaction) {
    try {
      const product = await db.Product.findByPk(subscription.productId);

      await db.Delivery.update({
        quantity: subscription.quantity,
        amount: parseFloat(subscription.quantity) * parseFloat(product.pricePerUnit)
      }, {
        where: {
          subscriptionId: subscription.id,
          status: 'pending',
          deliveryDate: {
            [db.Sequelize.Op.gte]: moment().format('YYYY-MM-DD')
          }
        },
        transaction
      });

      logger.info(`Updated pending deliveries for subscription ${subscription.id}`);
    } catch (error) {
      logger.error('Error updating pending deliveries:', error);
      throw error;
    }
  }

  async getActiveSubscriptions(customerId) {
    try {
      const subscriptions = await db.Subscription.findAll({
        where: {
          customerId,
          status: 'active'
        },
        include: [{
          model: db.Product,
          as: 'product'
        }],
        order: [['createdAt', 'DESC']]
      });

      return subscriptions;
    } catch (error) {
      logger.error('Error getting active subscriptions:', error);
      throw error;
    }
  }

  async pauseSubscription(subscriptionId, pauseStartDate, pauseEndDate) {
    const transaction = await db.sequelize.transaction();
    
    try {
      const subscription = await db.Subscription.findByPk(subscriptionId, { transaction });
      
      if (!subscription) {
        throw new Error('Subscription not found');
      }

      await subscription.update({
        status: 'paused',
        pauseStartDate,
        pauseEndDate
      }, { transaction });

      await db.Delivery.update({
        status: 'cancelled'
      }, {
        where: {
          subscriptionId: subscription.id,
          status: 'pending',
          deliveryDate: {
            [db.Sequelize.Op.between]: [pauseStartDate, pauseEndDate]
          }
        },
        transaction
      });

      await transaction.commit();

      logger.info(`Subscription paused: ${subscriptionId}`);
      return subscription;
    } catch (error) {
      await transaction.rollback();
      logger.error('Error pausing subscription:', error);
      throw error;
    }
  }

  async resumeSubscription(subscriptionId) {
    const transaction = await db.sequelize.transaction();
    
    try {
      const subscription = await db.Subscription.findByPk(subscriptionId, { transaction });
      
      if (!subscription) {
        throw new Error('Subscription not found');
      }

      await subscription.update({
        status: 'active',
        pauseStartDate: null,
        pauseEndDate: null
      }, { transaction });

      await this.generateDeliveriesForSubscription(subscription, transaction);

      await transaction.commit();

      logger.info(`Subscription resumed: ${subscriptionId}`);
      return subscription;
    } catch (error) {
      await transaction.rollback();
      logger.error('Error resuming subscription:', error);
      throw error;
    }
  }
}

module.exports = new SubscriptionService();
