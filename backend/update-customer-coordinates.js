const db = require('./src/config/db');
const logger = require('./src/utils/logger');

// Customer data with location coordinates
const customerData = [
  { phone: '6281816608', name: 'bhanumathi', latitude: 14.451444, longitude: 79.990611 },
  { phone: '9949067872', name: 'Sunitha ch', latitude: 14.445917, longitude: 79.989333 },
  { phone: '9848618181', name: 'Amala', latitude: 14.445553, longitude: 79.990694 },
  { phone: '9440797915', name: 'Krishnaiah(MGB 204)', latitude: 14.445553, longitude: 79.990694 },
  { phone: '8886897373', name: 'kalpana ganesh spectra', latitude: 14.443889, longitude: 80.000972 },
  { phone: '7004674848', name: 'babu singh', latitude: 14.442500, longitude: 80.003194 },
  { phone: '9703354377', name: 'Lakshman (Renu Appt)', latitude: 14.442500, longitude: 80.003194 },
  { phone: '9966006543', name: 'narayana reddy', latitude: 14.436750, longitude: 80.002444 },
  { phone: '8885527221', name: 'arsdhad', latitude: 14.439167, longitude: 79.989236 },
  { phone: '9849229842', name: 'mohan raju', latitude: 14.439519, longitude: 79.988306 },
  { phone: '8309458661', name: 'ty krishna' },
  { phone: '9866820357', name: 'VenkatSubbaReddy(Jagans college opp) vasantha kumari' },
  { phone: '9490277115', name: 'kokila' },
  { phone: '9581608050', name: 'Anuradha' },
  { phone: '9885830453', name: 'haranath kumar' },
  { phone: '7659931114', name: 'himaja' },
  { phone: '9963833033', name: 'aswjtha(samilulla khan) charan squre 201' },
  { phone: '9290719527', name: 'varalaxmi    hotel   side' },
  { phone: '9133355500', name: 'manohar sharma' },
  { phone: '9440561266', name: 'madhu sudhan.K' },
  { phone: '8501934435', name: 'subramanam  opp madhusudan achristreet' },
  { phone: '8639989599', name: 'Ahamed' },
  { phone: '8919243284', name: 'venkatmanaj' },
  { phone: '9652848306', name: 'nushart' },
  { phone: '8247828007', name: 'sudheer d mart' },
  { phone: '9959130553', name: 'hima.' },
  { phone: '9959130553', name: 'JYOTHI' },
  { phone: '9989154505', name: 'balayha' },
  { phone: '7983186865', name: 'geetha renu residence 1 floor', latitude: 14.442500, longitude: 80.003194 },
  { phone: '9092448855', name: 'uma' }
];

async function updateCustomerCoordinates() {
  try {
    console.log('Starting bulk customer coordinate update...\n');

    let updateCount = 0;
    let skipCount = 0;
    let errorCount = 0;

    for (const customerInfo of customerData) {
      try {
        // Skip if no coordinates provided
        if (customerInfo.latitude === undefined || customerInfo.longitude === undefined) {
          console.log(`⏭️  Skipping ${customerInfo.phone} (${customerInfo.name}) - no coordinates provided`);
          skipCount++;
          continue;
        }

        // Find existing customer
        const existingUser = await db.User.findOne({
          where: { phone: customerInfo.phone }
        });

        if (!existingUser) {
          console.log(`❌ Customer not found: ${customerInfo.phone} (${customerInfo.name})`);
          errorCount++;
          continue;
        }

        // Update customer with coordinates
        await existingUser.update({
          latitude: customerInfo.latitude,
          longitude: customerInfo.longitude
        });

        console.log(`✅ Updated: ${customerInfo.phone} - ${customerInfo.name} (${customerInfo.latitude}, ${customerInfo.longitude})`);
        updateCount++;

      } catch (err) {
        console.error(`❌ Error updating customer ${customerInfo.phone} (${customerInfo.name}):`, err.message);
        errorCount++;
      }
    }

    console.log('\n=== Bulk Update Summary ===');
    console.log(`✅ Successfully updated: ${updateCount}`);
    console.log(`⏭️  Skipped (no coordinates): ${skipCount}`);
    console.log(`❌ Errors: ${errorCount}`);
    console.log(`📊 Total processed: ${customerData.length}`);

    process.exit(0);

  } catch (error) {
    logger.error('Fatal error during bulk update:', error);
    console.error('Fatal error:', error);
    process.exit(1);
  }
}

// Initialize database and run update
db.sequelize.sync().then(() => {
  updateCustomerCoordinates();
}).catch(error => {
  logger.error('Database sync error:', error);
  console.error('Database sync error:', error);
  process.exit(1);
});

