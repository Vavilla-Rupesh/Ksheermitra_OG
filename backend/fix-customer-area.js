/**
 * Quick fix: Assign customer to an area
 * This will allow deliveries to be generated
 */

const db = require('./src/config/db');
const logger = require('./src/utils/logger');

async function assignCustomerToArea() {
  try {
    console.log('🔧 Assigning customer to area...\n');

    // Get the customer
    const customer = await db.User.findOne({
      where: { name: 'VR', role: 'customer' }
    });

    if (!customer) {
      console.log('❌ Customer "VR" not found');
      return;
    }

    console.log(`✅ Found customer: ${customer.name} (${customer.phone})`);

    // Get or create an area
    let area = await db.Area.findOne();

    if (!area) {
      console.log('📍 No areas found. Creating default area...');
      area = await db.Area.create({
        name: 'Default Area',
        description: 'Default delivery area'
      });
      console.log(`✅ Created area: ${area.name}`);
    } else {
      console.log(`✅ Using existing area: ${area.name}`);
    }

    // Get or create a delivery boy
    let deliveryBoy = await db.User.findOne({
      where: { role: 'delivery_boy' }
    });

    if (!deliveryBoy) {
      console.log('🚚 No delivery boys found. You need to create one via admin panel.');
      console.log('   For now, assigning area without delivery boy.');
    } else {
      console.log(`✅ Found delivery boy: ${deliveryBoy.name}`);

      // Assign delivery boy to area
      await area.update({ deliveryBoyId: deliveryBoy.id });
      console.log(`✅ Assigned delivery boy to area`);
    }

    // Assign customer to area
    await customer.update({ areaId: area.id });
    console.log(`✅ Assigned customer to area`);

    console.log('\n🎉 Customer area assignment complete!\n');
    console.log('Now regenerating deliveries for all subscriptions...\n');

    // Regenerate deliveries for all customer subscriptions
    const subscriptions = await db.Subscription.findAll({
      where: { customerId: customer.id, status: 'active' }
    });

    const subscriptionService = require('./src/services/subscription.service');

    for (const sub of subscriptions) {
      try {
        const transaction = await db.sequelize.transaction();
        await subscriptionService.generateDeliveriesForSubscription(sub.id, transaction);
        await transaction.commit();
        console.log(`✅ Deliveries generated for subscription ${sub.id}`);
      } catch (error) {
        console.log(`⚠️  Could not generate deliveries for ${sub.id}: ${error.message}`);
      }
    }

    console.log('\n✅ All done! Refresh your app to see the updated monthly breakout.\n');

  } catch (error) {
    console.error('❌ Error:', error);
    logger.error('Error assigning area:', error);
  } finally {
    await db.sequelize.close();
    process.exit(0);
  }
}

assignCustomerToArea();

