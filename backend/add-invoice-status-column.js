require('dotenv').config();
const db = require('./src/config/db');

async function addStatusColumn() {
  try {
    console.log('🚀 Adding status column to Invoices table...');

    // Connect to database
    await db.sequelize.authenticate();
    console.log('✅ Database connected');

    // Check if status column exists
    const [results] = await db.sequelize.query(`
      SELECT column_name
      FROM information_schema.columns
      WHERE table_name = 'Invoices'
      AND column_name = 'status';
    `);

    if (results.length > 0) {
      console.log('✅ Status column already exists');
      process.exit(0);
      return;
    }

    // Create enum type if it doesn't exist
    await db.sequelize.query(`
      DO $$ BEGIN
        CREATE TYPE "enum_Invoices_status" AS ENUM ('pending', 'generated', 'sent', 'paid', 'partial');
      EXCEPTION
        WHEN duplicate_object THEN null;
      END $$;
    `);
    console.log('✅ Status enum type created');

    // Add status column
    await db.sequelize.query(`
      ALTER TABLE "Invoices"
      ADD COLUMN IF NOT EXISTS "status" "enum_Invoices_status" DEFAULT 'pending';
    `);
    console.log('✅ Status column added to Invoices table');

    // Update existing records to have default status
    await db.sequelize.query(`
      UPDATE "Invoices"
      SET "status" = 'pending'
      WHERE "status" IS NULL;
    `);
    console.log('✅ Updated existing invoices with default status');

    console.log('🎉 Migration completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Migration failed:', error);
    process.exit(1);
  }
}

addStatusColumn();

