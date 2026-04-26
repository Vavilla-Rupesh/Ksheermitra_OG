module.exports = (sequelize, DataTypes) => {
  const WhatsAppSession = sequelize.define('WhatsAppSession', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    sessionQrCode: {
      type: DataTypes.TEXT,
      allowNull: true,
      comment: 'Current QR code for WhatsApp login'
    },
    lastQrGeneratedAt: {
      type: DataTypes.DATE,
      allowNull: true,
      comment: 'When the last QR code was generated'
    },
    sessionStartedAt: {
      type: DataTypes.DATE,
      allowNull: true,
      comment: 'When the WhatsApp session started'
    },
    sessionExpiresAt: {
      type: DataTypes.DATE,
      allowNull: true,
      comment: 'Estimated expiration time of the session'
    },
    isConnected: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
      comment: 'Is WhatsApp currently connected'
    },
    connectionState: {
      type: DataTypes.ENUM('disconnected', 'connecting', 'open', 'closed'),
      defaultValue: 'disconnected',
      comment: 'Current connection state'
    },
    expirationNotificationSentAt: {
      type: DataTypes.DATE,
      allowNull: true,
      comment: 'When the expiration notification was sent to admin'
    },
    metadata: {
      type: DataTypes.JSON,
      allowNull: true,
      comment: 'Additional session metadata'
    }
  }, {
    tableName: 'WhatsAppSessions',
    timestamps: true
  });

  return WhatsAppSession;
};

