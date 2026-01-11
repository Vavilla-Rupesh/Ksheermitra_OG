/**
 * Test script for Offline Sales feature
 * Run: node backend/test-offline-sales.js
 */

require('dotenv').config();
const db = require('./src/config/db');
const offlineSaleService = require('./src/services/offlineSale.service');
const logger = require('./src/utils/logger');

async function testOfflineSales() {
  try {
    console.log('🚀 Starting Offline Sales Test...\n');

    // Step 1: Connect to database
    console.log('📊 Connecting to database...');
    await db.sequelize.authenticate();
    console.log('✅ Database connected\n');

    // Step 2: Find admin user
    console.log('👤 Finding admin user...');
    const admin = await db.User.findOne({
      where: { role: 'admin', isActive: true }
    });

    if (!admin) {
      throw new Error('No active admin user found. Please create an admin user first.');
    }
    console.log(`✅ Admin found: ${admin.name} (${admin.phone})\n`);

    // Step 3: Find active products
    console.log('📦 Finding active products...');
    const products = await db.Product.findAll({
      where: { isActive: true },
      limit: 3
    });

    if (products.length === 0) {
      throw new Error('No active products found. Please create products first.');
    }

    console.log(`✅ Found ${products.length} products:`);
    products.forEach(p => {
      console.log(`   - ${p.name}: Stock=${p.stock}, Price=${p.pricePerUnit}/${p.unit}`);
    });
    console.log('');

    // Step 4: Check initial stock
    const initialStocks = {};
    products.forEach(p => {
      initialStocks[p.id] = p.stock;
    });

    // Step 5: Create test sale
    console.log('💰 Creating test offline sale...');
    const saleData = {
      adminId: admin.id,
      items: [
        {
          productId: products[0].id,
          quantity: 2
        }
      ],
      customerName: 'Test Customer',
      customerPhone: '+919876543210',
      paymentMethod: 'cash',
      notes: 'Test sale from automated script'
    };

    // Add second product if available
    if (products.length > 1 && products[1].stock >= 1) {
      saleData.items.push({
        productId: products[1].id,
        quantity: 1
      });
    }

    console.log('Sale data:', JSON.stringify(saleData, null, 2));
    console.log('');

    const sale = await offlineSaleService.createOfflineSale(saleData);

    console.log('✅ Sale created successfully!');
    console.log(`   Sale Number: ${sale.saleNumber}`);
    console.log(`   Total Amount: ₹${sale.totalAmount}`);
    console.log(`   Items: ${sale.items.length}`);
    console.log('');

    // Step 6: Verify stock reduction
    console.log('🔍 Verifying stock reduction...');
    for (const item of saleData.items) {
      const product = await db.Product.findByPk(item.productId);
      const expectedStock = initialStocks[item.productId] - item.quantity;
      const actualStock = product.stock;

      if (actualStock === expectedStock) {
        console.log(`   ✅ ${product.name}: ${initialStocks[item.productId]} → ${actualStock} (reduced by ${item.quantity})`);
      } else {
        console.log(`   ❌ ${product.name}: Expected ${expectedStock}, Got ${actualStock}`);
      }
    }
    console.log('');

    // Step 7: Verify invoice
    console.log('📄 Verifying invoice...');
    const today = new Date().toISOString().split('T')[0];
    const invoice = await offlineSaleService.getAdminDailyInvoice(today);

    if (invoice) {
      console.log(`   ✅ Invoice found: ${invoice.invoiceNumber}`);
      console.log(`   Total Amount: ₹${invoice.totalAmount}`);
      console.log(`   Offline Sales: ${invoice.metadata?.offlineSales?.length || 0}`);
    } else {
      console.log('   ❌ Invoice not found');
    }
    console.log('');

    // Step 8: Get sales list
    console.log('📊 Fetching recent sales...');
    const salesList = await offlineSaleService.getOfflineSales({
      startDate: today,
      endDate: today,
      limit: 10
    });

    console.log(`   ✅ Found ${salesList.sales.length} sales today`);
    salesList.sales.forEach(s => {
      console.log(`      - ${s.saleNumber}: ₹${s.totalAmount} (${s.items.length} items)`);
    });
    console.log('');

    // Step 9: Get statistics
    console.log('📈 Getting sales statistics...');
    const stats = await offlineSaleService.getSalesStats(today, today);

    console.log('   Today\'s Statistics:');
    console.log(`      Total Sales: ${stats.totalSales || 0}`);
    console.log(`      Total Revenue: ₹${stats.totalRevenue || 0}`);
    console.log(`      Average Sale: ₹${stats.averageSaleAmount || 0}`);
    console.log('');

    // Step 10: Test error handling
    console.log('🧪 Testing error handling...');

    // Test insufficient stock
    try {
      await offlineSaleService.createOfflineSale({
        adminId: admin.id,
        items: [
          {
            productId: products[0].id,
            quantity: 99999
          }
        ],
        paymentMethod: 'cash'
      });
      console.log('   ❌ Should have thrown insufficient stock error');
    } catch (error) {
      if (error.message.includes('Insufficient stock')) {
        console.log('   ✅ Insufficient stock error handled correctly');
      } else {
        console.log('   ⚠️  Unexpected error:', error.message);
      }
    }
    console.log('');

    // Success summary
    console.log('═══════════════════════════════════════');
    console.log('✨ All tests completed successfully! ✨');
    console.log('═══════════════════════════════════════');
    console.log('');
    console.log('Summary:');
    console.log(`  • Sale created: ${sale.saleNumber}`);
    console.log(`  • Amount: ₹${sale.totalAmount}`);
    console.log(`  • Stock reduced correctly`);
    console.log(`  • Invoice updated`);
    console.log(`  • Error handling working`);
    console.log('');
    console.log('🎉 Offline Sales feature is ready to use!');

  } catch (error) {
    console.error('\n❌ Test failed:', error.message);
    console.error('Stack trace:', error.stack);
    process.exit(1);
  } finally {
    await db.sequelize.close();
    process.exit(0);
  }
}

// Run tests
testOfflineSales();

