/**
 * Fix delivery amounts that are showing as 0
 * This script recalculates amounts for all deliveries based on their delivery items
 */

const db = require('./src/config/db');
const logger = require('./src/utils/logger');

async function fixDeliveryAmounts() {
  const transaction = await db.sequelize.transaction();

  try {
    console.log('Starting delivery amount fix...');

    // Get all deliveries
    const deliveries = await db.Delivery.findAll({
      include: [{
        model: db.DeliveryItem,
        as: 'items',
        include: [{
          model: db.Product,
          as: 'product'
        }]
      }],
      transaction
    });

    console.log(`Found ${deliveries.length} deliveries to check`);

    let fixedCount = 0;
    let skippedCount = 0;

    for (const delivery of deliveries) {
      // Calculate correct amount from delivery items
      let calculatedAmount = 0;

      if (delivery.items && delivery.items.length > 0) {
        for (const item of delivery.items) {
          calculatedAmount += parseFloat(item.price || 0);
        }
      } else {
        // If no items, try to get from subscription products
        const subscription = await db.Subscription.findByPk(delivery.subscriptionId, {
          include: [{
            model: db.SubscriptionProduct,
            as: 'products',
            include: [{
              model: db.Product,
              as: 'product'
            }]
          }],
          transaction
        });

        if (subscription && subscription.products) {
          for (const sp of subscription.products) {
            const itemPrice = parseFloat(sp.quantity) * parseFloat(sp.product.pricePerUnit);
            calculatedAmount += itemPrice;

            // Create missing delivery item
            await db.DeliveryItem.create({
              deliveryId: delivery.id,
              productId: sp.productId,
              quantity: sp.quantity,
              price: itemPrice,
              isOneTime: false
            }, { transaction });
          }
          console.log(`Created ${subscription.products.length} delivery items for delivery ${delivery.id}`);
        }
      }

      // Update if amount is different
      const currentAmount = parseFloat(delivery.amount || 0);
      if (Math.abs(currentAmount - calculatedAmount) > 0.01) {
        await delivery.update({ amount: calculatedAmount }, { transaction });
        console.log(`Fixed delivery ${delivery.id}: ${currentAmount} -> ${calculatedAmount}`);
        fixedCount++;
      } else {
        skippedCount++;
      }
    }

    await transaction.commit();

    console.log('\n=== Fix Complete ===');
    console.log(`Total deliveries checked: ${deliveries.length}`);
    console.log(`Deliveries fixed: ${fixedCount}`);
    console.log(`Deliveries already correct: ${skippedCount}`);

    process.exit(0);
  } catch (error) {
    await transaction.rollback();
    console.error('Error fixing delivery amounts:', error);
    process.exit(1);
  }
}

// Run the fix
fixDeliveryAmounts();

