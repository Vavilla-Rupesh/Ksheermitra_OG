const db = require('../config/db');
const logger = require('../utils/logger');
const mapsService = require('../services/maps.service');
const whatsappService = require('../services/whatsapp.service');
const offlineSaleService = require('../services/offlineSale.service');

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
        attributes: ['id', 'name', 'phone', 'address', 'latitude', 'longitude', 'areaId', 'isActive'],
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

  async createCustomer(req, res, next) {
    try {
      const { name, phone, email, address, latitude, longitude } = req.body;

      const existingUser = await db.User.findOne({ where: { phone } });

      if (existingUser) {
        return res.status(409).json({
          success: false,
          message: 'Phone number already registered'
        });
      }

      const customer = await db.User.create({
        name,
        phone,
        email,
        address,
        latitude,
        longitude,
        role: 'customer',
        isActive: true
      });

      const customerData = customer.toJSON();
      delete customerData.passwordHash;

      res.status(201).json({
        success: true,
        message: 'Customer created successfully',
        data: customerData
      });
    } catch (error) {
      logger.error('Error creating customer:', error);
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
          as: 'assignedArea',
          attributes: ['id', 'name', 'description', 'centerLatitude', 'centerLongitude']
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
      const { name, description, boundaries, centerLatitude, centerLongitude, mapLink, isActive, deliveryBoyId } = req.body;

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

      // If deliveryBoyId is being changed, validate it
      if (deliveryBoyId !== undefined) {
        if (deliveryBoyId === null) {
          // Allow null to unassign
          // Do nothing, just allow it
        } else {
          const deliveryBoy = await db.User.findOne({
            where: { id: deliveryBoyId, role: 'delivery_boy' }
          });
          if (!deliveryBoy) {
            return res.status(404).json({
              success: false,
              message: 'Delivery boy not found'
            });
          }

          // Check if delivery boy is already assigned to another area
          const existingArea = await db.Area.findOne({
            where: {
              deliveryBoyId,
              id: { [db.Sequelize.Op.ne]: id }
            }
          });

          if (existingArea) {
            return res.status(409).json({
              success: false,
              message: 'Delivery boy is already assigned to another area'
            });
          }
        }
      }

      // Prepare update data
      const updateData = {
        name: name || area.name,
        description: description !== undefined ? description : area.description,
        boundaries: boundaries || area.boundaries,
        centerLatitude: centerLatitude !== undefined ? centerLatitude : area.centerLatitude,
        centerLongitude: centerLongitude !== undefined ? centerLongitude : area.centerLongitude,
        mapLink: mapLink !== undefined ? mapLink : area.mapLink,
        isActive: isActive !== undefined ? isActive : area.isActive,
        deliveryBoyId: deliveryBoyId !== undefined ? deliveryBoyId : area.deliveryBoyId
      };

      await area.update(updateData);

      // Fetch updated area with delivery boy info for response
      const updatedArea = await db.Area.findByPk(id, {
        include: [{
          model: db.User,
          as: 'deliveryBoy',
          attributes: ['id', 'name', 'phone', 'email']
        }],
        attributes: ['id', 'name', 'description', 'boundaries', 'centerLatitude', 'centerLongitude', 'mapLink', 'deliveryBoyId', 'isActive', 'customerCount', 'createdAt', 'updatedAt']
      });

      res.status(200).json({
        success: true,
        message: 'Area updated successfully',
        data: updatedArea || area
      });
    } catch (error) {
      logger.error('Error updating area:', error);
      next(error);
    }
  }

  async deleteArea(req, res, next) {
    try {
      const { id } = req.params;

      const area = await db.Area.findByPk(id);

      if (!area) {
        return res.status(404).json({
          success: false,
          message: 'Area not found'
        });
      }

      // Check if any customers are assigned to this area
      const customerCount = await db.User.count({
        where: { areaId: id, role: 'customer' }
      });

      if (customerCount > 0) {
        return res.status(409).json({
          success: false,
          message: `Cannot delete area with ${customerCount} assigned customer(s). Please reassign or remove customers first.`
        });
      }

      // Check if area is assigned to a delivery boy
      if (area.deliveryBoyId) {
        // Unassign the delivery boy first
        await area.update({ deliveryBoyId: null });
      }

      await area.destroy();

      res.status(200).json({
        success: true,
        message: 'Area deleted successfully'
      });
    } catch (error) {
      logger.error('Error deleting area:', error);
      next(error);
    }
  }

  async getDailyInvoices(req, res, next) {
    try {
      const { startDate, endDate, deliveryBoyId } = req.query;

      const whereClause = {
        invoiceType: 'daily'
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
        invoiceType: 'monthly'
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

      // Return updated area immediately (don't wait for WhatsApp)
      const updatedArea = await db.Area.findByPk(areaId, {
        include: [{
          model: db.User,
          as: 'deliveryBoy',
          attributes: ['id', 'name', 'phone', 'email']
        }],
        attributes: ['id', 'name', 'description', 'boundaries', 'centerLatitude', 'centerLongitude', 'mapLink', 'deliveryBoyId', 'isActive', 'customerCount', 'createdAt', 'updatedAt']
      });

      // Send WhatsApp notification to delivery boy (fire-and-forget, don't block response)
      try {
        const message = `🎯 *Area Assignment*\n\n` +
          `Hello ${deliveryBoy.name}!\n\n` +
          `You have been assigned to: *${area.name}*\n` +
          `📍 Customers in area: ${customerCount}\n\n` +
          `${mapLink ? `🗺️ View Map: ${mapLink}\n\n` : ''}` +
          `You can now view your assigned deliveries in the app.\n\n` +
          `For support, contact admin.`;

        // Fire-and-forget WhatsApp notification (don't await)
        whatsappService.sendMessage(deliveryBoy.phone, message)
          .then(() => logger.info(`WhatsApp notification sent to delivery boy ${deliveryBoyId} for area assignment`))
          .catch(err => logger.error('Error sending WhatsApp notification:', err.message || err));
      } catch (whatsappError) {
        logger.error('WhatsApp notification setup error:', whatsappError);
        // Don't fail the request if WhatsApp fails
      }

      res.status(200).json({
        success: true,
        message: 'Area assigned successfully',
        data: {
          area: updatedArea || area,
          deliveryBoy: {
            id: deliveryBoy.id,
            name: deliveryBoy.name,
            phone: deliveryBoy.phone,
            email: deliveryBoy.email
          },
          customerCount,
          assignmentDetails: {
            areaId: areaId,
            deliveryBoyId: deliveryBoyId,
            boundaries: boundaries,
            centerLatitude: centerLatitude,
            centerLongitude: centerLongitude,
            mapLink: mapLink
          }
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

      const updates = {};

      // Only update boundaries if provided
      if (boundaries !== undefined && boundaries !== null) {
        updates.boundaries = boundaries;
      }

      // Parse center coordinates as numbers if provided
      if (centerLatitude !== undefined && centerLatitude !== null) {
        updates.centerLatitude = parseFloat(centerLatitude);
      }

      if (centerLongitude !== undefined && centerLongitude !== null) {
        updates.centerLongitude = parseFloat(centerLongitude);
      }

      // Update mapLink if provided
      if (mapLink !== undefined && mapLink !== null) {
        updates.mapLink = mapLink;
      }

      // Update area with new boundaries and center
      await area.update(updates);

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
            as: 'assignedArea',
            include: [{
              model: db.User,
              as: 'customers',
              attributes: ['id', 'name', 'phone', 'address', 'latitude', 'longitude']
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

  // Get WhatsApp connection status
  async getWhatsAppStatus(req, res, next) {
    try {
      const status = whatsappService.getStatus();
      res.status(200).json({
        success: true,
        data: status
      });
    } catch (error) {
      logger.error('Error getting WhatsApp status:', error);
      next(error);
    }
  }

  // Reset WhatsApp session (clears session and requires new QR scan)
  async resetWhatsAppSession(req, res, next) {
    try {
      logger.info('Admin requested WhatsApp session reset');
      await whatsappService.resetSession();
      res.status(200).json({
        success: true,
        message: 'WhatsApp session reset initiated. Please scan the new QR code in the server console.'
      });
    } catch (error) {
      logger.error('Error resetting WhatsApp session:', error);
      next(error);
    }
  }

  // ============ OFFLINE SALES (IN-STORE) METHODS ============

  /**
   * Create an offline/in-store sale
   */
  async createOfflineSale(req, res, next) {
    try {
      const adminId = req.user.id;
      const { items, customerName, customerPhone, paymentMethod, notes } = req.body;

      const saleData = {
        adminId,
        items,
        customerName,
        customerPhone,
        paymentMethod,
        notes
      };

      const sale = await offlineSaleService.createOfflineSale(saleData);

      res.status(201).json({
        success: true,
        message: 'Offline sale created successfully',
        data: sale
      });
    } catch (error) {
      logger.error('Error creating offline sale:', error);

      // Send appropriate error message
      const statusCode = error.message.includes('Insufficient stock') ? 400 : 500;
      res.status(statusCode).json({
        success: false,
        message: error.message || 'Failed to create offline sale'
      });
    }
  }

  /**
   * Get offline sales with pagination and filters
   */
  async getOfflineSales(req, res, next) {
    try {
      const { startDate, endDate, page, limit } = req.query;

      const filters = {
        startDate,
        endDate,
        page,
        limit
      };

      const result = await offlineSaleService.getOfflineSales(filters);

      res.status(200).json({
        success: true,
        data: result
      });
    } catch (error) {
      logger.error('Error getting offline sales:', error);
      next(error);
    }
  }

  /**
   * Get offline sale by ID
   */
  async getOfflineSaleById(req, res, next) {
    try {
      const { id } = req.params;

      const sale = await offlineSaleService.getOfflineSaleById(id);

      res.status(200).json({
        success: true,
        data: sale
      });
    } catch (error) {
      logger.error('Error getting offline sale:', error);

      if (error.message === 'Offline sale not found') {
        return res.status(404).json({
          success: false,
          message: error.message
        });
      }

      next(error);
    }
  }

  /**
   * Get offline sales statistics
   */
  async getOfflineSalesStats(req, res, next) {
    try {
      const { startDate, endDate } = req.query;

      const stats = await offlineSaleService.getSalesStats(startDate, endDate);

      res.status(200).json({
        success: true,
        data: stats
      });
    } catch (error) {
      logger.error('Error getting offline sales stats:', error);
      next(error);
    }
  }

  /**
   * Get admin daily invoice with offline sales
   */
  async getAdminDailyInvoice(req, res, next) {
    try {
      const { date } = req.query;

      if (!date) {
        return res.status(400).json({
          success: false,
          message: 'Date is required'
        });
      }

      const invoice = await offlineSaleService.getAdminDailyInvoice(date);

      if (!invoice) {
        return res.status(404).json({
          success: false,
          message: 'No invoice found for the specified date'
        });
      }

      res.status(200).json({
        success: true,
        data: invoice
      });
    } catch (error) {
      logger.error('Error getting admin daily invoice:', error);
      next(error);
    }
  }

  /**
   * GET /api/admin/invoices/pending
   * Get all pending invoices for approval
   */
  async getPendingInvoices(req, res, next) {
    try {
      const invoices = await db.Invoice.findAll({
        where: { status: 'submitted' },
        include: [{
          model: db.User,
          as: 'deliveryBoy',
          attributes: ['id', 'name', 'phone']
        }],
        order: [['submittedAt', 'ASC']]
      });

      res.status(200).json({
        success: true,
        data: invoices.map(invoice => ({
          ...invoice.toJSON(),
          deliveryBoyName: invoice.deliveryBoy?.name,
          items: invoice.metadata?.deliveries || []
        }))
      });
    } catch (error) {
      logger.error('Error getting pending invoices:', error);
      next(error);
    }
  }

  /**
   * GET /api/admin/invoices/delivery-boy/:deliveryBoyId
   * Get all invoices for a specific delivery boy
   */
  async getDeliveryBoyInvoices(req, res, next) {
    try {
      const { deliveryBoyId } = req.params;
      const { status, startDate, endDate } = req.query;

      const where = { deliveryBoyId };

      if (status) {
        where.status = status;
      }

      if (startDate && endDate) {
        where.invoiceDate = {
          [db.Sequelize.Op.between]: [new Date(startDate), new Date(endDate)]
        };
      }

      const invoices = await db.Invoice.findAll({
        where,
        include: [{
          model: db.User,
          as: 'deliveryBoy',
          attributes: ['id', 'name', 'phone']
        }],
        order: [['invoiceDate', 'DESC']]
      });

      res.status(200).json({
        success: true,
        data: invoices.map(invoice => ({
          ...invoice.toJSON(),
          deliveryBoyName: invoice.deliveryBoy?.name,
          items: invoice.metadata?.deliveries || []
        }))
      });
    } catch (error) {
      logger.error('Error getting delivery boy invoices:', error);
      next(error);
    }
  }

  /**
   * POST /api/admin/invoices/:id/approve
   * Approve an invoice submission
   */
  async approveInvoice(req, res, next) {
    try {
      const { id } = req.params;
      const adminId = req.user.id;

      const invoice = await db.Invoice.findByPk(id);

      if (!invoice) {
        return res.status(404).json({
          success: false,
          message: 'Invoice not found'
        });
      }

      if (invoice.status !== 'submitted') {
        return res.status(400).json({
          success: false,
          message: `Cannot approve invoice with status: ${invoice.status}`
        });
      }

      await invoice.update({
        status: 'approved',
        approvedAt: new Date(),
        approvedBy: adminId
      });

      logger.info(`Invoice ${invoice.invoiceNumber} approved by admin ${adminId}`);

      res.status(200).json({
        success: true,
        message: 'Invoice approved successfully',
        data: invoice
      });
    } catch (error) {
      logger.error('Error approving invoice:', error);
      next(error);
    }
  }

  /**
   * POST /api/admin/invoices/:id/reject
   * Reject an invoice submission
   */
  async rejectInvoice(req, res, next) {
    try {
      const { id } = req.params;
      const { reason } = req.body;
      const adminId = req.user.id;

      const invoice = await db.Invoice.findByPk(id);

      if (!invoice) {
        return res.status(404).json({
          success: false,
          message: 'Invoice not found'
        });
      }

      if (invoice.status !== 'submitted') {
        return res.status(400).json({
          success: false,
          message: `Cannot reject invoice with status: ${invoice.status}`
        });
      }

      await invoice.update({
        status: 'rejected',
        rejectionReason: reason,
        approvedBy: adminId
      });

      logger.info(`Invoice ${invoice.invoiceNumber} rejected by admin ${adminId}: ${reason}`);

      res.status(200).json({
        success: true,
        message: 'Invoice rejected',
        data: invoice
      });
    } catch (error) {
      logger.error('Error rejecting invoice:', error);
      next(error);
    }
  }

  /**
   * PUT /api/admin/areas/:id/customers
   * Update customers assigned to an area
   */
  async updateAreaCustomers(req, res, next) {
    const transaction = await db.sequelize.transaction();

    try {
      const { id } = req.params;
      const { customerIds } = req.body;

      // Validate area exists
      const area = await db.Area.findByPk(id, { transaction });

      if (!area) {
        await transaction.rollback();
        return res.status(404).json({
          success: false,
          message: 'Area not found'
        });
      }

      // Validate customerIds is an array
      if (!Array.isArray(customerIds)) {
        await transaction.rollback();
        return res.status(400).json({
          success: false,
          message: 'customerIds must be an array'
        });
      }

      // First, unassign all customers from this area
      await db.User.update(
        { areaId: null },
        {
          where: { areaId: id, role: 'customer' },
          transaction
        }
      );

      // Then assign selected customers to the area
      if (customerIds.length > 0) {
        await db.User.update(
          { areaId: id },
          {
            where: {
              id: { [db.Sequelize.Op.in]: customerIds },
              role: 'customer'
            },
            transaction
          }
        );
      }

      await transaction.commit();

      // Fetch updated area with customers
      const updatedArea = await db.Area.findByPk(id, {
        include: [
          {
            model: db.User,
            as: 'customers',
            attributes: ['id', 'name', 'phone', 'address'],
            where: { isActive: true },
            required: false
          }
        ]
      });

      logger.info(`Updated customers for area ${id}. Assigned: ${customerIds.length}`);

      res.status(200).json({
        success: true,
        message: `${customerIds.length} customers assigned to area successfully`,
        data: updatedArea
      });
    } catch (error) {
      await transaction.rollback();
      logger.error('Error updating area customers:', error);
      next(error);
    }
  }
}

module.exports = new AdminController();
