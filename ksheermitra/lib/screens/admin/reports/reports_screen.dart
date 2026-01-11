import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../providers/dashboard_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _isLoading = false;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _dateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Reports'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateRangeSelector(),
            const SizedBox(height: 24),
            const Text(
              'Available Reports',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildReportCard(
              'Sales Summary Report',
              'Complete summary of all sales including in-store and delivery sales',
              Icons.receipt_long,
              Colors.blue,
              () => _generateSalesSummaryReport(),
            ),
            const SizedBox(height: 12),
            _buildReportCard(
              'Customer Report',
              'List of all customers with their subscription status',
              Icons.people,
              Colors.green,
              () => _generateCustomerReport(),
            ),
            const SizedBox(height: 12),
            _buildReportCard(
              'Delivery Report',
              'Detailed delivery performance and statistics',
              Icons.local_shipping,
              Colors.orange,
              () => _generateDeliveryReport(),
            ),
            const SizedBox(height: 12),
            _buildReportCard(
              'Product Inventory Report',
              'Current stock levels and product details',
              Icons.inventory,
              Colors.purple,
              () => _generateInventoryReport(),
            ),
            const SizedBox(height: 12),
            _buildReportCard(
              'Revenue Report',
              'Revenue breakdown by category and time period',
              Icons.currency_rupee,
              Colors.teal,
              () => _generateRevenueReport(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.date_range),
        title: const Text('Report Date Range'),
        subtitle: Text(
          _dateRange != null
              ? '${DateFormat('MMM d, yyyy').format(_dateRange!.start)} - ${DateFormat('MMM d, yyyy').format(_dateRange!.end)}'
              : 'Select date range',
        ),
        trailing: const Icon(Icons.edit),
        onTap: _selectDateRange,
      ),
    );
  }

  Widget _buildReportCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onGenerate,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _previewReport(title, onGenerate),
                  icon: const Icon(Icons.preview, size: 18),
                  label: const Text('Preview'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : onGenerate,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download, size: 18),
                  label: const Text('Export PDF'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _previewReport(String title, VoidCallback onGenerate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Preview: $title'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: FutureBuilder<pw.Document>(
            future: _buildPdfDocument(title),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              return PdfPreview(
                build: (format) async => snapshot.data!.save(),
                canChangeOrientation: false,
                canChangePageFormat: false,
                allowPrinting: true,
                allowSharing: true,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<pw.Document> _buildPdfDocument(String title) async {
    final pdf = pw.Document();
    final dashboardProvider = context.read<DashboardProvider>();
    final stats = dashboardProvider.stats;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Ksheer Mitra',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              title,
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Generated: ${DateFormat('MMM d, yyyy HH:mm').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10),
            ),
            if (_dateRange != null) ...[
              pw.Text(
                'Period: ${DateFormat('MMM d, yyyy').format(_dateRange!.start)} - ${DateFormat('MMM d, yyyy').format(_dateRange!.end)}',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
            pw.Divider(),
          ],
        ),
        build: (context) => [
          pw.SizedBox(height: 20),
          pw.Text('Summary', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          if (stats != null) ...[
            _buildPdfRow('Total Customers', stats.totalCustomers.toString()),
            _buildPdfRow('Active Customers', stats.activeCustomers.toString()),
            _buildPdfRow('Total Delivery Boys', stats.totalDeliveryBoys.toString()),
            _buildPdfRow('Active Subscriptions', stats.activeSubscriptions.toString()),
            _buildPdfRow('Today\'s Deliveries', stats.todaysDeliveries.toString()),
            _buildPdfRow('Today\'s Revenue', '₹${stats.todaysRevenue.toStringAsFixed(2)}'),
            _buildPdfRow('Collected Payments', '₹${stats.collectedPayments.toStringAsFixed(2)}'),
            _buildPdfRow('Pending Payments', '₹${stats.pendingPayments.toStringAsFixed(2)}'),
          ],
          pw.SizedBox(height: 20),
          pw.Text('Note: This is a summary report. For detailed reports, please contact administrator.',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
      ),
    );

    return pdf;
  }

  pw.Widget _buildPdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _generateSalesSummaryReport() async {
    await _exportReport('Sales Summary Report');
  }

  Future<void> _generateCustomerReport() async {
    await _exportReport('Customer Report');
  }

  Future<void> _generateDeliveryReport() async {
    await _exportReport('Delivery Report');
  }

  Future<void> _generateInventoryReport() async {
    await _exportReport('Product Inventory Report');
  }

  Future<void> _generateRevenueReport() async {
    await _exportReport('Revenue Report');
  }

  Future<void> _exportReport(String title) async {
    setState(() => _isLoading = true);

    try {
      final pdf = await _buildPdfDocument(title);

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: '${title.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title generated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

