module.exports = (sequelize, DataTypes) => {
  const Delivery = sequelize.define('Delivery', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    customerId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'Users',
        key: 'id'
      }
    },
    deliveryBoyId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'Users',
        key: 'id'
      }
    },
    subscriptionId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'Subscriptions',
        key: 'id'
      }
    },
    productId: {
      type: DataTypes.UUID,
      allowNull: true, // Changed to true for multi-product support
      references: {
        model: 'Products',
        key: 'id'
      }
    },
    deliveryDate: {
      type: DataTypes.DATEONLY,
      allowNull: false
    },
    quantity: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true, // Changed to true for multi-product support
      validate: {
        min: 0,
        isDecimal: true
      }
    },
    status: {
      type: DataTypes.ENUM('pending', 'in-progress', 'delivered', 'missed', 'cancelled', 'failed'),
      allowNull: false,
      defaultValue: 'pending'
    },
    deliveredAt: {
      type: DataTypes.DATE,
      allowNull: true
    },
    amount: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
      validate: {
        min: 0,
        isDecimal: true
      }
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    notificationSent: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    }
  }, {
    tableName: 'Deliveries',
    timestamps: true,
    paranoid: true,
    indexes: [
      {
        fields: ['customerId']
      },
      {
        fields: ['deliveryBoyId']
      },
      {
        fields: ['subscriptionId']
      },
      {
        fields: ['productId']
      },
      {
        fields: ['deliveryDate']
      },
      {
        fields: ['status']
      },
      {
        fields: ['deliveryDate', 'customerId']
      },
      {
        fields: ['deliveryDate', 'deliveryBoyId']
      }
    ]
  });

  Delivery.associate = (models) => {
    Delivery.belongsTo(models.User, {
      foreignKey: 'customerId',
      as: 'customer'
    });

    Delivery.belongsTo(models.User, {
      foreignKey: 'deliveryBoyId',
      as: 'deliveryBoy'
    });

    Delivery.belongsTo(models.Subscription, {
      foreignKey: 'subscriptionId',
      as: 'subscription'
    });

    Delivery.belongsTo(models.Product, {
      foreignKey: 'productId',
      as: 'product'
    });

    Delivery.hasMany(models.DeliveryItem, {
      foreignKey: 'deliveryId',
      as: 'items'
    });
  };

  return Delivery;
};

