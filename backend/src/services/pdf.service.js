const PDFDocument = require('pdfkit');
const fs = require('fs');
const path = require('path');
const logger = require('../utils/logger');

// Currency symbol - use 'Rs.' since default PDFKit fonts don't support ₹
const RUPEE = 'Rs.';

class PDFService {
  constructor() {
    this.invoicesDir = path.join(__dirname, '../../invoices');
    this.ensureDirectoryExists();
  }

  ensureDirectoryExists() {
    try {
      if (!fs.existsSync(this.invoicesDir)) {
        fs.mkdirSync(this.invoicesDir, { recursive: true });
        logger.info(`Created invoices directory: ${this.invoicesDir}`);
      }
    } catch (error) {
      logger.error('Error creating invoices directory:', error.message);
    }
  }

  // Sanitize filename to remove characters invalid on Windows
  sanitizeFileName(name) {
    return name.replace(/[^a-zA-Z0-9._-]/g, '_');
  }

  async generateDailyInvoice(invoiceData) {
    try {
      // Ensure directory exists before generating
      this.ensureDirectoryExists();

      const {
        invoiceNumber,
        deliveryBoy,
        date,
        deliveries,
        totalAmount
      } = invoiceData;

      if (!invoiceNumber || !deliveryBoy) {
        throw new Error('Missing required invoice data: invoiceNumber or deliveryBoy');
      }

      const sanitizedInvoiceNum = this.sanitizeFileName(invoiceNumber);
      const fileName = `daily_${sanitizedInvoiceNum}_${Date.now()}.pdf`;
      const filePath = path.join(this.invoicesDir, fileName);

      logger.info(`Generating daily invoice PDF: ${fileName}`);
      logger.info(`Invoice data - deliveries: ${(deliveries || []).length}, totalAmount: ${totalAmount}`);

      return new Promise((resolve, reject) => {
        try {
          const doc = new PDFDocument({ margin: 50, size: 'A4' });
          const stream = fs.createWriteStream(filePath);

          // Handle stream errors
          stream.on('error', (error) => {
            logger.error('Stream error generating daily invoice:', error.message);
            reject(error);
          });

          doc.on('error', (error) => {
            logger.error('PDFDocument error:', error.message);
            reject(error);
          });

          doc.pipe(stream);

          this.addHeader(doc, 'Daily Delivery Invoice');

          doc.fontSize(12)
             .font('Helvetica')
             .text(`Invoice Number: ${invoiceNumber}`, 50, 150)
             .text(`Date: ${date || 'N/A'}`, 50, 170)
             .text(`Delivery Boy: ${deliveryBoy.name || 'N/A'}`, 50, 190)
             .text(`Phone: ${deliveryBoy.phone || 'N/A'}`, 50, 210);

          doc.moveDown(2);

          const safeDeliveries = Array.isArray(deliveries) ? deliveries : [];
          const tableTop = 260;

          if (safeDeliveries.length > 0) {
            this.generateDeliveryTable(doc, safeDeliveries, tableTop);
          } else {
            doc.fontSize(11)
               .font('Helvetica')
               .text('No delivery details available.', 50, tableTop);
          }

          const totalY = tableTop + (safeDeliveries.length + 2) * 25 + 20;
          doc.fontSize(12)
             .font('Helvetica-Bold')
             .text(`Total Amount: ${RUPEE} ${parseFloat(totalAmount || 0).toFixed(2)}`, 350, totalY);

          this.addFooter(doc);

          doc.end();

          stream.on('finish', () => {
            // Verify the file was actually created
            if (fs.existsSync(filePath)) {
              const stats = fs.statSync(filePath);
              logger.info(`Daily invoice generated: ${fileName} (${stats.size} bytes)`);
              resolve(filePath);
            } else {
              logger.error(`PDF file was not created at: ${filePath}`);
              reject(new Error('PDF file was not created'));
            }
          });
        } catch (innerError) {
          logger.error('Error inside PDF generation promise:', innerError.message);
          reject(innerError);
        }
      });
    } catch (error) {
      logger.error('Error in generateDailyInvoice:', error.message, error.stack);
      throw error;
    }
  }

  async generateMonthlyInvoice(invoiceData) {
    try {
      // Ensure directory exists before generating
      this.ensureDirectoryExists();

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

      if (!invoiceNumber || !customer) {
        throw new Error('Missing required invoice data: invoiceNumber or customer');
      }

      const sanitizedInvoiceNum = this.sanitizeFileName(invoiceNumber);
      const fileName = `monthly_${sanitizedInvoiceNum}_${Date.now()}.pdf`;
      const filePath = path.join(this.invoicesDir, fileName);

      logger.info(`Generating monthly invoice PDF: ${fileName}`);

      return new Promise((resolve, reject) => {
        try {
          const doc = new PDFDocument({ margin: 50, size: 'A4' });
          const stream = fs.createWriteStream(filePath);

          stream.on('error', (error) => {
            logger.error('Stream error generating monthly invoice:', error.message);
            reject(error);
          });

          doc.on('error', (error) => {
            logger.error('PDFDocument error:', error.message);
            reject(error);
          });

          doc.pipe(stream);

          this.addHeader(doc, 'Monthly Invoice');

          doc.fontSize(12)
             .font('Helvetica')
             .text(`Invoice Number: ${invoiceNumber}`, 50, 150)
             .text(`Customer Name: ${customer.name || 'N/A'}`, 50, 170)
             .text(`Phone: ${customer.phone || 'N/A'}`, 50, 190)
             .text(`Address: ${customer.address || 'N/A'}`, 50, 210)
             .text(`Period: ${periodStart || 'N/A'} to ${periodEnd || 'N/A'}`, 50, 230);

          doc.moveDown(2);

          const safeDeliveries = Array.isArray(deliveries) ? deliveries : [];
          const tableTop = 280;

          if (safeDeliveries.length > 0) {
            this.generateMonthlyDeliveryTable(doc, safeDeliveries, tableTop);
          } else {
            doc.fontSize(11)
               .font('Helvetica')
               .text('No delivery details available.', 50, tableTop);
          }

          const summaryY = tableTop + (safeDeliveries.length + 2) * 25 + 30;
          const safeTotalAmount = parseFloat(totalAmount || 0);
          const safePaidAmount = parseFloat(paidAmount || 0);

          doc.fontSize(12)
             .font('Helvetica-Bold')
             .text(`Total Amount: ${RUPEE} ${safeTotalAmount.toFixed(2)}`, 350, summaryY)
             .text(`Paid Amount: ${RUPEE} ${safePaidAmount.toFixed(2)}`, 350, summaryY + 20)
             .text(`Balance Due: ${RUPEE} ${(safeTotalAmount - safePaidAmount).toFixed(2)}`, 350, summaryY + 40)
             .text(`Status: ${(paymentStatus || 'pending').toUpperCase()}`, 350, summaryY + 60);

          this.addFooter(doc);

          doc.end();

          stream.on('finish', () => {
            if (fs.existsSync(filePath)) {
              const stats = fs.statSync(filePath);
              logger.info(`Monthly invoice generated: ${fileName} (${stats.size} bytes)`);
              resolve(filePath);
            } else {
              logger.error(`PDF file was not created at: ${filePath}`);
              reject(new Error('PDF file was not created'));
            }
          });
        } catch (innerError) {
          logger.error('Error inside monthly PDF generation promise:', innerError.message);
          reject(innerError);
        }
      });
    } catch (error) {
      logger.error('Error in generateMonthlyInvoice:', error.message, error.stack);
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
       .text(`Generated on: ${new Date().toLocaleString('en-IN')}`, 350, bottomY + 10);
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
    const safeDeliveries = Array.isArray(deliveries) ? deliveries : [];
    safeDeliveries.forEach((delivery, index) => {
      const y = startY + 25 + (index * 25);
      
      // Prevent going past footer area - add new page if needed
      if (y > 720) {
        doc.addPage();
        return;
      }

      doc.text(String(delivery.customerName || 'N/A'), startX, y, { width: 140 });
      doc.text(String(delivery.productName || 'N/A'), startX + 150, y, { width: 140 });
      doc.text(`${delivery.quantity || 0} ${delivery.unit || ''}`, startX + 300, y);
      doc.text(`${RUPEE} ${parseFloat(delivery.amount || 0).toFixed(2)}`, startX + 400, y);
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
    const safeDeliveries = Array.isArray(deliveries) ? deliveries : [];
    safeDeliveries.forEach((delivery, index) => {
      const y = startY + 25 + (index * 25);
      
      if (y > 720) {
        doc.addPage();
        return;
      }

      doc.text(String(delivery.date || 'N/A'), startX, y);
      doc.text(String(delivery.productName || 'N/A'), startX + 100, y, { width: 190 });
      doc.text(`${delivery.quantity || 0} ${delivery.unit || ''}`, startX + 300, y);
      doc.text(`${RUPEE} ${parseFloat(delivery.amount || 0).toFixed(2)}`, startX + 400, y);
    });
  }
}

module.exports = new PDFService();
