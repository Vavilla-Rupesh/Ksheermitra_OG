module.exports = (sequelize, DataTypes) => {
  const DeliveryItem = sequelize.define('DeliveryItem', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    deliveryId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'Deliveries',
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
        min: 0,
        isDecimal: true
      }
    },
    price: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
      validate: {
        min: 0,
        isDecimal: true
      }
    },
    isOneTime: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
      comment: 'True if this is a one-time addition not part of regular subscription'
    }
  }, {
    tableName: 'DeliveryItems',
    timestamps: true,
    indexes: [
      {
        fields: ['deliveryId']
      },
      {
        fields: ['productId']
      }
    ]
  });

  DeliveryItem.associate = (models) => {
    DeliveryItem.belongsTo(models.Delivery, {
      foreignKey: 'deliveryId',
      as: 'delivery'
    });

    DeliveryItem.belongsTo(models.Product, {
      foreignKey: 'productId',
      as: 'product'
    });
  };

  return DeliveryItem;
};

