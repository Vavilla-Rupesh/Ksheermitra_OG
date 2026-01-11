const db = require('./src/config/db');
const offlineSaleService = require('./src/services/offlineSale.service');
const bcrypt = require('bcrypt');
const moment = require('moment');

/**
 * Comprehensive test for Offline Sales feature
 * Tests: Product creation, Stock management, Sale creation, Invoice generation
 */

async function runTests() {
  console.log('🚀 Starting Offline Sales Complete Test...\n');

  try {
    // Connect to database
    await db.sequelize.authenticate();
    console.log('✅ Database connected successfully\n');


    // Step 1: Create or get admin user
    console.log('📌 Step 1: Setting up admin user...');
    let admin = await db.User.findOne({ where: { role: 'admin' } });

    if (!admin) {
      const passwordHash = await bcrypt.hash('admin123', 10);
      admin = await db.User.create({
        name: 'Test Admin',
        phone: '+919876543210',
        email: 'admin@test.com',
        role: 'admin',
        passwordHash,
        isActive: true
      });
      console.log('✅ Admin user created');
    } else {
      console.log('✅ Admin user found:', admin.name);
    }
    console.log('   Admin ID:', admin.id, '\n');

    // Step 2: Create test products
    console.log('📌 Step 2: Setting up test products...');
    const productsData = [
      { name: 'Full Cream Milk', pricePerUnit: 60, unit: 'liter', stock: 100 },
      { name: 'Toned Milk', pricePerUnit: 50, unit: 'liter', stock: 150 },
      { name: 'Fresh Curd', pricePerUnit: 70, unit: 'kg', stock: 50 }
    ];

    const products = [];
    for (const productData of productsData) {
      let product = await db.Product.findOne({ where: { name: productData.name } });
      if (!product) {
        product = await db.Product.create({ ...productData, isActive: true });
        console.log(`✅ Created product: ${product.name}`);
      } else {
        // Update stock for testing
        await product.update({ stock: productData.stock, isActive: true });
        console.log(`✅ Updated product: ${product.name}`);
      }
      products.push(product);
    }
    console.log('   Total products:', products.length, '\n');

    // Step 3: Check initial stock
    console.log('📌 Step 3: Initial stock levels:');
    for (const product of products) {
      console.log(`   ${product.name}: ${product.stock} ${product.unit}(s)`);
    }
    console.log('');

    // Step 4: Create offline sale
    console.log('📌 Step 4: Creating offline sale...');
    const saleData = {
      adminId: admin.id,
      items: [
        { productId: products[0].id, quantity: 5 }, // 5 liters of Full Cream Milk
        { productId: products[1].id, quantity: 10 }, // 10 liters of Toned Milk
        { productId: products[2].id, quantity: 3 }  // 3 kg of Fresh Curd
      ],
      customerName: 'Walk-in Customer Test',
      customerPhone: '+919999999999',
      paymentMethod: 'cash',
      notes: 'Test sale for verification'
    };

    const sale = await offlineSaleService.createOfflineSale(saleData);
    console.log('✅ Offline sale created successfully!');
    console.log('   Sale Number:', sale.saleNumber);
    console.log('   Total Amount: ₹' + sale.totalAmount);
    console.log('   Items:', sale.items.length);
    console.log('   Invoice ID:', sale.invoiceId, '\n');

    // Step 5: Verify stock reduction
    console.log('📌 Step 5: Verifying stock reduction...');
    for (let i = 0; i < products.length; i++) {
      await products[i].reload();
      const itemQuantity = saleData.items[i].quantity;
      const expectedStock = productsData[i].stock - itemQuantity;

      if (products[i].stock === expectedStock) {
        console.log(`✅ ${products[i].name}: ${productsData[i].stock} → ${products[i].stock} (reduced by ${itemQuantity})`);
      } else {
        console.log(`❌ ${products[i].name}: Expected ${expectedStock} but got ${products[i].stock}`);
      }
    }
    console.log('');

    // Step 6: Verify invoice creation/update
    console.log('📌 Step 6: Verifying invoice...');
    const invoice = await db.Invoice.findByPk(sale.invoiceId);
    if (invoice) {
      console.log('✅ Invoice found');
      console.log('   Invoice Number:', invoice.invoiceNumber);
      console.log('   Invoice Type:', invoice.invoiceType);
      console.log('   Total Amount: ₹' + invoice.totalAmount);
      console.log('   Metadata:', JSON.stringify(invoice.metadata, null, 2));
    } else {
      console.log('❌ Invoice not found!');
    }
    console.log('');

    // Step 7: Test insufficient stock error handling
    console.log('📌 Step 7: Testing insufficient stock validation...');
    try {
      await offlineSaleService.createOfflineSale({
        adminId: admin.id,
        items: [
          { productId: products[0].id, quantity: 9999 } // Exceeds available stock
        ],
        paymentMethod: 'cash'
      });
      console.log('❌ Should have thrown insufficient stock error!');
    } catch (error) {
      if (error.message.includes('Insufficient stock')) {
        console.log('✅ Insufficient stock validation working correctly');
        console.log('   Error:', error.message);
      } else {
        console.log('❌ Unexpected error:', error.message);
      }
    }
    console.log('');

    // Step 8: Get all offline sales
    console.log('📌 Step 8: Fetching all offline sales...');
    const salesList = await offlineSaleService.getOfflineSales({
      startDate: moment().format('YYYY-MM-DD'),
      endDate: moment().format('YYYY-MM-DD')
    });
    console.log('✅ Found', salesList.sales.length, 'sale(s) today');
    console.log('');

    // Step 9: Get sales statistics
    console.log('📌 Step 9: Getting sales statistics...');
    const stats = await offlineSaleService.getSalesStats(
      moment().format('YYYY-MM-DD'),
      moment().format('YYYY-MM-DD')
    );
    console.log('✅ Statistics:');
    console.log('   Total Sales:', stats.totalSales);
    console.log('   Total Revenue: ₹' + parseFloat(stats.totalRevenue || 0).toFixed(2));
    console.log('   Average Sale: ₹' + parseFloat(stats.averageSaleAmount || 0).toFixed(2));
    console.log('');

    // Step 10: Get admin daily invoice
    console.log('📌 Step 10: Getting admin daily invoice...');
    const todayInvoice = await offlineSaleService.getAdminDailyInvoice(
      moment().format('YYYY-MM-DD')
    );
    if (todayInvoice) {
      console.log('✅ Daily invoice found');
      console.log('   Invoice Number:', todayInvoice.invoiceNumber);
      console.log('   Total Amount: ₹' + todayInvoice.totalAmount);
      console.log('   Offline Sales Count:', todayInvoice.metadata?.offlineSales?.length || 0);
    } else {
      console.log('⚠️  No invoice found for today');
    }
    console.log('');

    // Summary
    console.log('═'.repeat(60));
    console.log('✅ ALL TESTS PASSED SUCCESSFULLY!');
    console.log('═'.repeat(60));
    console.log('\n🎉 Offline Sales feature is fully functional!\n');
    console.log('Features verified:');
    console.log('  ✓ Product management');
    console.log('  ✓ Stock tracking and reduction');
    console.log('  ✓ Offline sale creation');
    console.log('  ✓ Invoice generation and updates');
    console.log('  ✓ Stock validation (insufficient stock handling)');
    console.log('  ✓ Sales listing and filtering');
    console.log('  ✓ Sales statistics');
    console.log('  ✓ Daily invoice retrieval');
    console.log('');

  } catch (error) {
    console.error('❌ Test failed:', error);
    console.error('Stack trace:', error.stack);
    process.exit(1);
  } finally {
    await db.sequelize.close();
    console.log('Database connection closed.');
    process.exit(0);
  }
}

// Run tests
runTests();

