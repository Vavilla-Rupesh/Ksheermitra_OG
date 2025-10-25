module.exports = (sequelize, DataTypes) => {
  const SubscriptionProduct = sequelize.define('SubscriptionProduct', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
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
    }
  }, {
    tableName: 'SubscriptionProducts',
    timestamps: true,
    indexes: [
      {
        fields: ['subscriptionId']
      },
      {
        fields: ['productId']
      },
      {
        unique: true,
        fields: ['subscriptionId', 'productId']
      }
    ]
  });

  SubscriptionProduct.associate = (models) => {
    SubscriptionProduct.belongsTo(models.Subscription, {
      foreignKey: 'subscriptionId',
      as: 'subscription'
    });

    SubscriptionProduct.belongsTo(models.Product, {
      foreignKey: 'productId',
      as: 'product'
    });
  };

  return SubscriptionProduct;
};

