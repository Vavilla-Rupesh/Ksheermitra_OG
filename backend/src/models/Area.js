module.exports = (sequelize, DataTypes) => {
  const Area = sequelize.define('Area', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
      validate: {
        notEmpty: true,
        len: [2, 100]
      }
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    deliveryBoyId: {
      type: DataTypes.UUID,
      allowNull: true,
      unique: true,
      references: {
        model: 'Users',
        key: 'id'
      }
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    }
  }, {
    tableName: 'Areas',
    timestamps: true,
    paranoid: true,
    indexes: [
      {
        unique: true,
        fields: ['name']
      },
      {
        unique: true,
        fields: ['deliveryBoyId']
      },
      {
        fields: ['isActive']
      }
    ]
  });

  Area.associate = (models) => {
    Area.belongsTo(models.User, {
      foreignKey: 'deliveryBoyId',
      as: 'deliveryBoy'
    });

    Area.hasMany(models.User, {
      foreignKey: 'areaId',
      as: 'customers'
    });
  };

  return Area;
};
