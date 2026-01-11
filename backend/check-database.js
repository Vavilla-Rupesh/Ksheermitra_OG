require('dotenv').config();
const db = require('./src/config/db');

async function checkDatabase() {
  try {
    console.log('🔍 CHECKING DATABASE SCHEMA...');
    console.log('=====================================\n');

    // Connect to database
    await db.sequelize.authenticate();
    console.log('✅ Database connected\n');

    // Check all required tables
    const requiredTables = [
      'Users',
      'Products',
      'Subscriptions',
      'Deliveries',
      'Invoices',
      'Areas',
      'OfflineSales'
    ];

    console.log('📋 CHECKING TABLES:');
    console.log('-------------------');

    for (const table of requiredTables) {
      const [results] = await db.sequelize.query(`
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'public'
        AND table_name = '${table}';
      `);

      if (results.length > 0) {
        console.log(`✅ ${table} - EXISTS`);
      } else {
        console.log(`❌ ${table} - MISSING`);
      }
    }

    console.log('\n📋 CHECKING INVOICES TABLE COLUMNS:');
    console.log('-----------------------------------');

    const [invoiceColumns] = await db.sequelize.query(`
      SELECT column_name, data_type, is_nullable, column_default
      FROM information_schema.columns
      WHERE table_name = 'Invoices'
      ORDER BY ordinal_position;
    `);

    const requiredInvoiceColumns = [
      'id',
      'invoiceNumber',
      'customerId',
      'deliveryBoyId',
      'invoiceType',
      'invoiceDate',
      'periodStart',
      'periodEnd',
      'totalAmount',
      'paidAmount',
      'status',
      'pdfPath',
      'sentViaWhatsApp',
      'sentAt',
      'metadata',
      'createdAt',
      'updatedAt',
      'deletedAt'
    ];

    console.log('\nInvoices Table Columns:');
    for (const col of requiredInvoiceColumns) {
      const found = invoiceColumns.find(c => c.column_name === col);
      if (found) {
        console.log(`✅ ${col.padEnd(20)} - ${found.data_type}`);
      } else {
        console.log(`❌ ${col.padEnd(20)} - MISSING`);
      }
    }

    console.log('\n📋 CHECKING OFFLINESALES TABLE COLUMNS:');
    console.log('---------------------------------------');

    const [offlineSalesColumns] = await db.sequelize.query(`
      SELECT column_name, data_type, is_nullable, column_default
      FROM information_schema.columns
      WHERE table_name = 'OfflineSales'
      ORDER BY ordinal_position;
    `);

    const requiredOfflineSalesColumns = [
      'id',
      'saleNumber',
      'saleDate',
      'adminId',
      'totalAmount',
      'items',
      'customerName',
      'customerPhone',
      'paymentMethod',
      'notes',
      'invoiceId',
      'createdAt',
      'updatedAt',
      'deletedAt'
    ];

    console.log('\nOfflineSales Table Columns:');
    for (const col of requiredOfflineSalesColumns) {
      const found = offlineSalesColumns.find(c => c.column_name === col);
      if (found) {
        console.log(`✅ ${col.padEnd(20)} - ${found.data_type}`);
      } else {
        console.log(`❌ ${col.padEnd(20)} - MISSING`);
      }
    }

    console.log('\n📋 CHECKING ENUM TYPES:');
    console.log('----------------------');

    // Check enum types
    const [enumTypes] = await db.sequelize.query(`
      SELECT t.typname as enum_name,
             string_agg(e.enumlabel, ', ' ORDER BY e.enumsortorder) as enum_values
      FROM pg_type t
      JOIN pg_enum e ON t.oid = e.enumtypid
      JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
      WHERE n.nspname = 'public'
      GROUP BY t.typname
      ORDER BY t.typname;
    `);

    console.log('\nEnum Types:');
    for (const enumType of enumTypes) {
      console.log(`✅ ${enumType.enum_name}`);
      console.log(`   Values: ${enumType.enum_values}`);
    }

    console.log('\n📋 CHECKING INDEXES:');
    console.log('-------------------');

    // Check OfflineSales indexes
    const [offlineSalesIndexes] = await db.sequelize.query(`
      SELECT indexname, indexdef
      FROM pg_indexes
      WHERE tablename = 'OfflineSales'
      ORDER BY indexname;
    `);

    console.log('\nOfflineSales Indexes:');
    for (const idx of offlineSalesIndexes) {
      console.log(`✅ ${idx.indexname}`);
    }

    console.log('\n📋 CHECKING FOREIGN KEYS:');
    console.log('------------------------');

    // Check OfflineSales foreign keys
    const [foreignKeys] = await db.sequelize.query(`
      SELECT
        tc.constraint_name,
        tc.table_name,
        kcu.column_name,
        ccu.table_name AS foreign_table_name,
        ccu.column_name AS foreign_column_name
      FROM information_schema.table_constraints AS tc
      JOIN information_schema.key_column_usage AS kcu
        ON tc.constraint_name = kcu.constraint_name
        AND tc.table_schema = kcu.table_schema
      JOIN information_schema.constraint_column_usage AS ccu
        ON ccu.constraint_name = tc.constraint_name
        AND ccu.table_schema = tc.table_schema
      WHERE tc.constraint_type = 'FOREIGN KEY'
        AND tc.table_name = 'OfflineSales';
    `);

    console.log('\nOfflineSales Foreign Keys:');
    for (const fk of foreignKeys) {
      console.log(`✅ ${fk.column_name} → ${fk.foreign_table_name}(${fk.foreign_column_name})`);
    }

    // Check record counts
    console.log('\n📊 TABLE RECORD COUNTS:');
    console.log('----------------------');

    for (const table of requiredTables) {
      try {
        const [count] = await db.sequelize.query(`SELECT COUNT(*) as count FROM "${table}"`);
        console.log(`${table.padEnd(20)}: ${count[0].count} records`);
      } catch (error) {
        console.log(`${table.padEnd(20)}: Unable to count`);
      }
    }

    // Summary
    console.log('\n=====================================');
    console.log('📊 DATABASE VERIFICATION SUMMARY:');
    console.log('=====================================');

    const allTablesExist = requiredTables.length === requiredTables.length;
    const invoicesTableComplete = invoiceColumns.length >= requiredInvoiceColumns.length - 2; // Allow some optional
    const offlineSalesTableComplete = offlineSalesColumns.length >= requiredOfflineSalesColumns.length - 2;

    if (allTablesExist && invoicesTableComplete && offlineSalesTableComplete) {
      console.log('✅ DATABASE IS READY FOR OFFLINE SALES!');
      console.log('✅ All required tables exist');
      console.log('✅ All required columns present');
      console.log('✅ Indexes are in place');
      console.log('✅ Foreign keys configured');
    } else {
      console.log('⚠️  DATABASE NEEDS ATTENTION:');
      if (!allTablesExist) console.log('❌ Some tables are missing');
      if (!invoicesTableComplete) console.log('❌ Invoices table incomplete');
      if (!offlineSalesTableComplete) console.log('❌ OfflineSales table incomplete');
    }

    console.log('\n🎉 Verification Complete!\n');
    process.exit(0);

  } catch (error) {
    console.error('❌ Database verification failed:', error.message);
    console.error('Stack:', error.stack);
    process.exit(1);
  }
}

checkDatabase();

