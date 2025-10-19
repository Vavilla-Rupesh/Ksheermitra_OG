module.exports = (sequelize, DataTypes) => {
  const Subscription = sequelize.define('Subscription', {
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
    productId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'Products',
        key: 'id'
      }
    },
    quantity: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
      validate: {
        min: 0.1,
        isDecimal: true
      }
    },
    frequency: {
      type: DataTypes.ENUM('daily', 'weekly', 'monthly', 'custom'),
      allowNull: false,
      defaultValue: 'daily'
    },
    selectedDays: {
      type: DataTypes.ARRAY(DataTypes.INTEGER),
      allowNull: true,
      comment: '0=Sunday, 1=Monday, ..., 6=Saturday'
    },
    startDate: {
      type: DataTypes.DATEONLY,
      allowNull: false
    },
    endDate: {
      type: DataTypes.DATEONLY,
      allowNull: true
    },
    status: {
      type: DataTypes.ENUM('active', 'paused', 'cancelled', 'completed'),
      allowNull: false,
      defaultValue: 'active'
    },
    pauseStartDate: {
      type: DataTypes.DATEONLY,
      allowNull: true
    },
    pauseEndDate: {
      type: DataTypes.DATEONLY,
      allowNull: true
    }
  }, {
    tableName: 'Subscriptions',
    timestamps: true,
    paranoid: true,
    indexes: [
      {
        fields: ['customerId']
      },
      {
        fields: ['productId']
      },
      {
        fields: ['status']
      },
      {
        fields: ['startDate', 'endDate']
      }
    ]
  });

  Subscription.associate = (models) => {
    Subscription.belongsTo(models.User, {
      foreignKey: 'customerId',
      as: 'customer'
    });

    Subscription.belongsTo(models.Product, {
      foreignKey: 'productId',
      as: 'product'
    });

    Subscription.hasMany(models.Delivery, {
      foreignKey: 'subscriptionId',
      as: 'deliveries'
    });
  };

  return Subscription;
};
