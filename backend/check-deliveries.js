/**
 * Utility script to check and regenerate deliveries for subscriptions
 * Run this if deliveries are missing or not showing in monthly breakout
 */

const db = require('./src/config/db');
const subscriptionService = require('./src/services/subscription.service');
const logger = require('./src/utils/logger');

async function checkAndRegenerateDeliveries() {
  try {
    console.log('🔍 Checking subscriptions and deliveries...\n');

    // Get all active subscriptions
    const subscriptions = await db.Subscription.findAll({
      where: { status: 'active' },
      include: [
        {
          model: db.SubscriptionProduct,
          as: 'products',
          include: [{ model: db.Product, as: 'product' }]
        },
        {
          model: db.User,
          as: 'customer',
          include: [{
            model: db.Area,
            as: 'area',
            include: [{ model: db.User, as: 'deliveryBoy' }]
          }]
        }
      ]
    });

    console.log(`📊 Found ${subscriptions.length} active subscriptions\n`);

    for (const sub of subscriptions) {
      console.log(`\n🔖 Subscription ID: ${sub.id}`);
      console.log(`   Customer: ${sub.customer.name}`);
      console.log(`   Products: ${sub.products.map(p => p.product.name).join(', ')}`);
      console.log(`   Frequency: ${sub.frequency}`);
      console.log(`   Start Date: ${sub.startDate}`);

      // Check if customer has area and delivery boy
      if (!sub.customer.area) {
        console.log(`   ⚠️  WARNING: Customer has no area assigned!`);
        continue;
      }

      if (!sub.customer.area.deliveryBoy) {
        console.log(`   ⚠️  WARNING: Area has no delivery boy assigned!`);
        console.log(`   ℹ️  Action needed: Admin must assign delivery boy to area "${sub.customer.area.name}"`);
        continue;
      }

      console.log(`   ✅ Delivery Boy: ${sub.customer.area.deliveryBoy.name}`);

      // Check existing deliveries for October 2025
      const deliveries = await db.Delivery.findAll({
        where: {
          subscriptionId: sub.id,
          deliveryDate: {
            [db.Sequelize.Op.between]: ['2025-10-01', '2025-10-31']
          }
        },
        include: [{
          model: db.DeliveryItem,
          as: 'items'
        }]
      });

      console.log(`   📦 October deliveries: ${deliveries.length}`);

      if (deliveries.length > 0) {
        const totalAmount = deliveries.reduce((sum, d) => sum + parseFloat(d.amount), 0);
        console.log(`   💰 Total amount for October: ₹${totalAmount.toFixed(2)}`);

        // Show sample deliveries
        console.log(`   📅 Sample dates: ${deliveries.slice(0, 3).map(d => d.deliveryDate).join(', ')}`);
      } else {
        console.log(`   ⚠️  No deliveries found for October!`);
        console.log(`   🔄 Attempting to regenerate deliveries...`);

        try {
          const transaction = await db.sequelize.transaction();
          await subscriptionService.generateDeliveriesForSubscription(sub.id, transaction);
          await transaction.commit();
          console.log(`   ✅ Deliveries regenerated successfully!`);
        } catch (error) {
          console.log(`   ❌ Error regenerating deliveries: ${error.message}`);
        }
      }
    }

    console.log('\n\n📊 Summary Report:\n');
    console.log(`Total subscriptions checked: ${subscriptions.length}`);

    const subsWithNoArea = subscriptions.filter(s => !s.customer.area).length;
    const subsWithNoDeliveryBoy = subscriptions.filter(s => s.customer.area && !s.customer.area.deliveryBoy).length;

    if (subsWithNoArea > 0) {
      console.log(`⚠️  ${subsWithNoArea} customers need area assignment`);
    }

    if (subsWithNoDeliveryBoy > 0) {
      console.log(`⚠️  ${subsWithNoDeliveryBoy} areas need delivery boy assignment`);
    }

    console.log('\n✅ Check complete!\n');

  } catch (error) {
    console.error('❌ Error:', error);
    logger.error('Error checking deliveries:', error);
  } finally {
    await db.sequelize.close();
    process.exit(0);
  }
}

// Run the check
checkAndRegenerateDeliveries();

