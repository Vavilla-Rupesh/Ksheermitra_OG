const db = require('../config/db');
const logger = require('../utils/logger');
const moment = require('moment');

class OfflineSaleService {
  /**
   * Create an offline sale
   * @param {Object} saleData - Sale data including adminId, items, customerName, customerPhone, paymentMethod, notes
   * @returns {Promise<Object>} Created sale with updated stock and invoice
   */
  async createOfflineSale(saleData) {
    const transaction = await db.sequelize.transaction();

    try {
      const { adminId, items, customerName, customerPhone, paymentMethod, notes } = saleData;
      const saleDate = moment().format('YYYY-MM-DD');

      // Validate admin
      const admin = await db.User.findOne({
        where: { id: adminId, role: 'admin', isActive: true },
        transaction
      });

      if (!admin) {
        throw new Error('Invalid or inactive admin user');
      }

      // Validate items and check stock
      if (!items || !Array.isArray(items) || items.length === 0) {
        throw new Error('At least one item is required for the sale');
      }

      let totalAmount = 0;
      const processedItems = [];

      for (const item of items) {
        const { productId, quantity } = item;

        if (!productId || !quantity || quantity <= 0) {
          throw new Error('Invalid product or quantity');
        }

        // Fetch product and check stock
        const product = await db.Product.findByPk(productId, { transaction });

        if (!product) {
          throw new Error(`Product not found: ${productId}`);
        }

        if (!product.isActive) {
          throw new Error(`Product is not active: ${product.name}`);
        }

        if (product.stock < quantity) {
          throw new Error(`Insufficient stock for ${product.name}. Available: ${product.stock}, Requested: ${quantity}`);
        }

        const itemAmount = parseFloat(product.pricePerUnit) * quantity;
        totalAmount += itemAmount;

        processedItems.push({
          productId: product.id,
          productName: product.name,
          quantity,
          unit: product.unit,
          pricePerUnit: parseFloat(product.pricePerUnit),
          amount: itemAmount
        });

        // Reduce stock
        await product.update(
          { stock: product.stock - quantity },
          { transaction }
        );

        logger.info(`Stock reduced for ${product.name}: ${product.stock + quantity} -> ${product.stock}`);
      }

      // Generate sale number
      const saleNumber = `SALE-${moment().format('YYYYMMDD-HHmmss')}-${adminId.substring(0, 6)}`;

      // Get or create admin daily invoice
      const invoice = await this.getOrCreateAdminDailyInvoice(adminId, saleDate, transaction);

      // Create offline sale record
      const offlineSale = await db.OfflineSale.create({
        saleNumber,
        saleDate,
        adminId,
        totalAmount,
        items: processedItems,
        customerName: customerName || null,
        customerPhone: customerPhone || null,
        paymentMethod: paymentMethod || 'cash',
        notes: notes || null,
        invoiceId: invoice.id
      }, { transaction });

      // Update invoice total amount
      await invoice.update(
        { totalAmount: parseFloat(invoice.totalAmount) + totalAmount },
        { transaction }
      );

      // Update metadata
      const metadata = invoice.metadata || { offlineSales: [] };
      if (!metadata.offlineSales) {
        metadata.offlineSales = [];
      }
      metadata.offlineSales.push({
        saleNumber,
        amount: totalAmount,
        items: processedItems,
        customerName: customerName || 'Walk-in Customer',
        timestamp: moment().format('YYYY-MM-DD HH:mm:ss')
      });

      await invoice.update({ metadata }, { transaction });

      await transaction.commit();

      logger.info(`Offline sale created: ${saleNumber}, Total: ${totalAmount}`);

      // Return complete sale data
      const completeSale = await db.OfflineSale.findByPk(offlineSale.id, {
        include: [
          {
            model: db.User,
            as: 'admin',
            attributes: ['id', 'name', 'phone']
          },
          {
            model: db.Invoice,
            as: 'invoice',
            attributes: ['id', 'invoiceNumber', 'totalAmount']
          }
        ]
      });

      return completeSale;
    } catch (error) {
      await transaction.rollback();
      logger.error('Error creating offline sale:', error);
      throw error;
    }
  }

  /**
   * Get or create admin daily invoice for offline sales
   * @param {string} adminId - Admin user ID
   * @param {string} date - Date in YYYY-MM-DD format
   * @param {Object} transaction - Database transaction
   * @returns {Promise<Object>} Invoice object
   */
  async getOrCreateAdminDailyInvoice(adminId, date, transaction) {
    const invoiceNumber = `INV-ADMIN-${moment(date).format('YYYYMMDD')}`;

    let invoice = await db.Invoice.findOne({
      where: { invoiceNumber },
      transaction
    });

    if (!invoice) {
      invoice = await db.Invoice.create({
        invoiceNumber,
        invoiceType: 'admin_daily',
        invoiceDate: date,
        periodStart: date,
        periodEnd: date,
        totalAmount: 0,
        paidAmount: 0,
        status: 'pending',
        metadata: {
          offlineSales: [],
          description: 'Daily In-Store Sales Invoice'
        }
      }, { transaction });

      logger.info(`Created admin daily invoice: ${invoiceNumber}`);
    }

    return invoice;
  }

  /**
   * Get offline sales with filters
   * @param {Object} filters - startDate, endDate, adminId
   * @returns {Promise<Array>} List of offline sales
   */
  async getOfflineSales(filters = {}) {
    try {
      const { startDate, endDate, adminId, page = 1, limit = 50 } = filters;
      const offset = (page - 1) * limit;

      const whereClause = {};

      if (startDate && endDate) {
        whereClause.saleDate = {
          [db.Sequelize.Op.between]: [startDate, endDate]
        };
      } else if (startDate) {
        whereClause.saleDate = {
          [db.Sequelize.Op.gte]: startDate
        };
      } else if (endDate) {
        whereClause.saleDate = {
          [db.Sequelize.Op.lte]: endDate
        };
      }

      if (adminId) {
        whereClause.adminId = adminId;
      }

      const { count, rows } = await db.OfflineSale.findAndCountAll({
        where: whereClause,
        include: [
          {
            model: db.User,
            as: 'admin',
            attributes: ['id', 'name', 'phone']
          },
          {
            model: db.Invoice,
            as: 'invoice',
            attributes: ['id', 'invoiceNumber', 'totalAmount', 'status']
          }
        ],
        order: [['saleDate', 'DESC'], ['createdAt', 'DESC']],
        limit: parseInt(limit),
        offset: parseInt(offset)
      });

      return {
        sales: rows,
        pagination: {
          total: count,
          page: parseInt(page),
          limit: parseInt(limit),
          totalPages: Math.ceil(count / limit)
        }
      };
    } catch (error) {
      logger.error('Error getting offline sales:', error);
      throw error;
    }
  }

  /**
   * Get offline sale by ID
   * @param {string} saleId - Sale ID
   * @returns {Promise<Object>} Sale object
   */
  async getOfflineSaleById(saleId) {
    try {
      const sale = await db.OfflineSale.findByPk(saleId, {
        include: [
          {
            model: db.User,
            as: 'admin',
            attributes: ['id', 'name', 'phone', 'email']
          },
          {
            model: db.Invoice,
            as: 'invoice',
            attributes: ['id', 'invoiceNumber', 'totalAmount', 'status', 'invoiceDate']
          }
        ]
      });

      if (!sale) {
        throw new Error('Offline sale not found');
      }

      return sale;
    } catch (error) {
      logger.error('Error getting offline sale by ID:', error);
      throw error;
    }
  }

  /**
   * Get sales statistics
   * @param {string} startDate - Start date
   * @param {string} endDate - End date
   * @returns {Promise<Object>} Statistics
   */
  async getSalesStats(startDate, endDate) {
    try {
      const whereClause = {};

      if (startDate && endDate) {
        whereClause.saleDate = {
          [db.Sequelize.Op.between]: [startDate, endDate]
        };
      }

      const stats = await db.OfflineSale.findAll({
        where: whereClause,
        attributes: [
          [db.Sequelize.fn('COUNT', db.Sequelize.col('id')), 'totalSales'],
          [db.Sequelize.fn('SUM', db.Sequelize.col('totalAmount')), 'totalRevenue'],
          [db.Sequelize.fn('AVG', db.Sequelize.col('totalAmount')), 'averageSaleAmount']
        ],
        raw: true
      });

      return stats[0] || {
        totalSales: 0,
        totalRevenue: 0,
        averageSaleAmount: 0
      };
    } catch (error) {
      logger.error('Error getting sales stats:', error);
      throw error;
    }
  }

  /**
   * Get admin daily invoice with offline sales
   * @param {string} date - Date in YYYY-MM-DD format
   * @returns {Promise<Object>} Invoice with sales
   */
  async getAdminDailyInvoice(date) {
    try {
      const invoiceNumber = `INV-ADMIN-${moment(date).format('YYYYMMDD')}`;

      const invoice = await db.Invoice.findOne({
        where: { invoiceNumber },
        include: [
          {
            model: db.OfflineSale,
            as: 'offlineSales',
            include: [
              {
                model: db.User,
                as: 'admin',
                attributes: ['id', 'name', 'phone']
              }
            ]
          }
        ]
      });

      return invoice;
    } catch (error) {
      logger.error('Error getting admin daily invoice:', error);
      throw error;
    }
  }
}

module.exports = new OfflineSaleService();

