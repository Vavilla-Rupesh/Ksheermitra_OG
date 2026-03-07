import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/invoice.dart';
import '../../services/customer_api_service.dart';
import '../../config/dairy_theme.dart';
import '../../widgets/premium_widgets.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final CustomerApiService _apiService = CustomerApiService();
  List<Invoice> _invoices = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() => _isLoading = true);
    try {
      final invoices = await _apiService.getInvoices();
      setState(() {
        _invoices = invoices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading invoices: $e')),
        );
      }
    }
  }

  List<Invoice> get _filteredInvoices {
    if (_selectedFilter == 'all') return _invoices;
    return _invoices.where((invoice) => invoice.paymentStatus == _selectedFilter).toList();
  }

  double get _totalAmount {
    return _filteredInvoices.fold(0, (sum, invoice) => sum + invoice.totalAmount);
  }

  double get _paidAmount {
    return _filteredInvoices
        .where((invoice) => invoice.paymentStatus == 'paid')
        .fold(0, (sum, invoice) => sum + invoice.paidAmount);
  }

  double get _pendingAmount {
    return _filteredInvoices
        .where((invoice) => invoice.paymentStatus == 'pending')
        .fold(0, (sum, invoice) => sum + invoice.totalAmount);
  }

  Future<void> _downloadInvoicePdf(Invoice invoice) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(DairySpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: DairySpacing.md),
                Text('Downloading invoice...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Simulate download delay
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        // Show success message with share option
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Invoice downloaded successfully!'),
            backgroundColor: DairyColorsLight.success,
            action: SnackBarAction(
              label: 'Share',
              textColor: Colors.white,
              onPressed: () {
                // Share functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening share options...')),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading invoice: $e'),
            backgroundColor: DairyColorsLight.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PremiumAppBar(
        title: 'Billing & Invoices',
      ),
      body: Column(
        children: [
          // Premium Summary Cards
          _buildSummarySection(),

          // Filter Chips
          _buildFilterSection(),

          // Invoice List
          Expanded(
            child: _isLoading
                ? const PremiumLoadingWidget(message: 'Loading invoices...')
                : _filteredInvoices.isEmpty
                    ? PremiumEmptyState(
                        icon: Icons.receipt_long,
                        title: 'No Invoices Found',
                        message: _selectedFilter == 'all'
                            ? 'You don\'t have any invoices yet'
                            : 'No $_selectedFilter invoices found',
                      )
                    : RefreshIndicator(
                        onRefresh: _loadInvoices,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(AppTheme.space16),
                          itemCount: _filteredInvoices.length,
                          itemBuilder: (context, index) {
                            final invoice = _filteredInvoices[index];
                            return _buildInvoiceCard(invoice);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        gradient: AppTheme.dashboardHeaderGradient,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total',
                  _totalAmount,
                  AppTheme.infoBlue,
                  Icons.account_balance_wallet,
                ),
              ),
              const SizedBox(width: AppTheme.space12),
              Expanded(
                child: _buildSummaryCard(
                  'Paid',
                  _paidAmount,
                  AppTheme.successGreen,
                  Icons.check_circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space12),
          _buildSummaryCard(
            'Pending',
            _pendingAmount,
            AppTheme.warningOrange,
            Icons.pending,
            isWide: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, double amount, Color color, IconData icon, {bool isWide = false}) {
    return PremiumCard(
      padding: const EdgeInsets.all(AppTheme.space16),
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.space8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              if (isWide) ...[
                const SizedBox(width: AppTheme.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: AppTheme.bodySmall),
                      Row(
                        children: [
                          Icon(Icons.currency_rupee, size: 18, color: color),
                          Text(
                            amount.toStringAsFixed(2),
                            style: AppTheme.h4.copyWith(color: color),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (!isWide) ...[
            const SizedBox(height: AppTheme.space8),
            Text(label, style: AppTheme.bodySmall),
            const SizedBox(height: AppTheme.space4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.currency_rupee, size: 16, color: color),
                Text(
                  amount.toStringAsFixed(2),
                  style: AppTheme.h5.copyWith(color: color),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space16,
        vertical: AppTheme.space12,
      ),
      child: Row(
        children: [
          Text('Filter: ', style: AppTheme.labelText),
          const SizedBox(width: AppTheme.space8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'All'),
                  _buildFilterChip('paid', 'Paid'),
                  _buildFilterChip('pending', 'Pending'),
                  _buildFilterChip('overdue', 'Overdue'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.space8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedFilter = value);
        },
        selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
        checkmarkColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    final isPaid = invoice.paymentStatus.toLowerCase() == 'paid';
    final isPending = invoice.paymentStatus.toLowerCase() == 'pending';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.space12),
      child: PremiumCard(
        onTap: () => _showInvoiceDetails(invoice),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.space12),
                  decoration: BoxDecoration(
                    gradient: isPaid
                        ? AppTheme.deliveredGradient
                        : isPending
                            ? AppTheme.pendingGradient
                            : LinearGradient(
                                colors: [AppTheme.errorRed, AppTheme.errorRed.withValues(alpha: 0.7)],
                              ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppTheme.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invoice #${invoice.invoiceNumber}',
                        style: AppTheme.h5,
                      ),
                      const SizedBox(height: AppTheme.space4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(invoice.invoiceDate),
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.space12,
                    vertical: AppTheme.space4,
                  ),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? AppTheme.successGreen.withValues(alpha: 0.1)
                        : isPending
                            ? AppTheme.warningOrange.withValues(alpha: 0.1)
                            : AppTheme.errorRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  ),
                  child: Text(
                    isPaid ? 'PAID' : isPending ? 'PENDING' : 'OVERDUE',
                    style: AppTheme.labelText.copyWith(
                      color: isPaid
                          ? AppTheme.successGreen
                          : isPending
                              ? AppTheme.warningOrange
                              : AppTheme.errorRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: AppTheme.space24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Amount', style: AppTheme.bodySmall),
                    const SizedBox(height: AppTheme.space4),
                    Row(
                      children: [
                        const Icon(Icons.currency_rupee, size: 16),
                        Text(
                          invoice.totalAmount.toStringAsFixed(2),
                          style: AppTheme.h5,
                        ),
                      ],
                    ),
                  ],
                ),
                if (!isPaid) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Remaining', style: AppTheme.bodySmall),
                      const SizedBox(height: AppTheme.space4),
                      Row(
                        children: [
                          const Icon(Icons.currency_rupee, size: 16, color: AppTheme.errorRed),
                          Text(
                            invoice.remainingAmount.toStringAsFixed(2),
                            style: AppTheme.h5.copyWith(color: AppTheme.errorRed),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showInvoiceDetails(Invoice invoice) {
    final deliveries = invoice.deliveryDetails?['deliveries'] as List?;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppTheme.space16),
                decoration: BoxDecoration(
                  gradient: AppTheme.dashboardHeaderGradient,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusMedium),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long, color: Colors.white),
                    const SizedBox(width: AppTheme.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invoice Details',
                            style: DairyTypography.headingSmall(color: Colors.white),
                          ),
                          const SizedBox(height: DairySpacing.xs),
                          Text(
                            '#${invoice.invoiceNumber}',
                            style: DairyTypography.bodySmall(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTheme.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Invoice Info
                      _buildDetailRow('Invoice Date', DateFormat('dd MMM yyyy').format(invoice.invoiceDate)),
                      _buildDetailRow('Period',
                        '${DateFormat('dd MMM').format(invoice.periodStart)} - ${DateFormat('dd MMM yyyy').format(invoice.periodEnd)}'),
                      _buildDetailRow('Type', invoice.type.toUpperCase()),
                      const Divider(height: AppTheme.space24),

                      // Amount Summary
                      PremiumCard(
                        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                        child: Column(
                          children: [
                            _buildAmountRow('Total Amount', invoice.totalAmount, AppTheme.textPrimary),
                            const SizedBox(height: AppTheme.space8),
                            _buildAmountRow('Paid Amount', invoice.paidAmount, AppTheme.successGreen),
                            const Divider(height: AppTheme.space16),
                            _buildAmountRow('Remaining', invoice.remainingAmount, AppTheme.errorRed, isBold: true),
                          ],
                        ),
                      ),

                      // Daily Delivery Breakdown
                      if (deliveries != null && deliveries.isNotEmpty) ...[
                        const SizedBox(height: AppTheme.space24),
                        Text(
                          'Delivery Breakdown',
                          style: AppTheme.h4,
                        ),
                        const SizedBox(height: AppTheme.space12),
                        ...deliveries.map((delivery) {
                          final date = delivery['date'] ?? '';
                          final productName = delivery['productName'] ?? '';
                          final quantity = delivery['quantity']?.toString() ?? '0';
                          final unit = delivery['unit'] ?? '';
                          final amount = double.tryParse(delivery['amount']?.toString() ?? '0') ?? 0.0;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppTheme.space8),
                            child: PremiumCard(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(AppTheme.space8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.infoBlue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                    ),
                                    child: const Icon(
                                      Icons.local_shipping,
                                      color: AppTheme.infoBlue,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.space12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          date,
                                          style: AppTheme.bodySmall.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '$productName - $quantity $unit',
                                          style: AppTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.currency_rupee, size: 14),
                                      Text(
                                        amount.toStringAsFixed(2),
                                        style: AppTheme.h5,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],

                      // Status and Notes
                      const SizedBox(height: AppTheme.space16),
                      Row(
                        children: [
                          Text('Status: ', style: AppTheme.bodyMedium),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.space12,
                              vertical: AppTheme.space4,
                            ),
                            decoration: BoxDecoration(
                              color: invoice.isPaid
                                  ? AppTheme.successGreen.withValues(alpha: 0.1)
                                  : AppTheme.warningOrange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                            ),
                            child: Text(
                              invoice.paymentStatus.toUpperCase(),
                              style: TextStyle(
                                color: invoice.isPaid ? AppTheme.successGreen : AppTheme.warningOrange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
                        const SizedBox(height: AppTheme.space16),
                        Text('Notes:', style: AppTheme.h5),
                        const SizedBox(height: AppTheme.space8),
                        PremiumCard(
                          backgroundColor: DairyColorsLight.surface,
                          child: Text(invoice.notes!, style: DairyTypography.body()),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Footer Actions
              Container(
                padding: const EdgeInsets.all(AppTheme.space16),
                decoration: BoxDecoration(
                  color: DairyColorsLight.surface,
                  border: Border(
                    top: BorderSide(color: DairyColorsLight.border),
                  ),
                ),
                child: Row(
                  children: [
                    if (invoice.pdfPath != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            // Download PDF
                            Navigator.pop(context);
                            _downloadInvoicePdf(invoice);
                          },
                          icon: const Icon(Icons.download),
                          label: const Text('Download PDF'),
                        ),
                      ),
                    if (invoice.pdfPath != null) const SizedBox(width: AppTheme.space12),
                    Expanded(
                      child: PremiumButton(
                        text: 'Close',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Row(
          children: [
            Icon(Icons.currency_rupee, size: 16, color: color),
            Text(
              amount.toStringAsFixed(2),
              style: TextStyle(
                fontSize: isBold ? 18 : 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DairySpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: DairyTypography.body()),
          Text(value, style: DairyTypography.bodyLarge()),
        ],
      ),
    );
  }
}
