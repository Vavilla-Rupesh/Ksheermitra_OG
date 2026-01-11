const db = require('./src/config/db');
const migration = require('./migrations/20260104_add_offline_sales');

async function runMigration() {
  console.log('🔄 Running offline sales migration...\n');

  try {
    await db.sequelize.authenticate();
    console.log('✅ Database connected\n');

    // Run migration
    await migration.up(db.sequelize.getQueryInterface(), db.Sequelize);

    console.log('\n✅ Migration completed successfully!');
    console.log('   - OfflineSales table created');
    console.log('   - Invoice invoiceType enum updated with "admin_daily"');
    console.log('   - All indexes created');

  } catch (error) {
    console.error('❌ Migration failed:', error.message);
    if (error.original) {
      console.error('   Database error:', error.original.message);
    }

    // If table already exists, that's okay
    if (error.message.includes('already exists')) {
      console.log('\n⚠️  Tables already exist - skipping migration');
    } else {
      throw error;
    }
  } finally {
    await db.sequelize.close();
  }
}

runMigration();

