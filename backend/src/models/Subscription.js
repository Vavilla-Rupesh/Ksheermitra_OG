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
    frequency: {
      type: DataTypes.ENUM('daily', 'weekly', 'custom', 'monthly', 'daterange'),
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
    },
    autoRenewal: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
      comment: 'Auto-renew monthly subscriptions'
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

    Subscription.hasMany(models.SubscriptionProduct, {
      foreignKey: 'subscriptionId',
      as: 'products'
    });

    Subscription.hasMany(models.Delivery, {
      foreignKey: 'subscriptionId',
      as: 'deliveries'
    });
  };

  return Subscription;
};
