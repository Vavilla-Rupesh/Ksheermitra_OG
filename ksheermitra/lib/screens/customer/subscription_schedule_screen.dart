import 'package:flutter/material.dart';
import '../../config/dairy_theme.dart';
import 'package:intl/intl.dart';
import '../../models/product.dart';
import 'subscription_review_screen.dart';

class SubscriptionScheduleScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedProducts;

  const SubscriptionScheduleScreen({
    super.key,
    required this.selectedProducts,
  });

  @override
  State<SubscriptionScheduleScreen> createState() => _SubscriptionScheduleScreenState();
}

class _SubscriptionScheduleScreenState extends State<SubscriptionScheduleScreen> {
  String _selectedType = 'daily';
  Set<int> _selectedDays = {};
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _startDateForRange;
  bool _autoRenewal = false;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now().add(const Duration(days: 1));
  }

  double get _totalPerDelivery {
    return widget.selectedProducts.fold(0.0, (sum, item) {
      final product = item['product'] as Product;
      final quantity = (item['quantity'] as num).toDouble();
      return sum + (product.pricePerUnit * quantity);
    });
  }

  double get _estimatedMonthlyCost {
    switch (_selectedType) {
      case 'daily':
        return _totalPerDelivery * 30;
      case 'specificDays':
        if (_selectedDays.isEmpty) return 0;
        return _totalPerDelivery * (_selectedDays.length * 4.3);
      case 'dateRange':
        if (_startDateForRange == null || _endDate == null) return 0;
        final days = _endDate!.difference(_startDateForRange!).inDays + 1;
        return _totalPerDelivery * days;
      case 'monthly':
        return _totalPerDelivery * 30;
      default:
        return 0;
    }
  }

  bool get _canContinue {
    if (_startDate == null) return false;

    switch (_selectedType) {
      case 'specificDays':
        return _selectedDays.isNotEmpty;
      case 'dateRange':
        return _startDateForRange != null &&
               _endDate != null &&
               _endDate!.isAfter(_startDateForRange!);
      default:
        return true;
    }
  }

  void _continueToReview() {
    if (!_canContinue) {
      String message = 'Please complete the schedule configuration';
      if (_selectedType == 'specificDays' && _selectedDays.isEmpty) {
        message = 'Please select at least one day';
      } else if (_selectedType == 'dateRange') {
        if (_startDateForRange == null || _endDate == null) {
          message = 'Please select both start and end dates';
        } else if (!_endDate!.isAfter(_startDateForRange!)) {
          message = 'End date must be after start date';
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }

    final scheduleData = <String, dynamic>{
      'type': _selectedType,
      'startDate': _startDate,
      'autoRenewal': _autoRenewal,
    };

    // Only add selectedDays if the type is specificDays and days are selected
    if (_selectedType == 'specificDays' && _selectedDays.isNotEmpty) {
      scheduleData['selectedDays'] = _selectedDays.toList();
    }

    // Only add endDate if the type is dateRange and endDate is set
    if (_selectedType == 'dateRange' && _endDate != null) {
      scheduleData['endDate'] = _endDate;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionReviewScreen(
          selectedProducts: widget.selectedProducts,
          scheduleData: scheduleData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Delivery Schedule'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected Products Summary
            _buildProductsSummary(),

            const Divider(thickness: 8, height: 8),

            // Subscription Type Options
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Schedule Type',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  _buildScheduleOption(
                    'daily',
                    'Daily Delivery',
                    'Get delivery every day',
                    Icons.calendar_today,
                  ),

                  _buildScheduleOption(
                    'specificDays',
                    'Select Days',
                    'Choose specific days of the week',
                    Icons.calendar_month,
                  ),

                  if (_selectedType == 'specificDays')
                    _buildDaySelector(),

                  _buildScheduleOption(
                    'dateRange',
                    'Date Range',
                    'Daily delivery for specific period',
                    Icons.date_range,
                  ),

                  if (_selectedType == 'dateRange')
                    _buildDateRangeSelector(),

                  _buildScheduleOption(
                    'monthly',
                    'Monthly',
                    '30 days daily delivery',
                    Icons.calendar_view_month,
                  ),

                  if (_selectedType == 'monthly')
                    _buildAutoRenewalToggle(),
                ],
              ),
            ),

            const Divider(thickness: 8, height: 8),

            // Start Date Picker
            _buildStartDatePicker(),

            const Divider(thickness: 8, height: 8),

            // Cost Summary
            _buildCostSummary(),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _canContinue ? _continueToReview : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductsSummary() {
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
                  'Selected Products',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...widget.selectedProducts.map((item) {
              final product = item['product'] as Product;
              final quantity = (item['quantity'] as num).toDouble();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.local_drink,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${quantity.toInt()} ${product.unit}',
                            style: TextStyle(
                              fontSize: 12,
                              color: DairyColorsLight.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${(product.pricePerUnit * quantity).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleOption(String value, String title, String description, IconData icon) {
    final isSelected = _selectedType == value;
    return Card(
      elevation: isSelected ? 3 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DairyRadius.md),
        side: isSelected
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: _selectedType,
        onChanged: (val) => setState(() => _selectedType = val!),
        title: Row(
          children: [
            Icon(icon, color: isSelected ? Theme.of(context).primaryColor : Colors.grey),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Theme.of(context).primaryColor : Colors.black,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 40),
          child: Text(description),
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Container(
      margin: const EdgeInsets.only(left: 16, bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DairyColorsLight.surface,
        borderRadius: BorderRadius.circular(DairyRadius.md),
        border: Border.all(color: DairyColorsLight.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Days:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(7, (index) {
              final dayIndex = (index + 1) % 7; // Convert to Sunday=0 format
              final isSelected = _selectedDays.contains(dayIndex);
              return FilterChip(
                label: Text(dayNames[index]),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedDays.add(dayIndex);
                    } else {
                      _selectedDays.remove(dayIndex);
                    }
                  });
                },
                selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                checkmarkColor: Theme.of(context).primaryColor,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Container(
      margin: const EdgeInsets.only(left: 16, bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DairyColorsLight.surface,
        borderRadius: BorderRadius.circular(DairyRadius.md),
        border: Border.all(color: DairyColorsLight.border),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Start Date'),
            subtitle: Text(
              _startDateForRange != null
                  ? DateFormat('dd MMM yyyy, EEEE').format(_startDateForRange!)
                  : 'Select start date',
            ),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now().add(const Duration(days: 1)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() => _startDateForRange = date);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('End Date'),
            subtitle: Text(
              _endDate != null
                  ? DateFormat('dd MMM yyyy, EEEE').format(_endDate!)
                  : 'Select end date',
            ),
            onTap: () async {
              final minDate = _startDateForRange?.add(const Duration(days: 1)) ??
                  DateTime.now().add(const Duration(days: 2));
              final date = await showDatePicker(
                context: context,
                initialDate: minDate,
                firstDate: minDate,
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() => _endDate = date);
              }
            },
            enabled: _startDateForRange != null,
          ),
        ],
      ),
    );
  }

  Widget _buildAutoRenewalToggle() {
    return Container(
      margin: const EdgeInsets.only(left: 16, bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: DairyColorsLight.surface,
        borderRadius: BorderRadius.circular(DairyRadius.md),
        border: Border.all(color: DairyColorsLight.border),
      ),
      child: SwitchListTile(
        value: _autoRenewal,
        onChanged: (value) => setState(() => _autoRenewal = value),
        title: const Text('Auto-renewal'),
        subtitle: const Text('Automatically renew after 30 days'),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildStartDatePicker() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Start From',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
              title: const Text('Start Date'),
              subtitle: Text(
                _startDate != null
                    ? DateFormat('dd MMM yyyy, EEEE').format(_startDate!)
                    : 'Select start date',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now().add(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (date != null) {
                  setState(() => _startDate = date);
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Deliveries will start from tomorrow onwards',
                    style: TextStyle(fontSize: 13, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.green.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cost Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
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
              const Text(
                'Estimated monthly cost:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '₹${_estimatedMonthlyCost.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
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
}
