const subscriptionService = require('../services/subscription.service');
const deliveryService = require('../services/delivery.service');
const invoiceService = require('../services/invoice.service');
const db = require('../config/db');
const logger = require('../utils/logger');
const monthlyBreakoutService = require('../services/monthlyBreakout.service');

class CustomerController {
  async getProfile(req, res, next) {
    try {
      const userId = req.user.id;

      const user = await db.User.findByPk(userId, {
        attributes: { exclude: ['passwordHash'] },
        include: [{
          model: db.Area,
          as: 'area'
        }]
      });

      res.status(200).json({
        success: true,
        data: user
      });
    } catch (error) {
      logger.error('Error getting profile:', error);
      next(error);
    }
  }

  async updateProfile(req, res, next) {
    try {
      const userId = req.user.id;
      const { name, email, address, latitude, longitude } = req.body;

      const user = await db.User.findByPk(userId);
      
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User not found'
        });
      }

      const updates = {};
      if (name !== undefined) updates.name = name;
      if (email !== undefined) updates.email = email;
      if (address !== undefined) updates.address = address;
      if (latitude !== undefined) updates.latitude = latitude;
      if (longitude !== undefined) updates.longitude = longitude;

      await user.update(updates);

      res.status(200).json({
        success: true,
        message: 'Profile updated successfully',
        data: user
      });
    } catch (error) {
      logger.error('Error updating profile:', error);
      next(error);
    }
  }

  async createSubscription(req, res, next) {
    try {
      const customerId = req.user.id;
      const subscriptionData = {
        customerId,
        ...req.body
      };

      const subscription = await subscriptionService.createSubscription(subscriptionData);

      res.status(201).json({
        success: true,
        message: 'Subscription created successfully',
        data: subscription
      });
    } catch (error) {
      logger.error('Error creating subscription:', error);
      next(error);
    }
  }

  async getSubscriptions(req, res, next) {
    try {
      const customerId = req.user.id;

      const subscriptions = await subscriptionService.getActiveSubscriptions(customerId);

      res.status(200).json({
        success: true,
        data: subscriptions
      });
    } catch (error) {
      logger.error('Error getting subscriptions:', error);
      next(error);
    }
  }

  async updateSubscription(req, res, next) {
    try {
      const { id } = req.params;
      const customerId = req.user.id;

      const subscription = await db.Subscription.findByPk(id);
      
      if (!subscription) {
        return res.status(404).json({
          success: false,
          message: 'Subscription not found'
        });
      }

      if (subscription.customerId !== customerId) {
        return res.status(403).json({
          success: false,
          message: 'Unauthorized'
        });
      }

      const updatedSubscription = await subscriptionService.updateSubscription(id, req.body);

      res.status(200).json({
        success: true,
        message: 'Subscription updated successfully',
        data: updatedSubscription
      });
    } catch (error) {
      logger.error('Error updating subscription:', error);
      next(error);
    }
  }

  async pauseSubscription(req, res, next) {
    try {
      const { id } = req.params;
      const customerId = req.user.id;
      const { pauseStartDate, pauseEndDate } = req.body;

      const subscription = await db.Subscription.findByPk(id);
      
      if (!subscription) {
        return res.status(404).json({
          success: false,
          message: 'Subscription not found'
        });
      }

      if (subscription.customerId !== customerId) {
        return res.status(403).json({
          success: false,
          message: 'Unauthorized'
        });
      }

      const pausedSubscription = await subscriptionService.pauseSubscription(id, pauseStartDate, pauseEndDate);

      res.status(200).json({
        success: true,
        message: 'Subscription paused successfully',
        data: pausedSubscription
      });
    } catch (error) {
      logger.error('Error pausing subscription:', error);
      next(error);
    }
  }

  async resumeSubscription(req, res, next) {
    try {
      const { id } = req.params;
      const customerId = req.user.id;

      const subscription = await db.Subscription.findByPk(id);
      
      if (!subscription) {
        return res.status(404).json({
          success: false,
          message: 'Subscription not found'
        });
      }

      if (subscription.customerId !== customerId) {
        return res.status(403).json({
          success: false,
          message: 'Unauthorized'
        });
      }

      const resumedSubscription = await subscriptionService.resumeSubscription(id);

      res.status(200).json({
        success: true,
        message: 'Subscription resumed successfully',
        data: resumedSubscription
      });
    } catch (error) {
      logger.error('Error resuming subscription:', error);
      next(error);
    }
  }

  async cancelSubscription(req, res, next) {
    try {
      const { id } = req.params;
      const customerId = req.user.id;

      const subscription = await db.Subscription.findByPk(id);

      if (!subscription) {
        return res.status(404).json({
          success: false,
          message: 'Subscription not found'
        });
      }

      if (subscription.customerId !== customerId) {
        return res.status(403).json({
          success: false,
          message: 'Unauthorized'
        });
      }

      const cancelledSubscription = await subscriptionService.cancelSubscription(id);

      res.status(200).json({
        success: true,
        message: 'Subscription cancelled successfully',
        data: cancelledSubscription
      });
    } catch (error) {
      logger.error('Error cancelling subscription:', error);
      next(error);
    }
  }

  async getSubscriptionDetails(req, res, next) {
    try {
      const { id } = req.params;
      const customerId = req.user.id;

      const subscription = await subscriptionService.getSubscriptionById(id);

      if (!subscription) {
        return res.status(404).json({
          success: false,
          message: 'Subscription not found'
        });
      }

      if (subscription.customerId !== customerId) {
        return res.status(403).json({
          success: false,
          message: 'Unauthorized'
        });
      }

      res.status(200).json({
        success: true,
        data: subscription
      });
    } catch (error) {
      logger.error('Error getting subscription details:', error);
      next(error);
    }
  }

  async addProductsToSubscription(req, res, next) {
    try {
      const { id } = req.params;
      const customerId = req.user.id;
      const { products } = req.body;

      const subscription = await db.Subscription.findByPk(id);

      if (!subscription) {
        return res.status(404).json({
          success: false,
          message: 'Subscription not found'
        });
      }

      if (subscription.customerId !== customerId) {
        return res.status(403).json({
          success: false,
          message: 'Unauthorized'
        });
      }

      const updatedSubscription = await subscriptionService.addProductsToSubscription(id, products);

      res.status(200).json({
        success: true,
        message: 'Products added to subscription successfully',
        data: updatedSubscription
      });
    } catch (error) {
      logger.error('Error adding products to subscription:', error);
      next(error);
    }
  }

  async removeProductFromSubscription(req, res, next) {
    try {
      const { id, productId } = req.params;
      const customerId = req.user.id;

      const subscription = await db.Subscription.findByPk(id);

      if (!subscription) {
        return res.status(404).json({
          success: false,
          message: 'Subscription not found'
        });
      }

      if (subscription.customerId !== customerId) {
        return res.status(403).json({
          success: false,
          message: 'Unauthorized'
        });
      }

      const updatedSubscription = await subscriptionService.removeProductFromSubscription(id, productId);

      res.status(200).json({
        success: true,
        message: 'Product removed from subscription successfully',
        data: updatedSubscription
      });
    } catch (error) {
      logger.error('Error removing product from subscription:', error);
      next(error);
    }
  }

  async updateTodayDelivery(req, res, next) {
    try {
      const { id } = req.params;
      const customerId = req.user.id;

      const subscription = await db.Subscription.findByPk(id);

      if (!subscription) {
        return res.status(404).json({
          success: false,
          message: 'Subscription not found'
        });
      }

      if (subscription.customerId !== customerId) {
        return res.status(403).json({
          success: false,
          message: 'Unauthorized'
        });
      }

      const updatedDelivery = await subscriptionService.updateTodayDelivery(id, customerId, req.body);

      res.status(200).json({
        success: true,
        message: 'Today\'s delivery updated successfully',
        data: updatedDelivery
      });
    } catch (error) {
      logger.error('Error updating today delivery:', error);
      next(error);
    }
  }

  async getDeliveryHistory(req, res, next) {
    try {
      const customerId = req.user.id;
      const { startDate, endDate } = req.query;

      const deliveries = await deliveryService.getCustomerDeliveryHistory(customerId, startDate, endDate);

      res.status(200).json({
        success: true,
        data: deliveries
      });
    } catch (error) {
      logger.error('Error getting delivery history:', error);
      next(error);
    }
  }

  async getInvoices(req, res, next) {
    try {
      const customerId = req.user.id;

      const invoices = await invoiceService.getCustomerInvoices(customerId);

      res.status(200).json({
        success: true,
        data: invoices
      });
    } catch (error) {
      logger.error('Error getting invoices:', error);
      next(error);
    }
  }

  async getProducts(req, res, next) {
    try {
      const products = await db.Product.findAll({
        where: {
          isActive: true
        },
        order: [['name', 'ASC']]
      });

      res.status(200).json({
        success: true,
        data: products
      });
    } catch (error) {
      logger.error('Error getting products:', error);
      next(error);
    }
  }

  // Monthly breakout endpoints
  async getSubscriptionMonthlyBreakout(req, res, next) {
    try {
      const { id } = req.params;
      const customerId = req.user.id;
      const { year, month } = req.query;

      const currentDate = new Date();
      const breakoutYear = year || currentDate.getFullYear();
      const breakoutMonth = month || (currentDate.getMonth() + 1);

      const breakout = await monthlyBreakoutService.getMonthlyBreakout(
        id,
        customerId,
        breakoutYear,
        breakoutMonth
      );

      res.status(200).json({
        success: true,
        data: breakout
      });
    } catch (error) {
      logger.error('Error getting subscription monthly breakout:', error);
      next(error);
    }
  }

  async getCustomerMonthlyBreakout(req, res, next) {
    try {
      const customerId = req.user.id;
      const { year, month } = req.params;

      const breakout = await monthlyBreakoutService.getCustomerMonthlyBreakouts(
        customerId,
        year,
        month
      );

      res.status(200).json({
        success: true,
        data: breakout
      });
    } catch (error) {
      logger.error('Error getting customer monthly breakout:', error);
      next(error);
    }
  }

  async modifyDeliveryProducts(req, res, next) {
    try {
      const { id } = req.params;
      const customerId = req.user.id;
      const { products } = req.body;

      const delivery = await monthlyBreakoutService.modifyDeliveryProducts(
        id,
        customerId,
        products
      );

      res.status(200).json({
        success: true,
        message: 'Delivery products updated successfully',
        data: delivery
      });
    } catch (error) {
      logger.error('Error modifying delivery products:', error);
      next(error);
    }
  }

  async generateMonthlyInvoice(req, res, next) {
    try {
      const customerId = req.user.id;
      const { year, month } = req.params;

      const invoice = await monthlyBreakoutService.generateMonthlyInvoice(
        customerId,
        year,
        month
      );

      res.status(201).json({
        success: true,
        message: 'Monthly invoice generated successfully',
        data: invoice
      });
    } catch (error) {
      logger.error('Error generating monthly invoice:', error);
      next(error);
    }
  }

  async getMonthlyInvoice(req, res, next) {
    try {
      const customerId = req.user.id;
      const { year, month } = req.params;

      const invoice = await monthlyBreakoutService.getMonthlyInvoice(
        customerId,
        year,
        month
      );

      if (!invoice) {
        return res.status(404).json({
          success: false,
          message: 'Invoice not found for this month'
        });
      }

      res.status(200).json({
        success: true,
        data: invoice
      });
    } catch (error) {
      logger.error('Error getting monthly invoice:', error);
      next(error);
    }
  }
}

module.exports = new CustomerController();
