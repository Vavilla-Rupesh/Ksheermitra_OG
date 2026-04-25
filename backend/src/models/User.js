const bcrypt = require('bcrypt');

module.exports = (sequelize, DataTypes) => {
  const User = sequelize.define('User', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    name: {
      type: DataTypes.STRING,
      allowNull: true,
      validate: {
        len: [2, 100]
      }
    },
    phone: {
      type: DataTypes.STRING(15),
      allowNull: false,
      unique: true,
      validate: {
        notEmpty: true,
        is: /^\+?[1-9]\d{1,14}$/
      }
    },
    email: {
      type: DataTypes.STRING,
      allowNull: true,
      unique: true,
      validate: {
        isEmail: true
      }
    },
    role: {
      type: DataTypes.ENUM('admin', 'customer', 'delivery_boy'),
      allowNull: false,
      defaultValue: 'customer'
    },
    address: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    latitude: {
      type: DataTypes.DECIMAL(10, 8),
      allowNull: true
    },
    longitude: {
      type: DataTypes.DECIMAL(11, 8),
      allowNull: true
    },
    areaId: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: 'Areas',
        key: 'id'
      }
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    },
    passwordHash: {
      type: DataTypes.STRING,
      allowNull: true
    },
    lastLogin: {
      type: DataTypes.DATE,
      allowNull: true
    }
  }, {
    tableName: 'Users',
    timestamps: true,
    paranoid: true,
    indexes: [
      {
        unique: true,
        fields: ['phone']
      },
      {
        fields: ['role']
      },
      {
        fields: ['areaId']
      },
      {
        fields: ['isActive']
      }
    ]
  });

  User.associate = (models) => {
    User.belongsTo(models.Area, {
      foreignKey: 'areaId',
      as: 'area'
    });

    // Association for delivery boy to get assigned area
    User.hasOne(models.Area, {
      foreignKey: 'deliveryBoyId',
      as: 'assignedArea'
    });

    User.hasMany(models.Subscription, {
      foreignKey: 'customerId',
      as: 'subscriptions'
    });

    User.hasMany(models.Delivery, {
      foreignKey: 'deliveryBoyId',
      as: 'deliveries'
    });

    User.hasMany(models.Invoice, {
      foreignKey: 'customerId',
      as: 'invoices'
    });

    User.hasMany(models.OTPLog, {
      foreignKey: 'userId',
      as: 'otpLogs'
    });
  };

  User.prototype.setPassword = async function(password) {
    this.passwordHash = await bcrypt.hash(password, 10);
  };

  User.prototype.validatePassword = async function(password) {
    if (!this.passwordHash) return false;
    return await bcrypt.compare(password, this.passwordHash);
  };

  return User;
};
