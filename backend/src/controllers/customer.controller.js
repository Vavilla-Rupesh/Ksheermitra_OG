const subscriptionService = require('../services/subscription.service');
const deliveryService = require('../services/delivery.service');
const invoiceService = require('../services/invoice.service');
const db = require('../config/db');
const logger = require('../utils/logger');

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
}

module.exports = new CustomerController();
