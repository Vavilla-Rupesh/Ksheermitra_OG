const db = require('./src/config/db');

async function checkSchema() {
  try {
    await db.sequelize.authenticate();
    console.log('Connected to database');

    const deliveries = await db.sequelize.query(
      "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'Deliveries' ORDER BY ordinal_position;",
      { type: db.Sequelize.QueryTypes.SELECT }
    );

    console.log('Deliveries table columns:');
    console.log(JSON.stringify(deliveries, null, 2));

    const users = await db.sequelize.query(
      "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'Users' WHERE column_name LIKE '%delivery%' OR column_name = 'role';",
      { type: db.Sequelize.QueryTypes.SELECT }
    );

    console.log('\nUsers table (delivery related):');
    console.log(JSON.stringify(users, null, 2));

    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

checkSchema();

