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

      res.status(201).json({
        success: true,
        message: 'Delivery boy created successfully',
        data: deliveryBoy
      });
    } catch (error) {
      logger.error('Error creating delivery boy:', error);
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
      const { name, description, deliveryBoyId } = req.body;

      const area = await db.Area.create({
        name,
        description,
        deliveryBoyId,
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
      const { name, description, deliveryBoyId, isActive } = req.body;

      const area = await db.Area.findByPk(id);
      
      if (!area) {
        return res.status(404).json({
          success: false,
          message: 'Area not found'
        });
      }

      const updates = {};
      if (name !== undefined) updates.name = name;
      if (description !== undefined) updates.description = description;
      if (deliveryBoyId !== undefined) updates.deliveryBoyId = deliveryBoyId;
      if (isActive !== undefined) updates.isActive = isActive;

      await area.update(updates);

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

      const product = await db.Product.create({
        name,
        description,
        unit,
        pricePerUnit,
        stock: stock || 0,
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
