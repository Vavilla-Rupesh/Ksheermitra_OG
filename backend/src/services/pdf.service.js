const PDFDocument = require('pdfkit');
const fs = require('fs');
const path = require('path');
const logger = require('../utils/logger');

class PDFService {
  constructor() {
    this.invoicesDir = path.join(__dirname, '../../invoices');
    this.ensureDirectoryExists();
  }

  ensureDirectoryExists() {
    if (!fs.existsSync(this.invoicesDir)) {
      fs.mkdirSync(this.invoicesDir, { recursive: true });
    }
  }

  async generateDailyInvoice(invoiceData) {
    try {
      const {
        invoiceNumber,
        deliveryBoy,
        date,
        deliveries,
        totalAmount
      } = invoiceData;

      const fileName = `daily_${invoiceNumber}_${Date.now()}.pdf`;
      const filePath = path.join(this.invoicesDir, fileName);

      return new Promise((resolve, reject) => {
        const doc = new PDFDocument({ margin: 50, size: 'A4' });
        const stream = fs.createWriteStream(filePath);

        doc.pipe(stream);

        this.addHeader(doc, 'Daily Delivery Invoice');

        doc.fontSize(12)
           .text(`Invoice Number: ${invoiceNumber}`, 50, 150)
           .text(`Date: ${date}`, 50, 170)
           .text(`Delivery Boy: ${deliveryBoy.name}`, 50, 190)
           .text(`Phone: ${deliveryBoy.phone}`, 50, 210);

        doc.moveDown(2);
        
        const tableTop = 260;
        this.generateDeliveryTable(doc, deliveries, tableTop);

        const totalY = tableTop + (deliveries.length + 2) * 25 + 20;
        doc.fontSize(12)
           .font('Helvetica-Bold')
           .text(`Total Amount: ₹${parseFloat(totalAmount).toFixed(2)}`, 400, totalY);

        this.addFooter(doc);

        doc.end();

        stream.on('finish', () => {
          logger.info(`Daily invoice generated: ${fileName}`);
          resolve(filePath);
        });

        stream.on('error', (error) => {
          logger.error('Error generating daily invoice:', error);
          reject(error);
        });
      });
    } catch (error) {
      logger.error('Error in generateDailyInvoice:', error);
      throw error;
    }
  }

  async generateMonthlyInvoice(invoiceData) {
    try {
      const {
        invoiceNumber,
        customer,
        periodStart,
        periodEnd,
        deliveries,
        totalAmount,
        paidAmount,
        paymentStatus
      } = invoiceData;

      const fileName = `monthly_${invoiceNumber}_${Date.now()}.pdf`;
      const filePath = path.join(this.invoicesDir, fileName);

      return new Promise((resolve, reject) => {
        const doc = new PDFDocument({ margin: 50, size: 'A4' });
        const stream = fs.createWriteStream(filePath);

        doc.pipe(stream);

        this.addHeader(doc, 'Monthly Invoice');

        doc.fontSize(12)
           .text(`Invoice Number: ${invoiceNumber}`, 50, 150)
           .text(`Customer Name: ${customer.name}`, 50, 170)
           .text(`Phone: ${customer.phone}`, 50, 190)
           .text(`Address: ${customer.address || 'N/A'}`, 50, 210)
           .text(`Period: ${periodStart} to ${periodEnd}`, 50, 230);

        doc.moveDown(2);

        const tableTop = 280;
        this.generateMonthlyDeliveryTable(doc, deliveries, tableTop);

        const summaryY = tableTop + (deliveries.length + 2) * 25 + 30;
        
        doc.fontSize(12)
           .font('Helvetica-Bold')
           .text(`Total Amount: ₹${parseFloat(totalAmount).toFixed(2)}`, 400, summaryY)
           .text(`Paid Amount: ₹${parseFloat(paidAmount).toFixed(2)}`, 400, summaryY + 20)
           .text(`Balance Due: ₹${(parseFloat(totalAmount) - parseFloat(paidAmount)).toFixed(2)}`, 400, summaryY + 40)
           .text(`Status: ${paymentStatus.toUpperCase()}`, 400, summaryY + 60);

        this.addFooter(doc);

        doc.end();

        stream.on('finish', () => {
          logger.info(`Monthly invoice generated: ${fileName}`);
          resolve(filePath);
        });

        stream.on('error', (error) => {
          logger.error('Error generating monthly invoice:', error);
          reject(error);
        });
      });
    } catch (error) {
      logger.error('Error in generateMonthlyInvoice:', error);
      throw error;
    }
  }

  addHeader(doc, title) {
    doc.fontSize(20)
       .font('Helvetica-Bold')
       .text(process.env.COMPANY_NAME || 'Ksheermitra', 50, 50);

    doc.fontSize(10)
       .font('Helvetica')
       .text(process.env.COMPANY_ADDRESS || 'Company Address', 50, 75)
       .text(`Phone: ${process.env.COMPANY_PHONE || 'N/A'}`, 50, 90)
       .text(`Email: ${process.env.COMPANY_EMAIL || 'N/A'}`, 50, 105);

    doc.fontSize(16)
       .font('Helvetica-Bold')
       .text(title, 400, 50);

    doc.moveTo(50, 130)
       .lineTo(550, 130)
       .stroke();
  }

  addFooter(doc) {
    const bottomY = 750;
    
    doc.moveTo(50, bottomY)
       .lineTo(550, bottomY)
       .stroke();

    doc.fontSize(10)
       .font('Helvetica')
       .text('Thank you for your business!', 50, bottomY + 10)
       .text(`Generated on: ${new Date().toLocaleString()}`, 400, bottomY + 10);
  }

  generateDeliveryTable(doc, deliveries, startY) {
    const headers = ['Customer', 'Product', 'Quantity', 'Amount'];
    const columnWidths = [150, 150, 100, 100];
    const startX = 50;

    doc.fontSize(10).font('Helvetica-Bold');
    headers.forEach((header, i) => {
      const x = startX + columnWidths.slice(0, i).reduce((a, b) => a + b, 0);
      doc.text(header, x, startY);
    });

    doc.moveTo(startX, startY + 15)
       .lineTo(550, startY + 15)
       .stroke();

    doc.font('Helvetica');
    deliveries.forEach((delivery, index) => {
      const y = startY + 25 + (index * 25);
      
      doc.text(delivery.customerName || 'N/A', startX, y, { width: 140 });
      doc.text(delivery.productName || 'N/A', startX + 150, y, { width: 140 });
      doc.text(`${delivery.quantity} ${delivery.unit || ''}`, startX + 300, y);
      doc.text(`₹${parseFloat(delivery.amount).toFixed(2)}`, startX + 400, y);
    });
  }

  generateMonthlyDeliveryTable(doc, deliveries, startY) {
    const headers = ['Date', 'Product', 'Quantity', 'Amount'];
    const columnWidths = [100, 200, 100, 100];
    const startX = 50;

    doc.fontSize(10).font('Helvetica-Bold');
    headers.forEach((header, i) => {
      const x = startX + columnWidths.slice(0, i).reduce((a, b) => a + b, 0);
      doc.text(header, x, startY);
    });

    doc.moveTo(startX, startY + 15)
       .lineTo(550, startY + 15)
       .stroke();

    doc.font('Helvetica');
    deliveries.forEach((delivery, index) => {
      const y = startY + 25 + (index * 25);
      
      doc.text(delivery.date, startX, y);
      doc.text(delivery.productName || 'N/A', startX + 100, y, { width: 190 });
      doc.text(`${delivery.quantity} ${delivery.unit || ''}`, startX + 300, y);
      doc.text(`₹${parseFloat(delivery.amount).toFixed(2)}`, startX + 400, y);
    });
  }
}

module.exports = new PDFService();
