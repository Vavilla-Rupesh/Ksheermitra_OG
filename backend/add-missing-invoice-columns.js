require('dotenv').config();
const db = require('./src/config/db');

async function addMissingColumns() {
  try {
    console.log('🚀 Adding missing columns to Invoices table...');

    await db.sequelize.authenticate();
    console.log('✅ Database connected');

    // Check and add invoiceType column
    const [invoiceTypeCheck] = await db.sequelize.query(`
      SELECT column_name
      FROM information_schema.columns
      WHERE table_name = 'Invoices'
      AND column_name = 'invoiceType';
    `);

    if (invoiceTypeCheck.length === 0) {
      console.log('📝 Adding invoiceType column...');

      // Ensure enum type exists
      await db.sequelize.query(`
        DO $$ BEGIN
          CREATE TYPE "enum_Invoices_invoiceType" AS ENUM ('daily', 'monthly', 'delivery_boy_daily', 'admin_daily');
        EXCEPTION
          WHEN duplicate_object THEN null;
        END $$;
      `);

      await db.sequelize.query(`
        ALTER TABLE "Invoices"
        ADD COLUMN "invoiceType" "enum_Invoices_invoiceType" DEFAULT 'daily';
      `);

      console.log('✅ invoiceType column added');
    } else {
      console.log('✅ invoiceType column already exists');
    }

    // Check and add metadata column
    const [metadataCheck] = await db.sequelize.query(`
      SELECT column_name
      FROM information_schema.columns
      WHERE table_name = 'Invoices'
      AND column_name = 'metadata';
    `);

    if (metadataCheck.length === 0) {
      console.log('📝 Adding metadata column...');

      await db.sequelize.query(`
        ALTER TABLE "Invoices"
        ADD COLUMN "metadata" JSONB;
      `);

      console.log('✅ metadata column added');
    } else {
      console.log('✅ metadata column already exists');
    }

    // Verify all columns now exist
    console.log('\n🔍 Verifying Invoices table structure...');
    const [columns] = await db.sequelize.query(`
      SELECT column_name, data_type
      FROM information_schema.columns
      WHERE table_name = 'Invoices'
      ORDER BY ordinal_position;
    `);

    console.log('\nInvoices Table Columns:');
    columns.forEach(col => {
      console.log(`  ✅ ${col.column_name.padEnd(20)} - ${col.data_type}`);
    });

    console.log('\n🎉 All missing columns have been added!');
    console.log('✅ Database is now fully ready for offline sales!');

    process.exit(0);
  } catch (error) {
    console.error('❌ Migration failed:', error.message);
    console.error('Stack:', error.stack);
    process.exit(1);
  }
}

addMissingColumns();

