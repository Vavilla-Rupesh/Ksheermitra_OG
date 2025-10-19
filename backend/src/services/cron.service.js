const cron = require('node-cron');
const invoiceService = require('./invoice.service');
const logger = require('../utils/logger');

class CronService {
  start() {
    this.setupMonthlyInvoiceCron();
    logger.info('Cron jobs initialized');
  }

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
}

module.exports = new CronService();
