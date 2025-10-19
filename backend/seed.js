const db = require('./src/config/db');
const bcrypt = require('bcrypt');

async function seedDatabase() {
  try {
    console.log('Starting database seeding...');

    await db.sequelize.sync({ force: false });
    console.log('Database synchronized');

    const adminPhone = process.env.ADMIN_PHONE || '+919876543210';
    const adminName = process.env.ADMIN_NAME || 'Admin User';

    const existingAdmin = await db.User.findOne({
      where: { phone: adminPhone }
    });

    if (!existingAdmin) {
      await db.User.create({
        name: adminName,
        phone: adminPhone,
        role: 'admin',
        isActive: true
      });
      console.log(`✓ Admin user created: ${adminPhone}`);
    } else {
      console.log('✓ Admin user already exists');
    }

    const products = [
      { name: 'Full Cream Milk', unit: 'liter', pricePerUnit: 60, description: 'Fresh full cream milk' },
      { name: 'Toned Milk', unit: 'liter', pricePerUnit: 50, description: 'Low fat toned milk' },
      { name: 'Double Toned Milk', unit: 'liter', pricePerUnit: 45, description: 'Very low fat milk' },
      { name: 'Cow Milk', unit: 'liter', pricePerUnit: 55, description: 'Pure cow milk' },
      { name: 'Buffalo Milk', unit: 'liter', pricePerUnit: 65, description: 'Pure buffalo milk' },
    ];

    for (const product of products) {
      const existing = await db.Product.findOne({ where: { name: product.name } });
      if (!existing) {
        await db.Product.create({
          ...product,
          isActive: true,
          stock: 1000
        });
        console.log(`✓ Product created: ${product.name}`);
      }
    }

    const areas = [
      { name: 'Zone A', description: 'North area' },
      { name: 'Zone B', description: 'South area' },
      { name: 'Zone C', description: 'East area' },
      { name: 'Zone D', description: 'West area' },
    ];

    for (const area of areas) {
      const existing = await db.Area.findOne({ where: { name: area.name } });
      if (!existing) {
        await db.Area.create({
          ...area,
          isActive: true
        });
        console.log(`✓ Area created: ${area.name}`);
      }
    }

    console.log('\n✅ Database seeding completed successfully!');
    console.log(`\nAdmin credentials:`);
    console.log(`Phone: ${adminPhone}`);
    console.log(`Role: admin`);
    console.log(`\nYou can now login using WhatsApp OTP authentication.`);
    
    process.exit(0);
  } catch (error) {
    console.error('Error seeding database:', error);
    process.exit(1);
  }
}

seedDatabase();
