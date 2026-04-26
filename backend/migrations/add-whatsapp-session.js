'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    /**
     * Add altering commands here.
     *
     * Example:
     * await queryInterface.createTable('users', { id: Sequelize.INTEGER });
     */
    await queryInterface.createTable('WhatsAppSessions', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true
      },
      sessionQrCode: {
        type: Sequelize.TEXT,
        allowNull: true,
        comment: 'Current QR code for WhatsApp login'
      },
      lastQrGeneratedAt: {
        type: Sequelize.DATE,
        allowNull: true,
        comment: 'When the last QR code was generated'
      },
      sessionStartedAt: {
        type: Sequelize.DATE,
        allowNull: true,
        comment: 'When the WhatsApp session started'
      },
      sessionExpiresAt: {
        type: Sequelize.DATE,
        allowNull: true,
        comment: 'Estimated expiration time of the session'
      },
      isConnected: {
        type: Sequelize.BOOLEAN,
        defaultValue: false,
        comment: 'Is WhatsApp currently connected'
      },
      connectionState: {
        type: Sequelize.ENUM('disconnected', 'connecting', 'open', 'closed'),
        defaultValue: 'disconnected',
        comment: 'Current connection state'
      },
      expirationNotificationSentAt: {
        type: Sequelize.DATE,
        allowNull: true,
        comment: 'When the expiration notification was sent to admin'
      },
      metadata: {
        type: Sequelize.JSON,
        allowNull: true,
        comment: 'Additional session metadata'
      },
      createdAt: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      },
      updatedAt: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      }
    });
  },

  async down(queryInterface, Sequelize) {
    /**
     * Add reverting commands here.
     *
     * Example:
     * await queryInterface.dropTable('users');
     */
    await queryInterface.dropTable('WhatsAppSessions');
  }
};

