const { Sequelize } = require('sequelize');
const config = require('./database');

const env = process.env.NODE_ENV || 'development';
const dbConfig = config[env];

const sequelize = new Sequelize(
  dbConfig.database,
  dbConfig.username,
  dbConfig.password,
  {
    host: dbConfig.host,
    port: dbConfig.port,
    dialect: dbConfig.dialect,
    logging: dbConfig.logging,
    pool: dbConfig.pool,
    dialectOptions: dbConfig.dialectOptions
  }
);

const db = {};

db.Sequelize = Sequelize;
db.sequelize = sequelize;

// Import models
db.User = require('../models/User')(sequelize, Sequelize);
db.Product = require('../models/Product')(sequelize, Sequelize);
db.Area = require('../models/Area')(sequelize, Sequelize);
db.Subscription = require('../models/Subscription')(sequelize, Sequelize);
db.Delivery = require('../models/Delivery')(sequelize, Sequelize);
db.Invoice = require('../models/Invoice')(sequelize, Sequelize);
db.OTPLog = require('../models/OTPLog')(sequelize, Sequelize);

// Define associations
Object.keys(db).forEach(modelName => {
  if (db[modelName].associate) {
    db[modelName].associate(db);
  }
});

module.exports = db;
