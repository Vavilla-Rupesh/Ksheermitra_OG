const cron = require('node-cron');
const invoiceService = require('./invoice.service');
const monthlyBreakoutService = require('./monthlyBreakout.service');
const db = require('../config/db');
const logger = require('../utils/logger');
const moment = require('moment');

class CronService {
  start() {
    this.setupMonthlyInvoiceCron();
    this.setupMonthlyBreakoutCron();
    this.setupDeliveryCleanupCron();
    logger.info('Cron jobs initialized');
  }

  /**
   * Generate monthly invoices on the 1st of every month at 7 AM
   * This will generate invoices for the previous month
   */
  setupMonthlyInvoiceCron() {
    const cronExpression = process.env.MONTHLY_INVOICE_CRON || '0 7 1 * *';
    
    cron.schedule(cronExpression, async () => {
      logger.info('Starting monthly invoice generation cron job');
      
      try {
        const results = await invoiceService.generateMonthlyInvoicesForAllCustomers();
        logger.info('Monthly invoice generation completed:', results);
      } catch (error) {
        logger.error('Error in monthly invoice cron job:', error);
      }
    }, {
      timezone: 'Asia/Kolkata'
    });

    logger.info(`Monthly invoice cron job scheduled: ${cronExpression}`);
  }

  /**
   * Auto-generate monthly breakouts for all active subscriptions
   * Runs on the last day of each month at 11 PM
   */
  setupMonthlyBreakoutCron() {
    // Run on last day of month at 11 PM
    const cronExpression = '0 23 28-31 * *';

    cron.schedule(cronExpression, async () => {
      const today = moment();
      const tomorrow = moment().add(1, 'day');

      // Only run if tomorrow is the first day of next month
      if (tomorrow.date() === 1) {
        logger.info('Starting monthly breakout summary generation');

        try {
          await this.generateMonthlyBreakoutSummaries();
          logger.info('Monthly breakout summaries generated successfully');
        } catch (error) {
          logger.error('Error generating monthly breakout summaries:', error);
        }
      }
    }, {
      timezone: 'Asia/Kolkata'
    });

    logger.info(`Monthly breakout cron job scheduled: ${cronExpression}`);
  }

  /**
   * Cleanup old pending deliveries and mark as missed
   * Runs daily at 2 AM
   */
  setupDeliveryCleanupCron() {
    const cronExpression = '0 2 * * *';

    cron.schedule(cronExpression, async () => {
      logger.info('Starting delivery cleanup cron job');

      try {
        const yesterday = moment().subtract(1, 'day').format('YYYY-MM-DD');

        const updated = await db.Delivery.update(
          { status: 'missed' },
          {
            where: {
              deliveryDate: {
                [db.Sequelize.Op.lt]: yesterday
              },
              status: 'pending'
            }
          }
        );

        logger.info(`Delivery cleanup completed: ${updated[0]} deliveries marked as missed`);
      } catch (error) {
        logger.error('Error in delivery cleanup cron job:', error);
      }
    }, {
      timezone: 'Asia/Kolkata'
    });

    logger.info(`Delivery cleanup cron job scheduled: ${cronExpression}`);
  }

  /**
   * Generate monthly breakout summaries for all customers
   */
  async generateMonthlyBreakoutSummaries() {
    try {
      const currentDate = moment();
      const year = currentDate.year();
      const month = currentDate.month() + 1;

      logger.info(`Generating monthly breakout summaries for ${month}/${year}`);

      const customers = await db.User.findAll({
        where: {
          role: 'customer',
          isActive: true
        },
        include: [{
          model: db.Subscription,
          as: 'subscriptions',
          where: {
            status: 'active'
          },
          required: false
        }]
      });

      const results = {
        total: customers.length,
        processed: 0,
        failed: 0
      };

      for (const customer of customers) {
        try {
          if (customer.subscriptions && customer.subscriptions.length > 0) {
            await monthlyBreakoutService.getCustomerMonthlyBreakouts(
              customer.id,
              year,
              month
            );
            results.processed++;
          }
        } catch (error) {
          results.failed++;
          logger.error(`Error generating breakout for customer ${customer.id}:`, error);
        }
      }

      logger.info('Monthly breakout summary generation complete:', results);
      return results;
    } catch (error) {
      logger.error('Error generating monthly breakout summaries:', error);
      throw error;
    }
  }
}

module.exports = new CronService();
