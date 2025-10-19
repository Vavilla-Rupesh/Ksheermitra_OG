module.exports = (sequelize, DataTypes) => {
  const OTPLog = sequelize.define('OTPLog', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    userId: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: 'Users',
        key: 'id'
      }
    },
    phone: {
      type: DataTypes.STRING(15),
      allowNull: false,
      validate: {
        notEmpty: true,
        is: /^\+?[1-9]\d{1,14}$/
      }
    },
    otp: {
      type: DataTypes.STRING(10),
      allowNull: false
    },
    expiresAt: {
      type: DataTypes.DATE,
      allowNull: false
    },
    isVerified: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    verifiedAt: {
      type: DataTypes.DATE,
      allowNull: true
    },
    attempts: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      validate: {
        min: 0
      }
    },
    ipAddress: {
      type: DataTypes.STRING(45),
      allowNull: true
    }
  }, {
    tableName: 'OTPLogs',
    timestamps: true,
    indexes: [
      {
        fields: ['userId']
      },
      {
        fields: ['phone']
      },
      {
        fields: ['otp']
      },
      {
        fields: ['expiresAt']
      },
      {
        fields: ['isVerified']
      },
      {
        fields: ['phone', 'isVerified']
      }
    ]
  });

  OTPLog.associate = (models) => {
    OTPLog.belongsTo(models.User, {
      foreignKey: 'userId',
      as: 'user'
    });
  };

  return OTPLog;
};
