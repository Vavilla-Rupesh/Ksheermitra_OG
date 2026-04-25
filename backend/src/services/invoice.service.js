const db = require('../config/db');
const logger = require('../utils/logger');
const pdfService = require('./pdf.service');
const whatsappService = require('./whatsapp.service');
const moment = require('moment');

class InvoiceService {
  async generateDailyInvoice(deliveryBoyId, date) {
    const transaction = await db.sequelize.transaction();
    
    try {
      const deliveryDate = date || moment().format('YYYY-MM-DD');

      const deliveryBoy = await db.User.findByPk(deliveryBoyId, { transaction });
      if (!deliveryBoy || deliveryBoy.role !== 'delivery_boy') {
        throw new Error('Invalid delivery boy');
      }

      const deliveries = await db.Delivery.findAll({
        where: {
          deliveryBoyId,
          deliveryDate,
          status: 'delivered'
        },
        include: [
          {
            model: db.User,
            as: 'customer',
            attributes: ['id', 'name', 'phone']
          },
          {
            model: db.Product,
            as: 'product',
            attributes: ['id', 'name', 'unit'],
            required: false
          },
          {
            model: db.DeliveryItem,
            as: 'items',
            include: [{
              model: db.Product,
              as: 'product',
              attributes: ['name', 'unit'],
              required: false
            }],
            required: false
          }
        ],
        transaction
      });

      if (deliveries.length === 0) {
        throw new Error('No deliveries found for the specified date');
      }

      const totalAmount = deliveries.reduce((sum, d) => sum + parseFloat(d.amount || 0), 0);

      const invoiceNumber = `INV-D-${moment(deliveryDate).format('YYYYMMDD')}-${deliveryBoyId.substring(0, 8)}`;

      const existingInvoice = await db.Invoice.findOne({
        where: { invoiceNumber },
        transaction
      });

      if (existingInvoice) {
        throw new Error('Invoice already generated for this date');
      }

      // Build delivery details - handle both single product and multi-product (items) cases
      const deliveryDetails = deliveries.map(d => {
        const items = d.items || [];
        let productName = 'N/A';
        let quantity = parseFloat(d.quantity) || 0;
        let unit = '';

        if (items.length > 0) {
          productName = items.map(i => i.product?.name || 'Product').join(', ');
          quantity = items.reduce((sum, i) => sum + (parseFloat(i.quantity) || 0), 0);
          unit = items[0]?.product?.unit || '';
        } else if (d.product) {
          productName = d.product.name || 'N/A';
          unit = d.product.unit || '';
        }

        return {
          customerName: d.customer?.name || 'N/A',
          productName,
          quantity,
          unit,
          amount: parseFloat(d.amount) || 0
        };
      });

      const pdfData = {
        invoiceNumber,
        deliveryBoy: {
          name: deliveryBoy.name || 'Delivery Boy',
          phone: deliveryBoy.phone || 'N/A'
        },
        date: moment(deliveryDate).format('DD-MM-YYYY'),
        deliveries: deliveryDetails,
        totalAmount
      };

      let pdfPath = null;
      try {
        pdfPath = await pdfService.generateDailyInvoice(pdfData);
        logger.info(`PDF generated at: ${pdfPath}`);
      } catch (pdfError) {
        logger.error('Error generating PDF in invoice service:', pdfError.message);
      }

      const invoice = await db.Invoice.create({
        invoiceNumber,
        deliveryBoyId,
        invoiceType: 'daily',
        invoiceDate: deliveryDate,
        periodStart: deliveryDate,
        periodEnd: deliveryDate,
        totalAmount,
        paidAmount: 0,
        status: 'generated',
        pdfPath: pdfPath || null,
        metadata: {
          deliveries: deliveryDetails,
          deliveryBoyName: deliveryBoy.name
        }
      }, { transaction });

      const admin = await db.User.findOne({
        where: { role: 'admin', isActive: true },
        transaction
      });

      if (admin && admin.phone && pdfPath) {
        try {
          await whatsappService.sendInvoice(admin.phone, 'Admin', pdfPath);
          invoice.sentViaWhatsApp = true;
          invoice.sentAt = new Date();
          await invoice.save({ transaction });
        } catch (error) {
          logger.error('Error sending daily invoice via WhatsApp:', error.message);
        }
      }

      await transaction.commit();

      logger.info(`Daily invoice generated: ${invoiceNumber}`);
      return invoice;
    } catch (error) {
      await transaction.rollback();
      logger.error('Error generating daily invoice:', error.message);
      throw error;
    }
  }

  async generateMonthlyInvoice(customerId, year, month) {
    const transaction = await db.sequelize.transaction();
    
    try {
      const customer = await db.User.findByPk(customerId, { transaction });
      if (!customer || customer.role !== 'customer') {
        throw new Error('Invalid customer');
      }

      const periodStart = moment({ year, month: month - 1, day: 1 }).format('YYYY-MM-DD');
      const periodEnd = moment(periodStart).endOf('month').format('YYYY-MM-DD');

      const deliveries = await db.Delivery.findAll({
        where: {
          customerId,
          deliveryDate: {
            [db.Sequelize.Op.between]: [periodStart, periodEnd]
          },
          status: 'delivered'
        },
        include: [
          {
            model: db.Product,
            as: 'product',
            attributes: ['id', 'name', 'unit'],
            required: false
          }
        ],
        order: [['deliveryDate', 'ASC']],
        transaction
      });

      if (deliveries.length === 0) {
        logger.info(`No deliveries found for customer ${customerId} in ${month}/${year}`);
        return null;
      }

      const totalAmount = deliveries.reduce((sum, d) => sum + parseFloat(d.amount), 0);

      const invoiceNumber = `INV-M-${year}${month.toString().padStart(2, '0')}-${customerId.substring(0, 8)}`;

      const existingInvoice = await db.Invoice.findOne({
        where: { invoiceNumber },
        transaction
      });

      if (existingInvoice) {
        logger.info(`Invoice already exists: ${invoiceNumber}`);
        return existingInvoice;
      }

      const deliveryDetails = deliveries.map(d => ({
        date: moment(d.deliveryDate).format('DD-MM-YYYY'),
        productName: d.product?.name || 'N/A',
        quantity: parseFloat(d.quantity) || 0,
        unit: d.product?.unit || '',
        amount: parseFloat(d.amount) || 0
      }));

      const pdfData = {
        invoiceNumber,
        customer: {
          name: customer.name || 'N/A',
          phone: customer.phone || 'N/A',
          address: customer.address || 'N/A'
        },
        periodStart: moment(periodStart).format('DD-MM-YYYY'),
        periodEnd: moment(periodEnd).format('DD-MM-YYYY'),
        deliveries: deliveryDetails,
        totalAmount,
        paidAmount: 0,
        paymentStatus: 'pending'
      };

      let pdfPath = null;
      try {
        pdfPath = await pdfService.generateMonthlyInvoice(pdfData);
        logger.info(`Monthly PDF generated at: ${pdfPath}`);
      } catch (pdfError) {
        logger.error('Error generating monthly PDF:', pdfError.message);
      }

      const invoice = await db.Invoice.create({
        invoiceNumber,
        customerId,
        invoiceType: 'monthly',
        invoiceDate: moment().format('YYYY-MM-DD'),
        periodStart,
        periodEnd,
        totalAmount,
        paidAmount: 0,
        status: 'generated',
        pdfPath: pdfPath || null,
        metadata: {
          deliveries: deliveryDetails
        }
      }, { transaction });

      if (pdfPath && customer.phone) {
        try {
          await whatsappService.sendInvoice(customer.phone, customer.name, pdfPath);
          invoice.sentViaWhatsApp = true;
          invoice.sentAt = new Date();
          await invoice.save({ transaction });
        } catch (error) {
          logger.error('Error sending monthly invoice via WhatsApp:', error.message);
        }
      }

      await transaction.commit();

      logger.info(`Monthly invoice generated: ${invoiceNumber}`);
      return invoice;
    } catch (error) {
      await transaction.rollback();
      logger.error('Error generating monthly invoice:', error);
      throw error;
    }
  }

  async generateMonthlyInvoicesForAllCustomers() {
    try {
      const lastMonth = moment().subtract(1, 'month');
      const year = lastMonth.year();
      const month = lastMonth.month() + 1;

      logger.info(`Generating monthly invoices for ${month}/${year}`);

      const customers = await db.User.findAll({
        where: {
          role: 'customer',
          isActive: true
        }
      });

      const results = {
        total: customers.length,
        generated: 0,
        failed: 0,
        errors: []
      };

      for (const customer of customers) {
        try {
          const invoice = await this.generateMonthlyInvoice(customer.id, year, month);
          if (invoice) {
            results.generated++;
          }
          
          await new Promise(resolve => setTimeout(resolve, 3000));
        } catch (error) {
          results.failed++;
          results.errors.push({
            customerId: customer.id,
            customerName: customer.name,
            error: error.message
          });
          logger.error(`Error generating invoice for customer ${customer.id}:`, error);
        }
      }

      logger.info(`Monthly invoice generation complete:`, results);
      return results;
    } catch (error) {
      logger.error('Error generating monthly invoices for all customers:', error);
      throw error;
    }
  }

  async getCustomerInvoices(customerId) {
    try {
      const invoices = await db.Invoice.findAll({
        where: {
          customerId
        },
        order: [['invoiceDate', 'DESC']],
        include: [
          {
            model: db.User,
            as: 'customer',
            attributes: ['id', 'name', 'phone']
          }
        ]
      });

      return invoices;
    } catch (error) {
      logger.error('Error getting customer invoices:', error);
      throw error;
    }
  }

  async updatePaymentStatus(invoiceId, paidAmount) {
    const transaction = await db.sequelize.transaction();
    
    try {
      const invoice = await db.Invoice.findByPk(invoiceId, { transaction });
      
      if (!invoice) {
        throw new Error('Invoice not found');
      }

      const newPaidAmount = parseFloat(invoice.paidAmount) + parseFloat(paidAmount);
      const totalAmount = parseFloat(invoice.totalAmount);

      let paymentStatus = 'pending';
      if (newPaidAmount >= totalAmount) {
        paymentStatus = 'paid';
      } else if (newPaidAmount > 0) {
        paymentStatus = 'partial';
      }

      await invoice.update({
        paidAmount: newPaidAmount,
        paymentStatus
      }, { transaction });

      await transaction.commit();

      logger.info(`Payment updated for invoice ${invoiceId}`);
      return invoice;
    } catch (error) {
      await transaction.rollback();
      logger.error('Error updating payment status:', error);
      throw error;
    }
  }
}

module.exports = new InvoiceService();
