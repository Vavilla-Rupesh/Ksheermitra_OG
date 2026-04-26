const fs = require('fs');
const path = require('path');
const logger = require('../utils/logger');
const db = require('../config/db');

/**
 * Initialization Service
 * Runs on server startup to:
 * 1. Ensure admin user exists with credentials from env
 * 2. Seed customers from seed-customers.txt file
 * 3. Delete seed file after successful insertion
 */

class InitializationService {
  /**
   * Parse DMS (Degrees, Minutes, Seconds) to Decimal
   * Example: 14°27'05.2"N = 14.45144
   */
  parseDMS(dms) {
    if (!dms || dms.trim() === '') return null;

    try {
      // Remove spaces and convert direction letters
      const str = dms.trim().replace(/\s/g, '');
      const isNegative = /[SW]/.test(str);

      // Extract degrees, minutes, seconds
      const degMatch = str.match(/(\d+)°/);
      const minMatch = str.match(/(\d+)'/);
      const secMatch = str.match(/(\d+(?:\.\d+)?)"/);

      if (!degMatch) return null;

      const degrees = parseFloat(degMatch[1]);
      const minutes = minMatch ? parseFloat(minMatch[1]) : 0;
      const seconds = secMatch ? parseFloat(secMatch[1]) : 0;

      let decimal = degrees + minutes / 60 + seconds / 3600;
      return isNegative ? -decimal : decimal;
    } catch (error) {
      logger.warn(`Failed to parse DMS: ${dms}`, error);
      return null;
    }
  }

  /**
   * Initialize on server startup
   */
  async initialize() {
    try {
      logger.info('Starting initialization service...');

      // Step 1: Ensure admin user exists
      await this.ensureAdminExists();

      // Step 2: Seed customers if file exists
      await this.seedCustomersIfFileExists();

      logger.info('Initialization completed successfully');
    } catch (error) {
      logger.error('Initialization error:', error);
      logger.warn('Server will continue, but initialization may be incomplete');
    }
  }

  /**
   * Ensure admin user exists with credentials from environment
   */
  async ensureAdminExists() {
    try {
      const adminPhone = process.env.ADMIN_PHONE || '8374186557';
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
        logger.info(`✅ Admin user created: ${adminPhone} (${adminName})`);
      } else {
        // Ensure the existing user has admin role and is active
        if (existingAdmin.role !== 'admin' || !existingAdmin.isActive) {
          await existingAdmin.update({ role: 'admin', isActive: true });
          logger.info(`✅ Admin user updated: ${adminPhone}`);
        } else {
          logger.info(`✅ Admin user verified: ${adminName} (${adminPhone})`);
        }
      }
    } catch (error) {
      logger.error('Error ensuring admin exists:', error);
      throw error;
    }
  }

  /**
   * Seed customers from file if it exists
   */
  async seedCustomersIfFileExists() {
    try {
      const seedFilePath = path.join(__dirname, '../../seed-customers.txt');

      // Check if seed file exists
      if (!fs.existsSync(seedFilePath)) {
        logger.info('ℹ️  No seed-customers.txt file found. Skipping customer seeding.');
        return;
      }

      logger.info('📥 Found seed-customers.txt. Starting customer seeding...');

      // Read the file
      const fileContent = fs.readFileSync(seedFilePath, 'utf-8');
      const lines = fileContent.trim().split('\n');

      let insertedCount = 0;
      let skippedCount = 0;
      const errors = [];

      // Process each line
      for (const line of lines) {
        if (!line.trim()) continue;

        try {
          const parts = line.split('\t');
          const phone = parts[0]?.trim();
          const name = parts[1]?.trim();
          const latDMS = parts[2]?.trim();
          const lonDMS = parts[3]?.trim();

          if (!phone || !name) {
            skippedCount++;
            continue;
          }

          // Parse DMS coordinates
          const latitude = this.parseDMS(latDMS);
          const longitude = this.parseDMS(lonDMS);

          // Check if customer already exists
          const existingCustomer = await db.User.findOne({
            where: { phone }
          });

          if (existingCustomer) {
            skippedCount++;
            logger.debug(`Customer already exists: ${phone}`);
            continue;
          }

          // Create customer
          await db.User.create({
            phone,
            name,
            latitude: latitude, // Can be null
            longitude: longitude, // Can be null
            role: 'customer',
            isActive: true
          });

          insertedCount++;
        } catch (error) {
          logger.error(`Error processing line: ${line}`, error);
          errors.push({ line, error: error.message });
        }
      }

      logger.info(`✅ Customer seeding completed:`);
      logger.info(`   - Inserted: ${insertedCount}`);
      logger.info(`   - Skipped: ${skippedCount}`);
      if (errors.length > 0) {
        logger.warn(`   - Errors: ${errors.length}`);
        errors.slice(0, 5).forEach(e => {
          logger.warn(`     Error: ${e.error}`);
        });
      }

      // Delete the seed file after successful processing
      try {
        fs.unlinkSync(seedFilePath);
        logger.info('🗑️  Seed file deleted: seed-customers.txt');
      } catch (deleteError) {
        logger.warn('Failed to delete seed file:', deleteError.message);
      }
    } catch (error) {
      logger.error('Error in customer seeding:', error);
      // Don't throw - let server continue
    }
  }
}

module.exports = new InitializationService();

