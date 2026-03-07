import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/dairy_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/premium_widgets.dart';

class InvoiceGenerationScreen extends StatefulWidget {
  const InvoiceGenerationScreen({super.key});

  @override
  State<InvoiceGenerationScreen> createState() => _InvoiceGenerationScreenState();
}

class _InvoiceGenerationScreenState extends State<InvoiceGenerationScreen> {
  bool _isLoading = true;
  bool _isGenerating = false;
  DateTime _selectedDate = DateTime.now();
  List<DeliveryInvoiceItem> _deliveries = [];
  double _totalAmount = 0;
  double _totalCollected = 0;

  @override
  void initState() {
    super.initState();
    _loadDeliveryData();
  }

  Future<void> _loadDeliveryData() async {
    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final response = await apiService.get(
        '/delivery-boy/daily-summary',
        queryParams: {
          'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        _deliveries = (data['deliveries'] as List<dynamic>?)
            ?.map((d) => DeliveryInvoiceItem.fromJson(d))
            .toList() ?? [];
        _calculateTotals();
      } else {
        // Show error if no data from API
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'No deliveries found for this date'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        _deliveries = [];
        _calculateTotals();
      }
    } catch (e) {
      // Show actual error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading deliveries: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _deliveries = [];
      _calculateTotals();
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _calculateTotals() {
    _totalAmount = _deliveries.fold(0, (sum, d) => sum + d.amount);
    _totalCollected = _deliveries.fold(0, (sum, d) => sum + d.collected);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadDeliveryData();
    }
  }

  Future<void> _generateInvoice() async {
    if (_deliveries.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No deliveries to invoice for this date'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final apiService = ApiService();
      final response = await apiService.post(
        '/delivery-boy/generate-invoice',
        {
          'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        },
      );

      if (mounted) {
        if (response['success'] == true) {
          _showSuccessDialog(response['data']);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to generate invoice'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  void _showSuccessDialog(dynamic invoiceData) {
    final bool whatsappSent = invoiceData?['whatsappNotificationSent'] == true;
    final bool pdfGenerated = invoiceData?['pdfGenerated'] == true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 32),
            const SizedBox(width: 12),
            const Text('Invoice Generated!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '✅ Invoice generated successfully',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(pdfGenerated
                ? '📄 PDF invoice created'
                : '⚠️ PDF generation pending'),
            const SizedBox(height: 8),
            Text(whatsappSent
                ? '📱 Invoice & PDF sent to admin via WhatsApp'
                : '⚠️ WhatsApp notification could not be sent'),
            if (invoiceData != null && invoiceData['invoiceNumber'] != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice #${invoiceData['invoiceNumber']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Total: ₹${invoiceData['totalAmount']?.toStringAsFixed(2) ?? _totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(color: DairyColorsLight.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Great work today! Your deliveries have been recorded and invoice is ready.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              if (mounted) {
                Navigator.pop(context); // Close screen
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }


  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: DairyTypography.body()),
          Text(value, style: DairyTypography.bodyLarge().copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _shareInvoice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invoice shared successfully!'),
        backgroundColor: DairyColorsLight.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Invoice'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Date Selector & Summary
                Container(
                  padding: const EdgeInsets.all(DairySpacing.md),
                  color: DairyColorsLight.surface,
                  child: Column(
                    children: [
                      // Date Picker
                      InkWell(
                        onTap: _selectDate,
                        borderRadius: DairyRadius.defaultBorderRadius,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DairySpacing.md,
                            vertical: DairySpacing.sm + 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: DairyRadius.defaultBorderRadius,
                            border: Border.all(color: DairyColorsLight.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.calendar_today, size: 20),
                              const SizedBox(width: DairySpacing.sm),
                              Text(
                                DateFormat('EEEE, dd MMM yyyy').format(_selectedDate),
                                style: DairyTypography.bodyLarge(),
                              ),
                              const SizedBox(width: DairySpacing.sm),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: DairySpacing.md),

                      // Summary Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              'Deliveries',
                              '${_deliveries.length}',
                              Icons.local_shipping,
                              DairyColorsLight.primary,
                            ),
                          ),
                          const SizedBox(width: DairySpacing.sm),
                          Expanded(
                            child: _buildSummaryCard(
                              'Total',
                              '₹${_totalAmount.toStringAsFixed(0)}',
                              Icons.receipt,
                              DairyColorsLight.info,
                            ),
                          ),
                          const SizedBox(width: DairySpacing.sm),
                          Expanded(
                            child: _buildSummaryCard(
                              'Collected',
                              '₹${_totalCollected.toStringAsFixed(0)}',
                              Icons.payments,
                              DairyColorsLight.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Deliveries List
                Expanded(
                  child: _deliveries.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: DairyColorsLight.textTertiary,
                              ),
                              const SizedBox(height: DairySpacing.md),
                              Text(
                                'No deliveries found',
                                style: DairyTypography.headingSmall(),
                              ),
                              Text(
                                'Select a different date',
                                style: DairyTypography.body(color: DairyColorsLight.textSecondary),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(DairySpacing.md),
                          itemCount: _deliveries.length,
                          itemBuilder: (context, index) {
                            return _buildDeliveryCard(_deliveries[index], index);
                          },
                        ),
                ),

                // Generate Button
                if (_deliveries.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(DairySpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isGenerating ? null : _generateInvoice,
                          icon: _isGenerating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.receipt_long),
                          label: Text(_isGenerating ? 'Generating...' : 'Generate Daily Invoice'),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(DairySpacing.sm + 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DairyRadius.defaultBorderRadius,
        border: Border.all(color: DairyColorsLight.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: DairyTypography.headingSmall(),
          ),
          Text(
            label,
            style: DairyTypography.caption(color: DairyColorsLight.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(DeliveryInvoiceItem delivery, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: DairySpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(DairySpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: DairyColorsLight.primarySurface,
                    borderRadius: DairyRadius.smallBorderRadius,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: DairyTypography.label(color: DairyColorsLight.primary),
                    ),
                  ),
                ),
                const SizedBox(width: DairySpacing.sm + 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        delivery.customerName,
                        style: DairyTypography.bodyLarge().copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        delivery.time,
                        style: DairyTypography.caption(color: DairyColorsLight.textSecondary),
                      ),
                    ],
                  ),
                ),
                _buildPaymentBadge(delivery.paymentMode, delivery.collected > 0),
              ],
            ),

            const SizedBox(height: DairySpacing.sm),
            const Divider(),
            const SizedBox(height: DairySpacing.sm),

            // Products
            Text(
              delivery.products,
              style: DairyTypography.body(color: DairyColorsLight.textSecondary),
            ),

            const SizedBox(height: DairySpacing.sm),

            // Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Amount:', style: DairyTypography.label()),
                Text(
                  '₹${delivery.amount.toStringAsFixed(2)}',
                  style: DairyTypography.price(),
                ),
              ],
            ),
            if (delivery.collected > 0 && delivery.collected != delivery.amount)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Collected:', style: DairyTypography.label()),
                  Text(
                    '₹${delivery.collected.toStringAsFixed(2)}',
                    style: DairyTypography.body(color: DairyColorsLight.success),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentBadge(String mode, bool isPaid) {
    Color bgColor;
    Color textColor;
    String label;

    switch (mode.toLowerCase()) {
      case 'cash':
        bgColor = DairyColorsLight.successSurface;
        textColor = DairyColorsLight.success;
        label = 'Cash';
        break;
      case 'upi':
        bgColor = DairyColorsLight.infoSurface;
        textColor = DairyColorsLight.info;
        label = 'UPI';
        break;
      default:
        bgColor = DairyColorsLight.warningSurface;
        textColor = DairyColorsLight.warning;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: DairyRadius.pillBorderRadius,
      ),
      child: Text(
        label,
        style: DairyTypography.caption(color: textColor),
      ),
    );
  }
}

class DeliveryInvoiceItem {
  final String id;
  final String customerName;
  final String customerPhone;
  final String products;
  final double amount;
  final double collected;
  final String paymentMode;
  final String status;
  final String time;

  DeliveryInvoiceItem({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.products,
    required this.amount,
    required this.collected,
    required this.paymentMode,
    required this.status,
    required this.time,
  });

  factory DeliveryInvoiceItem.fromJson(Map<String, dynamic> json) {
    return DeliveryInvoiceItem(
      id: json['id']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      customerPhone: json['customerPhone']?.toString() ?? '',
      products: json['products']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      collected: double.tryParse(json['collected']?.toString() ?? '0') ?? 0,
      paymentMode: json['paymentMode']?.toString() ?? 'pending',
      status: json['status']?.toString() ?? 'completed',
      time: json['time']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerName': customerName,
    'customerPhone': customerPhone,
    'products': products,
    'amount': amount,
    'collected': collected,
    'paymentMode': paymentMode,
    'status': status,
    'time': time,
  };
}

