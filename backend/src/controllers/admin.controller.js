const db = require('../config/db');
const logger = require('../utils/logger');
const mapsService = require('../services/maps.service');

class AdminController {
  async getCustomers(req, res, next) {
    try {
      const { page = 1, limit = 50, search } = req.query;
      const offset = (page - 1) * limit;

      const whereClause = {
        role: 'customer'
      };

      if (search) {
        whereClause[db.Sequelize.Op.or] = [
          { name: { [db.Sequelize.Op.iLike]: `%${search}%` } },
          { phone: { [db.Sequelize.Op.iLike]: `%${search}%` } }
        ];
      }

      const { count, rows } = await db.User.findAndCountAll({
        where: whereClause,
        attributes: { exclude: ['passwordHash'] },
        include: [{
          model: db.Area,
          as: 'area',
          include: [{
            model: db.User,
            as: 'deliveryBoy',
            attributes: ['id', 'name', 'phone']
          }]
        }],
        limit: parseInt(limit),
        offset: parseInt(offset),
        order: [['name', 'ASC']]
      });

      res.status(200).json({
        success: true,
        data: {
          customers: rows,
          pagination: {
            total: count,
            page: parseInt(page),
            limit: parseInt(limit),
            totalPages: Math.ceil(count / limit)
          }
        }
      });
    } catch (error) {
      logger.error('Error getting customers:', error);
      next(error);
    }
  }

  async getCustomersWithLocations(req, res, next) {
    try {
      const customers = await db.User.findAll({
        where: {
          role: 'customer',
          latitude: { [db.Sequelize.Op.ne]: null },
          longitude: { [db.Sequelize.Op.ne]: null }
        },
        attributes: ['id', 'name', 'phone', 'address', 'latitude', 'longitude', 'areaId'],
        include: [{
          model: db.Area,
          as: 'area',
          attributes: ['id', 'name']
        }]
      });

      res.status(200).json({
        success: true,
        data: customers
      });
    } catch (error) {
      logger.error('Error getting customers with locations:', error);
      next(error);
    }
  }

  async getCustomerDetails(req, res, next) {
    try {
      const { id } = req.params;

      const customer = await db.User.findOne({
        where: {
          id,
          role: 'customer'
        },
        attributes: { exclude: ['passwordHash'] },
        include: [
          {
            model: db.Area,
            as: 'area',
            include: [{
              model: db.User,
              as: 'deliveryBoy',
              attributes: ['id', 'name', 'phone']
            }]
          },
          {
            model: db.Subscription,
            as: 'subscriptions',
            include: [{
              model: db.SubscriptionProduct,
              as: 'products',
              include: [{
                model: db.Product,
                as: 'product'
              }]
            }]
          }
        ]
      });

      if (!customer) {
        return res.status(404).json({
          success: false,
          message: 'Customer not found'
        });
      }

      res.status(200).json({
        success: true,
        data: customer
      });
    } catch (error) {
      logger.error('Error getting customer details:', error);
      next(error);
    }
  }

  async getDeliveryBoys(req, res, next) {
    try {
      const deliveryBoys = await db.User.findAll({
        where: {
          role: 'delivery_boy',
          isActive: true
        },
        attributes: { exclude: ['passwordHash'] },
        include: [{
          model: db.Area,
          as: 'area',
          foreignKey: 'deliveryBoyId'
        }]
      });

      res.status(200).json({
        success: true,
        data: deliveryBoys
      });
    } catch (error) {
      logger.error('Error getting delivery boys:', error);
      next(error);
    }
  }

  async createDeliveryBoy(req, res, next) {
    try {
      const { name, phone, email, address, latitude, longitude } = req.body;

      const existingUser = await db.User.findOne({ where: { phone } });
      
      if (existingUser) {
        return res.status(409).json({
          success: false,
          message: 'Phone number already registered'
        });
      }

      const deliveryBoy = await db.User.create({
        name,
        phone,
        email,
        address,
        latitude,
        longitude,
        role: 'delivery_boy',
        isActive: true
      });

      const deliveryBoyData = deliveryBoy.toJSON();
      delete deliveryBoyData.passwordHash;

      res.status(201).json({
        success: true,
        message: 'Delivery boy created successfully',
        data: deliveryBoyData
      });
    } catch (error) {
      logger.error('Error creating delivery boy:', error);
      next(error);
    }
  }

  async updateDeliveryBoy(req, res, next) {
    try {
      const { id } = req.params;
      const { name, phone, email, address, latitude, longitude, isActive } = req.body;

      const deliveryBoy = await db.User.findOne({
        where: { id, role: 'delivery_boy' }
      });

      if (!deliveryBoy) {
        return res.status(404).json({
          success: false,
          message: 'Delivery boy not found'
        });
      }

      // Check if phone is being changed and if it's already taken
      if (phone && phone !== deliveryBoy.phone) {
        const existingUser = await db.User.findOne({ where: { phone } });
        if (existingUser) {
          return res.status(409).json({
            success: false,
            message: 'Phone number already in use'
          });
        }
      }

      await deliveryBoy.update({
        name: name || deliveryBoy.name,
        phone: phone || deliveryBoy.phone,
        email: email || deliveryBoy.email,
        address: address || deliveryBoy.address,
        latitude: latitude !== undefined ? latitude : deliveryBoy.latitude,
        longitude: longitude !== undefined ? longitude : deliveryBoy.longitude,
        isActive: isActive !== undefined ? isActive : deliveryBoy.isActive
      });

      const deliveryBoyData = deliveryBoy.toJSON();
      delete deliveryBoyData.passwordHash;

      res.status(200).json({
        success: true,
        message: 'Delivery boy updated successfully',
        data: deliveryBoyData
      });
    } catch (error) {
      logger.error('Error updating delivery boy:', error);
      next(error);
    }
  }

  async deleteDeliveryBoy(req, res, next) {
    const transaction = await db.sequelize.transaction();

    try {
      const { id } = req.params;

      const deliveryBoy = await db.User.findOne({
        where: { id, role: 'delivery_boy' },
        transaction
      });

      if (!deliveryBoy) {
        await transaction.rollback();
        return res.status(404).json({
          success: false,
          message: 'Delivery boy not found'
        });
      }

      // Check if delivery boy has assigned area
      const area = await db.Area.findOne({
        where: { deliveryBoyId: id },
        transaction
      });

      if (area) {
        // Unassign the area
        await area.update({ deliveryBoyId: null }, { transaction });
      }

      // Soft delete
      await deliveryBoy.update({ isActive: false }, { transaction });

      await transaction.commit();

      res.status(200).json({
        success: true,
        message: 'Delivery boy deactivated successfully'
      });
    } catch (error) {
      await transaction.rollback();
      logger.error('Error deleting delivery boy:', error);
      next(error);
    }
  }

  async assignArea(req, res, next) {
    const transaction = await db.sequelize.transaction();
    
    try {
      const { customerId, areaId } = req.body;

      const customer = await db.User.findByPk(customerId, { transaction });
      
      if (!customer || customer.role !== 'customer') {
        await transaction.rollback();
        return res.status(404).json({
          success: false,
          message: 'Customer not found'
        });
      }

      const area = await db.Area.findByPk(areaId, { transaction });
      
      if (!area) {
        await transaction.rollback();
        return res.status(404).json({
          success: false,
          message: 'Area not found'
        });
      }

      await customer.update({ areaId }, { transaction });

      await transaction.commit();

      logger.info(`Assigned customer ${customerId} to area ${areaId}`);

      res.status(200).json({
        success: true,
        message: 'Area assigned successfully',
        data: customer
      });
    } catch (error) {
      await transaction.rollback();
      logger.error('Error assigning area:', error);
      next(error);
    }
  }

  async bulkAssignArea(req, res, next) {
    const transaction = await db.sequelize.transaction();
    
    try {
      const { customerIds, areaId } = req.body;

      const area = await db.Area.findByPk(areaId, { transaction });
      
      if (!area) {
        await transaction.rollback();
        return res.status(404).json({
          success: false,
          message: 'Area not found'
        });
      }

      await db.User.update(
        { areaId },
        {
          where: {
            id: { [db.Sequelize.Op.in]: customerIds },
            role: 'customer'
          },
          transaction
        }
      );

      await transaction.commit();

      logger.info(`Bulk assigned ${customerIds.length} customers to area ${areaId}`);

      res.status(200).json({
        success: true,
        message: `${customerIds.length} customers assigned successfully`
      });
    } catch (error) {
      await transaction.rollback();
      logger.error('Error in bulk assign area:', error);
      next(error);
    }
  }

  async getAreas(req, res, next) {
    try {
      const areas = await db.Area.findAll({
        include: [
          {
            model: db.User,
            as: 'deliveryBoy',
            attributes: ['id', 'name', 'phone']
          },
          {
            model: db.User,
            as: 'customers',
            attributes: ['id', 'name', 'phone']
          }
        ],
        order: [['name', 'ASC']]
      });

      res.status(200).json({
        success: true,
        data: areas
      });
    } catch (error) {
      logger.error('Error getting areas:', error);
      next(error);
    }
  }

  async createArea(req, res, next) {
    try {
      const { name, description, boundaries, centerLatitude, centerLongitude, mapLink } = req.body;

      const existingArea = await db.Area.findOne({ where: { name } });

      if (existingArea) {
        return res.status(409).json({
          success: false,
          message: 'Area with this name already exists'
        });
      }

      const area = await db.Area.create({
        name,
        description,
        boundaries, // GeoJSON polygon
        centerLatitude,
        centerLongitude,
        mapLink,
        isActive: true
      });

      res.status(201).json({
        success: true,
        message: 'Area created successfully',
        data: area
      });
    } catch (error) {
      logger.error('Error creating area:', error);
      next(error);
    }
  }

  async updateArea(req, res, next) {
    try {
      const { id } = req.params;
      const { name, description, boundaries, centerLatitude, centerLongitude, mapLink, isActive } = req.body;

      const area = await db.Area.findByPk(id);

      if (!area) {
        return res.status(404).json({
          success: false,
          message: 'Area not found'
        });
      }

      // Check if name is being changed and if it's already taken
      if (name && name !== area.name) {
        const existingArea = await db.Area.findOne({ where: { name } });
        if (existingArea) {
          return res.status(409).json({
            success: false,
            message: 'Area name already in use'
          });
        }
      }

      await area.update({
        name: name || area.name,
        description: description !== undefined ? description : area.description,
        boundaries: boundaries || area.boundaries,
        centerLatitude: centerLatitude !== undefined ? centerLatitude : area.centerLatitude,
        centerLongitude: centerLongitude !== undefined ? centerLongitude : area.centerLongitude,
        mapLink: mapLink !== undefined ? mapLink : area.mapLink,
        isActive: isActive !== undefined ? isActive : area.isActive
      });

      res.status(200).json({
        success: true,
        message: 'Area updated successfully',
        data: area
      });
    } catch (error) {
      logger.error('Error updating area:', error);
      next(error);
    }
  }

  async getDailyInvoices(req, res, next) {
    try {
      const { startDate, endDate, deliveryBoyId } = req.query;

      const whereClause = {
        type: 'daily'
      };

      if (startDate && endDate) {
        whereClause.invoiceDate = {
          [db.Sequelize.Op.between]: [startDate, endDate]
        };
      }

      if (deliveryBoyId) {
        whereClause.deliveryBoyId = deliveryBoyId;
      }

      const invoices = await db.Invoice.findAll({
        where: whereClause,
        include: [{
          model: db.User,
          as: 'deliveryBoy',
          attributes: ['id', 'name', 'phone']
        }],
        order: [['invoiceDate', 'DESC']]
      });

      res.status(200).json({
        success: true,
        data: invoices
      });
    } catch (error) {
      logger.error('Error getting daily invoices:', error);
      next(error);
    }
  }

  async getMonthlyInvoices(req, res, next) {
    try {
      const { startDate, endDate, customerId } = req.query;

      const whereClause = {
        type: 'monthly'
      };

      if (startDate && endDate) {
        whereClause.invoiceDate = {
          [db.Sequelize.Op.between]: [startDate, endDate]
        };
      }

      if (customerId) {
        whereClause.customerId = customerId;
      }

      const invoices = await db.Invoice.findAll({
        where: whereClause,
        include: [{
          model: db.User,
          as: 'customer',
          attributes: ['id', 'name', 'phone', 'address']
        }],
        order: [['invoiceDate', 'DESC']]
      });

      res.status(200).json({
        success: true,
        data: invoices
      });
    } catch (error) {
      logger.error('Error getting monthly invoices:', error);
      next(error);
    }
  }

  async updateInvoicePaymentStatus(req, res, next) {
    try {
      const { id } = req.params;
      const { paymentStatus, paidAmount, paymentMethod, transactionId, notes } = req.body;

      const invoice = await db.Invoice.findByPk(id);

      if (!invoice) {
        return res.status(404).json({
          success: false,
          message: 'Invoice not found'
        });
      }

      const updates = {};
      if (paymentStatus !== undefined) updates.paymentStatus = paymentStatus;
      if (paidAmount !== undefined) updates.paidAmount = paidAmount;
      if (paymentMethod !== undefined) updates.paymentMethod = paymentMethod;
      if (transactionId !== undefined) updates.transactionId = transactionId;
      if (notes !== undefined) updates.notes = notes;

      await invoice.update(updates);

      res.status(200).json({
        success: true,
        message: 'Invoice payment status updated successfully',
        data: invoice
      });
    } catch (error) {
      logger.error('Error updating invoice payment status:', error);
      next(error);
    }
  }

  // New methods for enhanced delivery boy management


  async assignAreaWithMap(req, res, next) {
    const whatsappService = require('../services/whatsapp.service');
    const transaction = await db.sequelize.transaction();

    try {
      const {
        areaId,
        deliveryBoyId,
        boundaries,
        centerLatitude,
        centerLongitude,
        mapLink
      } = req.body;

      const area = await db.Area.findByPk(areaId, { transaction });

      if (!area) {
        await transaction.rollback();
        return res.status(404).json({
          success: false,
          message: 'Area not found'
        });
      }

      const deliveryBoy = await db.User.findOne({
        where: { id: deliveryBoyId, role: 'delivery_boy' },
        transaction
      });

      if (!deliveryBoy) {
        await transaction.rollback();
        return res.status(404).json({
          success: false,
          message: 'Delivery boy not found'
        });
      }

      // Check if delivery boy is already assigned to another area
      const existingArea = await db.Area.findOne({
        where: {
          deliveryBoyId,
          id: { [db.Sequelize.Op.ne]: areaId }
        },
        transaction
      });

      if (existingArea) {
        await transaction.rollback();
        return res.status(409).json({
          success: false,
          message: 'Delivery boy is already assigned to another area'
        });
      }

      // Update area with delivery boy and map data
      await area.update({
        deliveryBoyId,
        boundaries,
        centerLatitude,
        centerLongitude,
        mapLink
      }, { transaction });

      // Count customers in this area
      const customerCount = await db.User.count({
        where: { areaId, role: 'customer' },
        transaction
      });

      await transaction.commit();

      // Send WhatsApp notification to delivery boy
      try {
        const message = `🎯 *Area Assignment*\n\n` +
          `Hello ${deliveryBoy.name}!\n\n` +
          `You have been assigned to: *${area.name}*\n` +
          `📍 Customers in area: ${customerCount}\n\n` +
          `${mapLink ? `🗺️ View Map: ${mapLink}\n\n` : ''}` +
          `You can now view your assigned deliveries in the app.\n\n` +
          `For support, contact admin.`;

        await whatsappService.sendMessage(deliveryBoy.phone, message);
        logger.info(`WhatsApp notification sent to delivery boy ${deliveryBoyId} for area assignment`);
      } catch (whatsappError) {
        logger.error('Error sending WhatsApp notification:', whatsappError);
        // Don't fail the request if WhatsApp fails
      }

      res.status(200).json({
        success: true,
        message: 'Area assigned successfully and notification sent',
        data: {
          area,
          deliveryBoy,
          customerCount
        }
      });
    } catch (error) {
      await transaction.rollback();
      logger.error('Error assigning area with map:', error);
      next(error);
    }
  }

  async updateAreaBoundaries(req, res, next) {
    try {
      const { id } = req.params;
      const { boundaries, centerLatitude, centerLongitude, mapLink } = req.body;

      const area = await db.Area.findByPk(id);

      if (!area) {
        return res.status(404).json({
          success: false,
          message: 'Area not found'
        });
      }

      await area.update({
        boundaries,
        centerLatitude,
        centerLongitude,
        mapLink
      });

      res.status(200).json({
        success: true,
        message: 'Area boundaries updated successfully',
        data: area
      });
    } catch (error) {
      logger.error('Error updating area boundaries:', error);
      next(error);
    }
  }

  async getDeliveryBoyDetails(req, res, next) {
    try {
      const { id } = req.params;

      const deliveryBoy = await db.User.findOne({
        where: { id, role: 'delivery_boy' },
        attributes: { exclude: ['passwordHash'] },
        include: [
          {
            model: db.Area,
            as: 'area',
            foreignKey: 'deliveryBoyId',
            include: [{
              model: db.User,
              as: 'customers',
              attributes: ['id', 'name', 'phone', 'address']
            }]
          }
        ]
      });

      if (!deliveryBoy) {
        return res.status(404).json({
          success: false,
          message: 'Delivery boy not found'
        });
      }

      // Get delivery statistics
      const today = new Date().toISOString().split('T')[0];
      const deliveryStats = await db.Delivery.findAll({
        where: {
          deliveryBoyId: id,
          deliveryDate: today
        },
        attributes: [
          [db.Sequelize.fn('COUNT', db.Sequelize.col('id')), 'totalDeliveries'],
          [db.Sequelize.fn('SUM', db.Sequelize.literal("CASE WHEN status = 'delivered' THEN 1 ELSE 0 END")), 'completedDeliveries'],
          [db.Sequelize.fn('SUM', db.Sequelize.literal("CASE WHEN status = 'pending' THEN 1 ELSE 0 END")), 'pendingDeliveries'],
          [db.Sequelize.fn('SUM', db.Sequelize.col('amount')), 'totalAmount']
        ],
        raw: true
      });

      res.status(200).json({
        success: true,
        data: {
          deliveryBoy,
          stats: deliveryStats[0] || {
            totalDeliveries: 0,
            completedDeliveries: 0,
            pendingDeliveries: 0,
            totalAmount: 0
          }
        }
      });
    } catch (error) {
      logger.error('Error getting delivery boy details:', error);
      next(error);
    }
  }

  async getAreaWithCustomers(req, res, next) {
    try {
      const { id } = req.params;

      const area = await db.Area.findByPk(id, {
        include: [
          {
            model: db.User,
            as: 'deliveryBoy',
            attributes: ['id', 'name', 'phone', 'email']
          },
          {
            model: db.User,
            as: 'customers',
            attributes: ['id', 'name', 'phone', 'address', 'latitude', 'longitude'],
            where: { isActive: true },
            required: false
          }
        ]
      });

      if (!area) {
        return res.status(404).json({
          success: false,
          message: 'Area not found'
        });
      }

      res.status(200).json({
        success: true,
        data: area
      });
    } catch (error) {
      logger.error('Error getting area with customers:', error);
      next(error);
    }
  }

  async getDashboardStats(req, res, next) {
    try {
      const today = new Date().toISOString().split('T')[0];

      // Total customers
      const totalCustomers = await db.User.count({
        where: { role: 'customer', isActive: true }
      });

      // Total delivery boys
      const totalDeliveryBoys = await db.User.count({
        where: { role: 'delivery_boy', isActive: true }
      });

      // Active subscriptions
      const activeSubscriptions = await db.Subscription.count({
        where: { status: 'active' }
      });

      // Today's deliveries
      const todayDeliveries = await db.Delivery.findAll({
        where: { deliveryDate: today },
        attributes: [
          [db.Sequelize.fn('COUNT', db.Sequelize.col('id')), 'total'],
          [db.Sequelize.fn('SUM', db.Sequelize.literal("CASE WHEN status = 'delivered' THEN 1 ELSE 0 END")), 'delivered'],
          [db.Sequelize.fn('SUM', db.Sequelize.literal("CASE WHEN status = 'pending' THEN 1 ELSE 0 END")), 'pending'],
          [db.Sequelize.fn('SUM', db.Sequelize.col('amount')), 'totalAmount']
        ],
        raw: true
      });

      // Total areas
      const totalAreas = await db.Area.count({
        where: { isActive: true }
      });

      res.status(200).json({
        success: true,
        data: {
          totalCustomers,
          totalDeliveryBoys,
          activeSubscriptions,
          totalAreas,
          todayDeliveries: todayDeliveries[0] || {
            total: 0,
            delivered: 0,
            pending: 0,
            totalAmount: 0
          }
        }
      });
    } catch (error) {
      logger.error('Error getting dashboard stats:', error);
      next(error);
    }
  }

  async getProducts(req, res, next) {
    try {
      const products = await db.Product.findAll({
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

  async createProduct(req, res, next) {
    try {
      const { name, description, unit, pricePerUnit, stock } = req.body;

      // Handle image upload
      let imageUrl = null;
      if (req.file) {
        // Store relative path from uploads directory
        imageUrl = `/uploads/products/${req.file.filename}`;
      }

      const product = await db.Product.create({
        name,
        description,
        unit,
        pricePerUnit,
        stock: stock || 0,
        imageUrl,
        isActive: true
      });

      res.status(201).json({
        success: true,
        message: 'Product created successfully',
        data: product
      });
    } catch (error) {
      logger.error('Error creating product:', error);
      next(error);
    }
  }

  async updateProduct(req, res, next) {
    try {
      const { id } = req.params;
      const { name, description, unit, pricePerUnit, stock, isActive } = req.body;

      const product = await db.Product.findByPk(id);

      if (!product) {
        return res.status(404).json({
          success: false,
          message: 'Product not found'
        });
      }

      const updates = {};
      if (name !== undefined) updates.name = name;
      if (description !== undefined) updates.description = description;
      if (unit !== undefined) updates.unit = unit;
      if (pricePerUnit !== undefined) updates.pricePerUnit = pricePerUnit;
      if (stock !== undefined) updates.stock = stock;
      if (isActive !== undefined) updates.isActive = isActive;

      // Handle image upload
      if (req.file) {
        updates.imageUrl = `/uploads/products/${req.file.filename}`;
      }

      await product.update(updates);

      res.status(200).json({
        success: true,
        message: 'Product updated successfully',
        data: product
      });
    } catch (error) {
      logger.error('Error updating product:', error);
      next(error);
    }
  }
}

module.exports = new AdminController();
