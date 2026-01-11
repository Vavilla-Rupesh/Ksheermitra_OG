require('dotenv').config();
const db = require('./src/config/db');

async function runMigration() {
  try {
    console.log('🚀 Starting OfflineSales table migration...');

    // Connect to database
    await db.sequelize.authenticate();
    console.log('✅ Database connected');

    // Create OfflineSales table
    await db.sequelize.query(`
      CREATE TABLE IF NOT EXISTS "OfflineSales" (
        "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        "saleNumber" VARCHAR(50) UNIQUE NOT NULL,
        "saleDate" DATE NOT NULL,
        "adminId" UUID NOT NULL REFERENCES "Users"(id) ON UPDATE CASCADE ON DELETE RESTRICT,
        "totalAmount" DECIMAL(10,2) NOT NULL,
        "items" JSONB NOT NULL,
        "customerName" VARCHAR(100),
        "customerPhone" VARCHAR(15),
        "paymentMethod" VARCHAR(20) DEFAULT 'cash',
        "notes" TEXT,
        "invoiceId" UUID REFERENCES "Invoices"(id) ON UPDATE CASCADE ON DELETE SET NULL,
        "createdAt" TIMESTAMP NOT NULL DEFAULT NOW(),
        "updatedAt" TIMESTAMP NOT NULL DEFAULT NOW(),
        "deletedAt" TIMESTAMP
      );
    `);
    console.log('✅ OfflineSales table created');

    // Create indexes
    await db.sequelize.query(`
      CREATE UNIQUE INDEX IF NOT EXISTS "idx_offline_sales_sale_number"
      ON "OfflineSales"("saleNumber");
    `);

    await db.sequelize.query(`
      CREATE INDEX IF NOT EXISTS "idx_offline_sales_sale_date"
      ON "OfflineSales"("saleDate");
    `);

    await db.sequelize.query(`
      CREATE INDEX IF NOT EXISTS "idx_offline_sales_admin_id"
      ON "OfflineSales"("adminId");
    `);

    await db.sequelize.query(`
      CREATE INDEX IF NOT EXISTS "idx_offline_sales_invoice_id"
      ON "OfflineSales"("invoiceId");
    `);
    console.log('✅ Indexes created');

    // Update Invoice enum if needed
    await db.sequelize.query(`
      DO $$ BEGIN
        ALTER TYPE "enum_Invoices_invoiceType" ADD VALUE IF NOT EXISTS 'admin_daily';
      EXCEPTION
        WHEN duplicate_object THEN null;
      END $$;
    `);
    console.log('✅ Invoice enum updated');

    console.log('🎉 Migration completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Migration failed:', error);
    process.exit(1);
  }
}

runMigration();

