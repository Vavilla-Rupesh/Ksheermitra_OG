const db = require('../config/db');
const logger = require('../utils/logger');
const moment = require('moment');
const whatsappService = require('./whatsapp.service');

class SubscriptionService {
  async createSubscription(subscriptionData) {
    const transaction = await db.sequelize.transaction();
    
    try {
      const { customerId, products, frequency, selectedDays, startDate, endDate, autoRenewal } = subscriptionData;

      // Validate customer
      const customer = await db.User.findByPk(customerId, { transaction });
      if (!customer || customer.role !== 'customer') {
        throw new Error('Invalid customer');
      }

      // Validate products
      if (!products || products.length === 0) {
        throw new Error('At least one product is required');
      }

      // Create subscription
      const subscription = await db.Subscription.create({
        customerId,
        frequency,
        selectedDays,
        startDate,
        endDate,
        autoRenewal: autoRenewal || false,
        status: 'active'
      }, { transaction });

      // Create subscription products
      for (const productData of products) {
        const product = await db.Product.findByPk(productData.productId, { transaction });
        if (!product || !product.isActive) {
          throw new Error(`Product ${productData.productId} not available`);
        }

        await db.SubscriptionProduct.create({
          subscriptionId: subscription.id,
          productId: productData.productId,
          quantity: productData.quantity
        }, { transaction });
      }

      // Generate deliveries
      await this.generateDeliveriesForSubscription(subscription.id, transaction);

      await transaction.commit();

      // Send WhatsApp notification
      const subscriptionWithProducts = await this.getSubscriptionById(subscription.id);
      await this.sendSubscriptionCreatedNotification(subscriptionWithProducts);

      logger.info(`Multi-product subscription created: ${subscription.id}`);
      return subscriptionWithProducts;
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

      // Update subscription schedule if provided
      const scheduleFields = ['frequency', 'selectedDays', 'endDate', 'autoRenewal'];
      const scheduleUpdates = {};
      let scheduleChanged = false;

      for (const key of scheduleFields) {
        if (updateData[key] !== undefined) {
          scheduleUpdates[key] = updateData[key];
          scheduleChanged = true;
        }
      }

      if (Object.keys(scheduleUpdates).length > 0) {
        await subscription.update(scheduleUpdates, { transaction });
      }

      // Update products if provided
      if (updateData.products && updateData.products.length > 0) {
        // Delete existing subscription products
        await db.SubscriptionProduct.destroy({
          where: { subscriptionId: subscription.id },
          transaction
        });

        // Create new subscription products
        for (const productData of updateData.products) {
          await db.SubscriptionProduct.create({
            subscriptionId: subscription.id,
            productId: productData.productId,
            quantity: productData.quantity
          }, { transaction });
        }
      }

      // If schedule changed, regenerate future deliveries
      if (scheduleChanged) {
        await this.deleteFutureDeliveries(subscription.id, transaction);
        await this.generateDeliveriesForSubscription(subscription.id, transaction);
      } else if (updateData.products) {
        // Only products changed, update future delivery items
        await this.updateFutureDeliveryItems(subscription.id, transaction);
      }

      await transaction.commit();

      const updatedSubscription = await this.getSubscriptionById(subscriptionId);
      await this.sendSubscriptionUpdatedNotification(updatedSubscription);

      logger.info(`Subscription updated: ${subscriptionId}`);
      return updatedSubscription;
    } catch (error) {
      await transaction.rollback();
      logger.error('Error updating subscription:', error);
      throw error;
    }
  }

  async addProductsToSubscription(subscriptionId, products) {
    const transaction = await db.sequelize.transaction();

    try {
      const subscription = await db.Subscription.findByPk(subscriptionId, { transaction });
      if (!subscription) {
        throw new Error('Subscription not found');
      }

      // Add new products
      for (const productData of products) {
        const existing = await db.SubscriptionProduct.findOne({
          where: {
            subscriptionId: subscription.id,
            productId: productData.productId
          },
          transaction
        });

        if (!existing) {
          await db.SubscriptionProduct.create({
            subscriptionId: subscription.id,
            productId: productData.productId,
            quantity: productData.quantity
          }, { transaction });
        }
      }

      // Update future deliveries
      await this.updateFutureDeliveryItems(subscription.id, transaction);

      await transaction.commit();

      const updatedSubscription = await this.getSubscriptionById(subscriptionId);
      logger.info(`Products added to subscription: ${subscriptionId}`);
      return updatedSubscription;
    } catch (error) {
      await transaction.rollback();
      logger.error('Error adding products to subscription:', error);
      throw error;
    }
  }

  async removeProductFromSubscription(subscriptionId, productId) {
    const transaction = await db.sequelize.transaction();

    try {
      const productCount = await db.SubscriptionProduct.count({
        where: { subscriptionId },
        transaction
      });

      if (productCount <= 1) {
        throw new Error('Cannot remove last product. Cancel subscription instead.');
      }

      await db.SubscriptionProduct.destroy({
        where: {
          subscriptionId,
          productId
        },
        transaction
      });

      await this.updateFutureDeliveryItems(subscriptionId, transaction);

      await transaction.commit();

      const updatedSubscription = await this.getSubscriptionById(subscriptionId);
      logger.info(`Product removed from subscription: ${subscriptionId}`);
      return updatedSubscription;
    } catch (error) {
      await transaction.rollback();
      logger.error('Error removing product from subscription:', error);
      throw error;
    }
  }

  async updateTodayDelivery(subscriptionId, customerId, updates) {
    const transaction = await db.sequelize.transaction();

    try {
      const today = moment().format('YYYY-MM-DD');

      // Get today's delivery
      const delivery = await db.Delivery.findOne({
        where: {
          subscriptionId,
          customerId,
          deliveryDate: today,
          status: 'pending'
        },
        transaction
      });

      if (!delivery) {
        throw new Error('No pending delivery for today');
      }

      // Update delivery items
      if (updates.items) {
        // Delete existing items
        await db.DeliveryItem.destroy({
          where: { deliveryId: delivery.id },
          transaction
        });

        let totalAmount = 0;

        // Create updated items
        for (const item of updates.items) {
          const product = await db.Product.findByPk(item.productId);
          const itemPrice = parseFloat(item.quantity) * parseFloat(product.pricePerUnit);
          totalAmount += itemPrice;

          await db.DeliveryItem.create({
            deliveryId: delivery.id,
            productId: item.productId,
            quantity: item.quantity,
            price: itemPrice,
            isOneTime: item.isOneTime || false
          }, { transaction });
        }

        // Update delivery amount
        await delivery.update({ amount: totalAmount }, { transaction });
      }

      await transaction.commit();

      // Notify delivery boy
      await this.notifyDeliveryBoyOfChange(delivery);

      logger.info(`Today's delivery updated: ${delivery.id}`);
      return delivery;
    } catch (error) {
      await transaction.rollback();
      logger.error('Error updating today delivery:', error);
      throw error;
    }
  }

  async generateDeliveriesForSubscription(subscriptionId, transaction) {
    try {
      const subscription = await db.Subscription.findByPk(subscriptionId, {
        include: [{
          model: db.SubscriptionProduct,
          as: 'products',
          include: [{
            model: db.Product,
            as: 'product'
          }]
        }],
        transaction
      });

      if (!subscription) {
        throw new Error('Subscription not found');
      }

      if (!subscription.products || subscription.products.length === 0) {
        throw new Error('Subscription has no products');
      }

      const startDate = moment(subscription.startDate);
      const endDate = subscription.endDate ? moment(subscription.endDate) : moment(startDate).add(30, 'days');

      const customer = await db.User.findByPk(subscription.customerId, {
        include: [{
          model: db.Area,
          as: 'area',
          include: [{
            model: db.User,
            as: 'deliveryBoy'
          }]
        }],
        transaction
      });

      if (!customer.area || !customer.area.deliveryBoy) {
        logger.warn(`No delivery boy assigned for customer ${customer.id}. Subscription created but deliveries will be generated once area/delivery boy is assigned.`);
        // Don't throw error, just return - subscription is still valid
        return {
          subscriptionId,
          deliveriesGenerated: false,
          reason: 'No delivery boy assigned to customer area'
        };
      }

      const deliveryDates = this.getDeliveryDates(subscription, startDate, endDate);

      for (const date of deliveryDates) {
        const existingDelivery = await db.Delivery.findOne({
          where: {
            subscriptionId: subscription.id,
            deliveryDate: date
          },
          transaction
        });

        if (!existingDelivery) {
          // Calculate total amount from all products
          let totalAmount = 0;
          for (const sp of subscription.products) {
            const quantity = parseFloat(sp.quantity || 0);
            const pricePerUnit = parseFloat(sp.product.pricePerUnit || 0);
            const itemPrice = quantity * pricePerUnit;
            totalAmount += itemPrice;
          }

          // Ensure amount is never 0 for active subscriptions
          if (totalAmount <= 0) {
            logger.error(`Calculated amount is 0 for subscription ${subscriptionId}. Skipping delivery creation for ${date}`);
            continue;
          }

          // Create delivery (keeping old structure for compatibility)
          const delivery = await db.Delivery.create({
            customerId: subscription.customerId,
            deliveryBoyId: customer.area.deliveryBoy.id,
            subscriptionId: subscription.id,
            productId: subscription.products[0].productId, // For backward compatibility
            deliveryDate: date,
            quantity: subscription.products[0].quantity, // For backward compatibility
            amount: totalAmount,
            status: 'pending'
          }, { transaction });

          // Create delivery items for each product
          for (const sp of subscription.products) {
            const quantity = parseFloat(sp.quantity || 0);
            const pricePerUnit = parseFloat(sp.product.pricePerUnit || 0);
            const itemPrice = quantity * pricePerUnit;

            await db.DeliveryItem.create({
              deliveryId: delivery.id,
              productId: sp.productId,
              quantity: quantity,
              price: itemPrice,
              isOneTime: false
            }, { transaction });
          }

          logger.info(`Created delivery ${delivery.id} for ${date} with amount: ₹${totalAmount}`);
        }
      }

      logger.info(`Generated ${deliveryDates.length} deliveries for subscription ${subscriptionId}`);
      return {
        subscriptionId,
        deliveriesGenerated: true,
        deliveryCount: deliveryDates.length
      };
    } catch (error) {
      logger.error('Error generating deliveries:', error);
      throw error;
    }
  }

  getDeliveryDates(subscription, startDate, endDate) {
    const dates = [];
    let currentDate = startDate.clone();

    while (currentDate.isSameOrBefore(endDate) && dates.length < 365) {
      let shouldDeliver = false;

      if (subscription.frequency === 'daily') {
        shouldDeliver = true;
      } else if (subscription.frequency === 'weekly' || subscription.frequency === 'custom') {
        if (subscription.selectedDays && subscription.selectedDays.length > 0) {
          const dayOfWeek = currentDate.day();
          shouldDeliver = subscription.selectedDays.includes(dayOfWeek);
        }
      } else if (subscription.frequency === 'monthly') {
        shouldDeliver = currentDate.date() === startDate.date();
      } else if (subscription.frequency === 'daterange') {
        shouldDeliver = true;
      }

      if (shouldDeliver) {
        dates.push(currentDate.format('YYYY-MM-DD'));
      }

      currentDate.add(1, 'day');
    }

    return dates;
  }

  async deleteFutureDeliveries(subscriptionId, transaction) {
    const today = moment().format('YYYY-MM-DD');

    await db.Delivery.destroy({
      where: {
        subscriptionId,
        deliveryDate: { [db.Sequelize.Op.gt]: today },
        status: 'pending'
      },
      transaction
    });
  }

  async updateFutureDeliveryItems(subscriptionId, transaction) {
    const today = moment().format('YYYY-MM-DD');

    const subscription = await db.Subscription.findByPk(subscriptionId, {
      include: [{
        model: db.SubscriptionProduct,
        as: 'products',
        include: [{
          model: db.Product,
          as: 'product'
        }]
      }],
      transaction
    });

    const futureDeliveries = await db.Delivery.findAll({
      where: {
        subscriptionId,
        deliveryDate: { [db.Sequelize.Op.gt]: today },
        status: 'pending'
      },
      transaction
    });

    for (const delivery of futureDeliveries) {
      // Delete existing items
      await db.DeliveryItem.destroy({
        where: {
          deliveryId: delivery.id,
          isOneTime: false
        },
        transaction
      });

      let totalAmount = 0;

      // Create new items based on current subscription products
      for (const sp of subscription.products) {
        const itemPrice = parseFloat(sp.quantity) * parseFloat(sp.product.pricePerUnit);
        totalAmount += itemPrice;

        await db.DeliveryItem.create({
          deliveryId: delivery.id,
          productId: sp.productId,
          quantity: sp.quantity,
          price: itemPrice,
          isOneTime: false
        }, { transaction });
      }

      // Update delivery amount
      await delivery.update({ amount: totalAmount }, { transaction });
    }
  }

  async getActiveSubscriptions(customerId) {
    const subscriptions = await db.Subscription.findAll({
      where: {
        customerId,
        status: 'active'
      },
      include: [
        {
          model: db.SubscriptionProduct,
          as: 'products',
          include: [{
            model: db.Product,
            as: 'product'
          }]
        }
      ],
      order: [['createdAt', 'DESC']]
    });

    return subscriptions;
  }

  async getSubscriptionById(subscriptionId) {
    const subscription = await db.Subscription.findByPk(subscriptionId, {
      include: [
        {
          model: db.SubscriptionProduct,
          as: 'products',
          include: [{
            model: db.Product,
            as: 'product'
          }]
        },
        {
          model: db.User,
          as: 'customer',
          attributes: ['id', 'name', 'phone', 'address']
        }
      ]
    });

    return subscription;
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

      // Cancel deliveries in pause period
      await db.Delivery.update(
        { status: 'cancelled' },
        {
          where: {
            subscriptionId,
            deliveryDate: {
              [db.Sequelize.Op.between]: [pauseStartDate, pauseEndDate]
            },
            status: 'pending'
          },
          transaction
        }
      );

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

      await transaction.commit();

      logger.info(`Subscription resumed: ${subscriptionId}`);
      return subscription;
    } catch (error) {
      await transaction.rollback();
      logger.error('Error resuming subscription:', error);
      throw error;
    }
  }

  async cancelSubscription(subscriptionId) {
    const transaction = await db.sequelize.transaction();

    try {
      const subscription = await db.Subscription.findByPk(subscriptionId, { transaction });

      if (!subscription) {
        throw new Error('Subscription not found');
      }

      await subscription.update({ status: 'cancelled' }, { transaction });

      // Cancel all pending future deliveries
      const today = moment().format('YYYY-MM-DD');
      await db.Delivery.update(
        { status: 'cancelled' },
        {
          where: {
            subscriptionId,
            deliveryDate: { [db.Sequelize.Op.gte]: today },
            status: 'pending'
          },
          transaction
        }
      );

      await transaction.commit();

      logger.info(`Subscription cancelled: ${subscriptionId}`);
      return subscription;
    } catch (error) {
      await transaction.rollback();
      logger.error('Error cancelling subscription:', error);
      throw error;
    }
  }

  async sendSubscriptionCreatedNotification(subscription) {
    try {
      const productNames = subscription.products.map(sp =>
        `${sp.product.name} (${sp.quantity} ${sp.product.unit})`
      ).join(', ');

      const message = `✅ Subscription Created!\n\n` +
        `Products: ${productNames}\n` +
        `Schedule: ${subscription.frequency}\n` +
        `Start Date: ${moment(subscription.startDate).format('DD/MM/YYYY')}\n\n` +
        `Your deliveries will start as scheduled. Thank you for choosing Ksheermitra! 🥛`;

      await whatsappService.sendMessage(subscription.customer.phone, message);
    } catch (error) {
      logger.error('Error sending subscription notification:', error);
    }
  }

  async sendSubscriptionUpdatedNotification(subscription) {
    try {
      const message = `🔄 Subscription Updated!\n\n` +
        `Your subscription has been updated successfully.\n` +
        `Changes will apply from tomorrow onwards.\n\n` +
        `Thank you! 🥛`;

      await whatsappService.sendMessage(subscription.customer.phone, message);
    } catch (error) {
      logger.error('Error sending update notification:', error);
    }
  }

  async notifyDeliveryBoyOfChange(delivery) {
    try {
      const deliveryBoy = await db.User.findByPk(delivery.deliveryBoyId);
      const customer = await db.User.findByPk(delivery.customerId);

      const message = `⚠️ Order Updated!\n\n` +
        `Customer: ${customer.name}\n` +
        `Date: Today\n\n` +
        `The customer has updated today's order. Please check the details in the app.`;

      await whatsappService.sendMessage(deliveryBoy.phone, message);
    } catch (error) {
      logger.error('Error notifying delivery boy:', error);
    }
  }
}

module.exports = new SubscriptionService();
