module.exports = (sequelize, DataTypes) => {
  const OfflineSale = sequelize.define('OfflineSale', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    saleNumber: {
      type: DataTypes.STRING(50),
      allowNull: false,
      unique: true,
      validate: {
        notEmpty: true
      }
    },
    saleDate: {
      type: DataTypes.DATEONLY,
      allowNull: false,
      defaultValue: DataTypes.NOW
    },
    adminId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'Users',
        key: 'id'
      }
    },
    totalAmount: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
      validate: {
        min: 0,
        isDecimal: true
      }
    },
    items: {
      type: DataTypes.JSONB,
      allowNull: false,
      comment: 'Array of sale items with productId, productName, quantity, unit, pricePerUnit, amount'
    },
    customerName: {
      type: DataTypes.STRING(100),
      allowNull: true,
      comment: 'Optional walk-in customer name'
    },
    customerPhone: {
      type: DataTypes.STRING(15),
      allowNull: true,
      comment: 'Optional walk-in customer phone'
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
      comment: 'Reference to daily admin invoice'
    }
  }, {
    tableName: 'OfflineSales',
    timestamps: true,
    paranoid: true,
    indexes: [
      {
        unique: true,
        fields: ['saleNumber']
      },
      {
        fields: ['saleDate']
      },
      {
        fields: ['adminId']
      },
      {
        fields: ['invoiceId']
      }
    ]
  });

  OfflineSale.associate = (models) => {
    OfflineSale.belongsTo(models.User, {
      foreignKey: 'adminId',
      as: 'admin'
    });

    OfflineSale.belongsTo(models.Invoice, {
      foreignKey: 'invoiceId',
      as: 'invoice'
    });
  };

  return OfflineSale;
};

