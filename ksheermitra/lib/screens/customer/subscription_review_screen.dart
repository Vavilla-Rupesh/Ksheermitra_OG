import 'package:flutter/material.dart';
import '../../config/dairy_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/subscription_provider.dart';
import '../../services/customer_api_service.dart';

class SubscriptionReviewScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedProducts;
  final Map<String, dynamic> scheduleData;

  const SubscriptionReviewScreen({
    super.key,
    required this.selectedProducts,
    required this.scheduleData,
  });

  @override
  State<SubscriptionReviewScreen> createState() => _SubscriptionReviewScreenState();
}

class _SubscriptionReviewScreenState extends State<SubscriptionReviewScreen> {
  final CustomerApiService _apiService = CustomerApiService();
  bool _termsAccepted = false;
  bool _isCreating = false;

  double get _totalPerDelivery {
    return widget.selectedProducts.fold(0.0, (sum, item) {
      final product = item['product'] as Product;
      final quantity = item['quantity'] as int; // Changed to int
      return sum + (product.pricePerUnit * quantity);
    });
  }

  int get _deliveriesPerMonth {
    final type = widget.scheduleData['type'];
    switch (type) {
      case 'daily':
        return 30;
      case 'specificDays':
        final selectedDays = widget.scheduleData['selectedDays'] as List<int>;
        return (selectedDays.length * 4.3).round();
      case 'dateRange':
        final startDate = widget.scheduleData['startDate'] as DateTime;
        final endDate = widget.scheduleData['endDate'] as DateTime;
        final days = endDate.difference(startDate).inDays + 1;
        return days > 30 ? 30 : days;
      case 'monthly':
        return 30;
      default:
        return 0;
    }
  }

  double get _estimatedMonthlyCost {
    return _totalPerDelivery * _deliveriesPerMonth;
  }

  String get _scheduleDisplay {
    final type = widget.scheduleData['type'];
    switch (type) {
      case 'daily':
        return 'Daily';
      case 'specificDays':
        final selectedDays = widget.scheduleData['selectedDays'] as List<int>;
        final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        return selectedDays.map((d) => dayNames[d]).join(', ');
      case 'dateRange':
        final startDate = widget.scheduleData['startDate'] as DateTime;
        final endDate = widget.scheduleData['endDate'] as DateTime;
        return '${DateFormat('dd/MM/yyyy').format(startDate)} - ${DateFormat('dd/MM/yyyy').format(endDate)}';
      case 'monthly':
        return 'Monthly (30 days)';
      default:
        return '';
    }
  }

  Future<void> _confirmSubscription() async {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept terms and conditions')),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final startDate = widget.scheduleData['startDate'] as DateTime;
      final type = widget.scheduleData['type'];

      // Convert type to API format
      String frequency = 'daily';
      if (type == 'specificDays') {
        frequency = 'custom';
      } else if (type == 'dateRange') {
        frequency = 'daterange';
      } else if (type == 'monthly') {
        frequency = 'monthly';
      }

      final subscriptionData = {
        'products': widget.selectedProducts.map((item) {
          final product = item['product'] as Product;
          final quantity = item['quantity'] as int; // Changed to int
          return {
            'productId': product.id,
            'quantity': quantity,
          };
        }).toList(),
        'frequency': frequency,
        'startDate': DateFormat('yyyy-MM-dd').format(startDate),
        'autoRenewal': widget.scheduleData['autoRenewal'] ?? false,
      };

      // Add optional fields only if they have values
      if (type == 'specificDays' && widget.scheduleData['selectedDays'] != null) {
        subscriptionData['selectedDays'] = widget.scheduleData['selectedDays'];
      }

      if (type == 'dateRange' && widget.scheduleData['endDate'] != null) {
        subscriptionData['endDate'] = DateFormat('yyyy-MM-dd').format(widget.scheduleData['endDate']);
      }

      // Log the data being sent for debugging
      debugPrint('📦 Subscription data: $subscriptionData');

      final response = await _apiService.createSubscription(subscriptionData);

      if (response['success'] == true) {
        // Reload subscriptions
        if (mounted) {
          await Provider.of<SubscriptionProvider>(context, listen: false).loadSubscriptions();
        }

        if (mounted) {
          // Show success dialog
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Subscription Created!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your subscription has been created successfully.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: DairyColorsLight.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.of(context).popUntil((route) => route.isFirst); // Go to home
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
          );
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to create subscription');
      }
    } catch (e) {
      setState(() => _isCreating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Subscription'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Products Section
            _buildProductsSection(),

            const Divider(thickness: 8, height: 8),

            // Schedule Section
            _buildScheduleSection(),

            const Divider(thickness: 8, height: 8),

            // Cost Summary
            _buildCostSummary(),

            const Divider(thickness: 8, height: 8),

            // Terms and Conditions
            _buildTermsSection(),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: _isCreating ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: DairyColorsLight.textDisabled),
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isCreating || !_termsAccepted ? null : _confirmSubscription,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isCreating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Confirm Subscription',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Products',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
              ],
            ),
            const Divider(),
            ...widget.selectedProducts.map((item) {
              final product = item['product'] as Product;
              final quantity = item['quantity'] as int; // Changed to int
              final price = product.pricePerUnit * quantity;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.local_drink,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            '$quantity ${product.unit} × ₹${product.pricePerUnit.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: DairyColorsLight.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total per delivery:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹${_totalPerDelivery.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSection() {
    final startDate = widget.scheduleData['startDate'] as DateTime;
    final type = widget.scheduleData['type'];
    final autoRenewal = widget.scheduleData['autoRenewal'] ?? false;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Delivery Schedule',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
              ],
            ),
            const Divider(),
            _buildScheduleRow(Icons.calendar_today, 'Schedule Type', _scheduleDisplay),
            const SizedBox(height: 12),
            _buildScheduleRow(
              Icons.event,
              'Start Date',
              DateFormat('dd MMM yyyy, EEEE').format(startDate),
            ),
            if (type == 'dateRange' && widget.scheduleData['endDate'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _buildScheduleRow(
                  Icons.event_available,
                  'End Date',
                  DateFormat('dd MMM yyyy, EEEE').format(widget.scheduleData['endDate']),
                ),
              ),
            if (type == 'monthly' && autoRenewal)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _buildScheduleRow(
                  Icons.autorenew,
                  'Auto-renewal',
                  'Enabled',
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: DairyColorsLight.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCostSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade50,
            Colors.green.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(DairyRadius.md),
      ),
      child: Column(
        children: [
          const Text(
            'Cost Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Per delivery:', style: TextStyle(fontSize: 14)),
              Text(
                '₹${_totalPerDelivery.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Deliveries per month:', style: TextStyle(fontSize: 14)),
              Text(
                '$_deliveriesPerMonth times',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estimated monthly cost:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '₹${_estimatedMonthlyCost.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: CheckboxListTile(
        value: _termsAccepted,
        onChanged: (value) => setState(() => _termsAccepted = value ?? false),
        title: RichText(
          text: TextSpan(
            style: TextStyle(color: DairyColorsLight.textPrimary, fontSize: 14),
            children: [
              const TextSpan(text: 'I agree to the '),
              TextSpan(
                text: 'terms and conditions',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
