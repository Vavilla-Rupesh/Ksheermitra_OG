const { Sequelize } = require('sequelize');

/**
 * Migration: Add OfflineSales table and update Invoice invoiceType enum
 */

module.exports = {
  up: async (queryInterface, DataTypes) => {
    const transaction = await queryInterface.sequelize.transaction();

    try {
      // 1. Create OfflineSales table
      await queryInterface.createTable('OfflineSales', {
        id: {
          type: DataTypes.UUID,
          defaultValue: DataTypes.UUIDV4,
          primaryKey: true
        },
        saleNumber: {
          type: DataTypes.STRING(50),
          allowNull: false,
          unique: true
        },
        saleDate: {
          type: DataTypes.DATEONLY,
          allowNull: false
        },
        adminId: {
          type: DataTypes.UUID,
          allowNull: false,
          references: {
            model: 'Users',
            key: 'id'
          },
          onUpdate: 'CASCADE',
          onDelete: 'RESTRICT'
        },
        totalAmount: {
          type: DataTypes.DECIMAL(10, 2),
          allowNull: false
        },
        items: {
          type: DataTypes.JSONB,
          allowNull: false
        },
        customerName: {
          type: DataTypes.STRING(100),
          allowNull: true
        },
        customerPhone: {
          type: DataTypes.STRING(15),
          allowNull: true
        },
        paymentMethod: {
          type: DataTypes.ENUM('cash', 'card', 'upi', 'other'),
          defaultValue: 'cash'
        },
        notes: {
          type: DataTypes.TEXT,
          allowNull: true
        },
        invoiceId: {
          type: DataTypes.UUID,
          allowNull: true,
          references: {
            model: 'Invoices',
            key: 'id'
          },
          onUpdate: 'CASCADE',
          onDelete: 'SET NULL'
        },
        createdAt: {
          type: DataTypes.DATE,
          allowNull: false
        },
        updatedAt: {
          type: DataTypes.DATE,
          allowNull: false
        },
        deletedAt: {
          type: DataTypes.DATE,
          allowNull: true
        }
      }, { transaction });

      // 2. Add indexes
      await queryInterface.addIndex('OfflineSales', ['saleNumber'], {
        unique: true,
        transaction
      });

      await queryInterface.addIndex('OfflineSales', ['saleDate'], {
        transaction
      });

      await queryInterface.addIndex('OfflineSales', ['adminId'], {
        transaction
      });

      await queryInterface.addIndex('OfflineSales', ['invoiceId'], {
        transaction
      });

      // 3. Update Invoice invoiceType enum to include 'admin_daily'
      await queryInterface.sequelize.query(`
        ALTER TYPE "enum_Invoices_invoiceType" ADD VALUE IF NOT EXISTS 'admin_daily';
      `, { transaction });

      await transaction.commit();
      console.log('Migration completed successfully: Added OfflineSales table and updated Invoice enum');
    } catch (error) {
      await transaction.rollback();
      console.error('Migration failed:', error);
      throw error;
    }
  },

  down: async (queryInterface, DataTypes) => {
    const transaction = await queryInterface.sequelize.transaction();

    try {
      // Drop OfflineSales table
      await queryInterface.dropTable('OfflineSales', { transaction });

      // Note: PostgreSQL doesn't support removing values from enums directly
      // You would need to recreate the enum type if you want to remove 'admin_daily'
      // For simplicity, we're leaving the enum value in place

      await transaction.commit();
      console.log('Rollback completed successfully: Dropped OfflineSales table');
    } catch (error) {
      await transaction.rollback();
      console.error('Rollback failed:', error);
      throw error;
    }
  }
};

