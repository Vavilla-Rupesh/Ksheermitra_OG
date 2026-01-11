module.exports = (sequelize, DataTypes) => {
  const Invoice = sequelize.define('Invoice', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    invoiceNumber: {
      type: DataTypes.STRING(50),
      allowNull: false,
      unique: true,
      validate: {
        notEmpty: true
      }
    },
    customerId: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: 'Users',
        key: 'id'
      }
    },
    deliveryBoyId: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: 'Users',
        key: 'id'
      }
    },
    invoiceType: {
      type: DataTypes.ENUM('daily', 'monthly', 'delivery_boy_daily', 'admin_daily'),
      allowNull: false,
      defaultValue: 'daily'
    },
    invoiceDate: {
      type: DataTypes.DATEONLY,
      allowNull: false
    },
    periodStart: {
      type: DataTypes.DATEONLY,
      allowNull: true
    },
    periodEnd: {
      type: DataTypes.DATEONLY,
      allowNull: true
    },
    totalAmount: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
      validate: {
        min: 0,
        isDecimal: true
      }
    },
    paidAmount: {
      type: DataTypes.DECIMAL(10, 2),
      defaultValue: 0,
      validate: {
        min: 0,
        isDecimal: true
      }
    },
    status: {
      type: DataTypes.ENUM('pending', 'generated', 'sent', 'paid', 'partial'),
      defaultValue: 'pending'
    },
    pdfPath: {
      type: DataTypes.STRING,
      allowNull: true
    },
    sentViaWhatsApp: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    sentAt: {
      type: DataTypes.DATE,
      allowNull: true
    },
    metadata: {
      type: DataTypes.JSONB,
      allowNull: true,
      comment: 'Stores detailed invoice information including delivery details'
    }
  }, {
    tableName: 'Invoices',
    timestamps: true,
    paranoid: true,
    indexes: [
      {
        unique: true,
        fields: ['invoiceNumber']
      },
      {
        fields: ['customerId']
      },
      {
        fields: ['deliveryBoyId']
      },
      {
        fields: ['invoiceType']
      },
      {
        fields: ['invoiceDate']
      },
      {
        fields: ['status']
      },
      {
        fields: ['periodStart', 'periodEnd']
      }
    ]
  });

  Invoice.associate = (models) => {
    Invoice.belongsTo(models.User, {
      foreignKey: 'customerId',
      as: 'customer'
    });

    Invoice.belongsTo(models.User, {
      foreignKey: 'deliveryBoyId',
      as: 'deliveryBoy'
    });

    Invoice.hasMany(models.OfflineSale, {
      foreignKey: 'invoiceId',
      as: 'offlineSales'
    });
  };

  return Invoice;
};

