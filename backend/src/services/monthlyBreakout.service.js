const db = require('../config/db');
const logger = require('../utils/logger');
const moment = require('moment');

class MonthlyBreakoutService {
  /**
   * Generate complete monthly breakout for a subscription
   * Creates entries for all days of the month with products and pricing
   */
  async generateMonthlyBreakout(subscriptionId, year, month) {
    try {
      const subscription = await db.Subscription.findByPk(subscriptionId, {
        include: [{
          model: db.SubscriptionProduct,
          as: 'products',
          include: [{
            model: db.Product,
            as: 'product'
          }]
        }]
      });

      if (!subscription) {
        throw new Error('Subscription not found');
      }

      const paddedMonth = String(month).padStart(2, '0');
      const startDate = moment(`${year}-${paddedMonth}-01`, 'YYYY-MM-DD').startOf('month');
      const endDate = moment(`${year}-${paddedMonth}-01`, 'YYYY-MM-DD').endOf('month');
      const daysInMonth = endDate.date();

      const breakout = [];

      // Generate entry for each day of the month
      for (let day = 1; day <= daysInMonth; day++) {
        const currentDate = moment(`${year}-${paddedMonth}-${String(day).padStart(2, '0')}`, 'YYYY-MM-DD');

        // Check if this day is included in the subscription
        const isDeliveryDay = this.isDeliveryDay(subscription, currentDate);

        if (isDeliveryDay) {
          let dailyAmount = 0;
          const products = [];

          // Calculate amount for each product
          for (const subProduct of subscription.products) {
            const quantity = parseFloat(subProduct.quantity);
            const pricePerUnit = parseFloat(subProduct.product.pricePerUnit);
            const price = quantity * pricePerUnit;
            dailyAmount += price;

            products.push({
              productId: subProduct.productId,
              productName: subProduct.product.name,
              quantity,
              pricePerUnit,
              price,
              unit: subProduct.product.unit
            });
          }

          breakout.push({
            date: currentDate.format('YYYY-MM-DD'),
            dayOfWeek: currentDate.format('dddd'),
            products,
            amount: dailyAmount,
            isEditable: currentDate.isAfter(moment().startOf('day'))
          });
        }
      }

      return {
        subscriptionId,
        year: parseInt(year),
        month: parseInt(month),
        monthName: startDate.format('MMMM YYYY'),
        breakout,
        totalAmount: breakout.reduce((sum, day) => sum + day.amount, 0),
        deliveryDays: breakout.length
      };
    } catch (error) {
      logger.error('Error generating monthly breakout:', error);
      throw error;
    }
  }

  /**
   * Check if a given date is a delivery day based on subscription frequency
   */
  isDeliveryDay(subscription, date) {
    const momentDate = moment(date);
    const startDate = moment(subscription.startDate);
    const endDate = subscription.endDate ? moment(subscription.endDate) : null;

    // Check if date is within subscription period
    if (momentDate.isBefore(startDate, 'day')) {
      return false;
    }
    if (endDate && momentDate.isAfter(endDate, 'day')) {
      return false;
    }

    // Check if subscription is paused
    if (subscription.status === 'paused' && subscription.pauseStartDate && subscription.pauseEndDate) {
      const pauseStart = moment(subscription.pauseStartDate);
      const pauseEnd = moment(subscription.pauseEndDate);
      if (momentDate.isBetween(pauseStart, pauseEnd, 'day', '[]')) {
        return false;
      }
    }

    // Check frequency
    switch (subscription.frequency) {
      case 'daily':
        return true;
      case 'weekly':
        if (subscription.selectedDays && subscription.selectedDays.length > 0) {
          return subscription.selectedDays.includes(momentDate.day());
        }
        return false;
      case 'custom':
        if (subscription.selectedDays && subscription.selectedDays.length > 0) {
          return subscription.selectedDays.includes(momentDate.day());
        }
        return false;
      case 'monthly':
        // For monthly subscriptions, deliver on the same day of month as start date
        return momentDate.date() === startDate.date();
      default:
        return false;
    }
  }

  /**
   * Get monthly breakout for a subscription
   * Shows all deliveries for a specific month with products and amounts
   */
  async getMonthlyBreakout(subscriptionId, customerId, year, month) {
    try {
      // Validate subscription belongs to customer
      const subscription = await db.Subscription.findOne({
        where: {
          id: subscriptionId,
          customerId
        }
      });

      if (!subscription) {
        throw new Error('Subscription not found or unauthorized');
      }

      // Get start and end date of the month - ensure month is zero-padded
      const paddedMonth = String(month).padStart(2, '0');
      const startDate = moment(`${year}-${paddedMonth}-01`, 'YYYY-MM-DD').startOf('month');
      const endDate = moment(`${year}-${paddedMonth}-01`, 'YYYY-MM-DD').endOf('month');

      // Get all deliveries for this month
      const deliveries = await db.Delivery.findAll({
        where: {
          subscriptionId,
          deliveryDate: {
            [db.Sequelize.Op.between]: [
              startDate.format('YYYY-MM-DD'),
              endDate.format('YYYY-MM-DD')
            ]
          }
        },
        include: [
          {
            model: db.DeliveryItem,
            as: 'items',
            include: [{
              model: db.Product,
              as: 'product',
              attributes: ['id', 'name', 'pricePerUnit', 'unit']
            }]
          }
        ],
        order: [['deliveryDate', 'ASC']]
      });

      // Calculate totals
      let totalAmount = 0;
      let deliveredAmount = 0;
      let pendingAmount = 0;

      const breakout = deliveries.map(delivery => {
        // Calculate amount from delivery.amount or sum of delivery items if amount is null/zero
        let amount = parseFloat(delivery.amount) || 0;

        // If delivery amount is 0 or null, calculate from items
        if (amount === 0 && delivery.items && delivery.items.length > 0) {
          amount = delivery.items.reduce((sum, item) => {
            const itemPrice = parseFloat(item.price) || 0;
            return sum + itemPrice;
          }, 0);
        }

        totalAmount += amount;

        if (delivery.status === 'delivered') {
          deliveredAmount += amount;
        } else if (delivery.status === 'pending') {
          pendingAmount += amount;
        }

        return {
          id: delivery.id,
          date: delivery.deliveryDate,
          dayOfWeek: moment(delivery.deliveryDate).format('dddd'),
          status: delivery.status,
          amount: amount,
          items: delivery.items.map(item => ({
            id: item.id,
            productId: item.productId,
            productName: item.product.name,
            quantity: parseFloat(item.quantity),
            price: parseFloat(item.price),
            unit: item.product.unit,
            pricePerUnit: parseFloat(item.product.pricePerUnit),
            isOneTime: item.isOneTime
          })),
          deliveredAt: delivery.deliveredAt,
          notes: delivery.notes,
          isEditable: moment(delivery.deliveryDate).isAfter(moment().startOf('day')) && delivery.status === 'pending'
        };
      });

      return {
        subscriptionId,
        year: parseInt(year),
        month: parseInt(month),
        monthName: startDate.format('MMMM YYYY'),
        periodStart: startDate.format('YYYY-MM-DD'),
        periodEnd: endDate.format('YYYY-MM-DD'),
        totalAmount,
        deliveredAmount,
        pendingAmount,
        cancelledAmount: totalAmount - deliveredAmount - pendingAmount,
        deliveryCount: deliveries.length,
        deliveredCount: deliveries.filter(d => d.status === 'delivered').length,
        pendingCount: deliveries.filter(d => d.status === 'pending').length,
        breakout
      };
    } catch (error) {
      logger.error('Error getting monthly breakout:', error);
      throw error;
    }
  }

  /**
   * Get all monthly breakouts for a customer
   */
  async getCustomerMonthlyBreakouts(customerId, year, month) {
    try {
      const subscriptions = await db.Subscription.findAll({
        where: {
          customerId,
          status: 'active'
        },
        include: [{
          model: db.SubscriptionProduct,
          as: 'products',
          include: [{
            model: db.Product,
            as: 'product'
          }]
        }]
      });

      const breakouts = await Promise.all(
        subscriptions.map(sub =>
          this.getMonthlyBreakout(sub.id, customerId, year, month)
        )
      );

      const totalAmount = breakouts.reduce((sum, b) => sum + b.totalAmount, 0);
      const deliveredAmount = breakouts.reduce((sum, b) => sum + b.deliveredAmount, 0);
      const pendingAmount = breakouts.reduce((sum, b) => sum + b.pendingAmount, 0);

      return {
        customerId,
        year: parseInt(year),
        month: parseInt(month),
        monthName: moment(`${year}-${String(month).padStart(2, '0')}-01`, 'YYYY-MM-DD').format('MMMM YYYY'),
        totalAmount,
        deliveredAmount,
        pendingAmount,
        subscriptionCount: subscriptions.length,
        subscriptions: breakouts
      };
    } catch (error) {
      logger.error('Error getting customer monthly breakouts:', error);
      throw error;
    }
  }

  /**
   * Modify products for a specific delivery date
   * Allows customers to change products for future deliveries
   */
  async modifyDeliveryProducts(deliveryId, customerId, products) {
    const transaction = await db.sequelize.transaction();

    try {
      // Get delivery and validate
      const delivery = await db.Delivery.findOne({
        where: { id: deliveryId },
        include: [{
          model: db.Subscription,
          as: 'subscription'
        }],
        transaction
      });

      if (!delivery) {
        throw new Error('Delivery not found');
      }

      if (delivery.subscription.customerId !== customerId) {
        throw new Error('Unauthorized');
      }

      // Check if delivery date is in the future or today
      const deliveryDate = moment(delivery.deliveryDate);
      const today = moment().startOf('day');

      if (deliveryDate.isBefore(today)) {
        throw new Error('Cannot modify past deliveries');
      }

      if (delivery.status !== 'pending') {
        throw new Error('Can only modify pending deliveries');
      }

      // Delete existing delivery items
      await db.DeliveryItem.destroy({
        where: { deliveryId: delivery.id },
        transaction
      });

      let totalAmount = 0;

      // Create new delivery items
      for (const productData of products) {
        const product = await db.Product.findByPk(productData.productId, { transaction });

        if (!product) {
          throw new Error(`Product ${productData.productId} not found`);
        }

        const quantity = parseFloat(productData.quantity);
        const price = quantity * parseFloat(product.pricePerUnit);
        totalAmount += price;

        await db.DeliveryItem.create({
          deliveryId: delivery.id,
          productId: productData.productId,
          quantity,
          price,
          isOneTime: productData.isOneTime || false
        }, { transaction });
      }

      // Update delivery amount
      await delivery.update({ amount: totalAmount }, { transaction });

      await transaction.commit();

      // Return updated delivery
      const updatedDelivery = await db.Delivery.findByPk(deliveryId, {
        include: [{
          model: db.DeliveryItem,
          as: 'items',
          include: [{
            model: db.Product,
            as: 'product'
          }]
        }]
      });

      logger.info(`Delivery products modified: ${deliveryId}`);
      return updatedDelivery;
    } catch (error) {
      await transaction.rollback();
      logger.error('Error modifying delivery products:', error);
      throw error;
    }
  }

  /**
   * Generate monthly invoice for customer
   * Automatically calculates total from all deliveries in the month
   */
  async generateMonthlyInvoice(customerId, year, month) {
    const transaction = await db.sequelize.transaction();

    try {
      const paddedMonth = String(month).padStart(2, '0');
      const startDate = moment(`${year}-${paddedMonth}-01`, 'YYYY-MM-DD').startOf('month');
      const endDate = moment(`${year}-${paddedMonth}-01`, 'YYYY-MM-DD').endOf('month');

      // Check if invoice already exists
      const existingInvoice = await db.Invoice.findOne({
        where: {
          customerId,
          type: 'monthly',
          periodStart: startDate.format('YYYY-MM-DD'),
          periodEnd: endDate.format('YYYY-MM-DD')
        },
        transaction
      });

      if (existingInvoice) {
        throw new Error('Invoice already exists for this month');
      }

      // Get all deliveries for the month
      const deliveries = await db.Delivery.findAll({
        where: {
          customerId,
          deliveryDate: {
            [db.Sequelize.Op.between]: [
              startDate.format('YYYY-MM-DD'),
              endDate.format('YYYY-MM-DD')
            ]
          },
          status: {
            [db.Sequelize.Op.in]: ['delivered', 'pending']
          }
        },
        include: [{
          model: db.DeliveryItem,
          as: 'items',
          include: [{
            model: db.Product,
            as: 'product'
          }]
        }, {
          model: db.Subscription,
          as: 'subscription',
          include: [{
            model: db.SubscriptionProduct,
            as: 'products',
            include: [{
              model: db.Product,
              as: 'product'
            }]
          }]
        }],
        transaction
      });

      if (deliveries.length === 0) {
        throw new Error('No deliveries found for this month');
      }

      // Calculate total amount - handle null or zero delivery amounts
      const totalAmount = deliveries.reduce((sum, d) => {
        let amount = parseFloat(d.amount) || 0;
        // If delivery amount is 0 or null, calculate from items
        if (amount === 0 && d.items && d.items.length > 0) {
          amount = d.items.reduce((itemSum, item) => {
            return itemSum + (parseFloat(item.price) || 0);
          }, 0);
        }
        return sum + amount;
      }, 0);

      // Generate invoice number
      const invoiceNumber = await this.generateInvoiceNumber(year, month);

      // Create delivery details for invoice
      const deliveryDetails = deliveries.map(d => {
        let amount = parseFloat(d.amount) || 0;
        // If delivery amount is 0 or null, calculate from items
        if (amount === 0 && d.items && d.items.length > 0) {
          amount = d.items.reduce((itemSum, item) => {
            return itemSum + (parseFloat(item.price) || 0);
          }, 0);
        }

        return {
          date: d.deliveryDate,
          status: d.status,
          amount: amount,
          items: d.items.map(item => ({
            productName: item.product.name,
            quantity: parseFloat(item.quantity),
            price: parseFloat(item.price),
            unit: item.product.unit
          }))
        };
      });

      // Create invoice
      const invoice = await db.Invoice.create({
        invoiceNumber,
        customerId,
        type: 'monthly',
        invoiceDate: moment().format('YYYY-MM-DD'),
        periodStart: startDate.format('YYYY-MM-DD'),
        periodEnd: endDate.format('YYYY-MM-DD'),
        totalAmount,
        paidAmount: 0,
        paymentStatus: 'pending',
        deliveryDetails
      }, { transaction });

      await transaction.commit();

      logger.info(`Monthly invoice generated: ${invoice.id} for customer ${customerId}`);
      return invoice;
    } catch (error) {
      await transaction.rollback();
      logger.error('Error generating monthly invoice:', error);
      throw error;
    }
  }

  /**
   * Generate unique invoice number
   */
  async generateInvoiceNumber(year, month) {
    const prefix = `INV-${year}${month.toString().padStart(2, '0')}`;

    const lastInvoice = await db.Invoice.findOne({
      where: {
        invoiceNumber: {
          [db.Sequelize.Op.like]: `${prefix}%`
        }
      },
      order: [['createdAt', 'DESC']]
    });

    let sequence = 1;
    if (lastInvoice) {
      const lastSequence = parseInt(lastInvoice.invoiceNumber.split('-')[2]);
      sequence = lastSequence + 1;
    }

    return `${prefix}-${sequence.toString().padStart(4, '0')}`;
  }

  /**
   * Get monthly invoice for customer
   */
  async getMonthlyInvoice(customerId, year, month) {
    try {
      const paddedMonth = String(month).padStart(2, '0');
      const startDate = moment(`${year}-${paddedMonth}-01`, 'YYYY-MM-DD').startOf('month');
      const endDate = moment(`${year}-${paddedMonth}-01`, 'YYYY-MM-DD').endOf('month');

      const invoice = await db.Invoice.findOne({
        where: {
          customerId,
          type: 'monthly',
          periodStart: startDate.format('YYYY-MM-DD'),
          periodEnd: endDate.format('YYYY-MM-DD')
        },
        include: [{
          model: db.User,
          as: 'customer',
          attributes: ['id', 'name', 'phone', 'address']
        }]
      });

      return invoice;
    } catch (error) {
      logger.error('Error getting monthly invoice:', error);
      throw error;
    }
  }
}

module.exports = new MonthlyBreakoutService();
