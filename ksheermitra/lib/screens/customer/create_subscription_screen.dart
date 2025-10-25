import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/product.dart';
import '../../services/customer_api_service.dart';

class CreateSubscriptionScreen extends StatefulWidget {
  final Product product;

  const CreateSubscriptionScreen({super.key, required this.product});

  @override
  State<CreateSubscriptionScreen> createState() => _CreateSubscriptionScreenState();
}

class _CreateSubscriptionScreenState extends State<CreateSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final CustomerApiService _apiService = CustomerApiService();

  double _quantity = 1.0;
  String _frequency = 'daily';
  List<int> _selectedDays = [];
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime? _endDate;
  bool _hasEndDate = false;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _weekDays = [
    {'value': 1, 'name': 'Mon'},
    {'value': 2, 'name': 'Tue'},
    {'value': 3, 'name': 'Wed'},
    {'value': 4, 'name': 'Thu'},
    {'value': 5, 'name': 'Fri'},
    {'value': 6, 'name': 'Sat'},
    {'value': 0, 'name': 'Sun'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Subscription'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Product Info Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.local_drink,
                        size: 32,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${widget.product.pricePerUnit.toStringAsFixed(2)}/${widget.product.unit}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quantity Input
            const Text(
              'Quantity',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (_quantity > 0.5) _quantity -= 0.5;
                    });
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: 36,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_quantity.toStringAsFixed(1)} ${widget.product.unit}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() => _quantity += 0.5);
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 36,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Frequency Selection
            const Text(
              'Delivery Frequency',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildFrequencySelector(),
            const SizedBox(height: 16),

            // Day Selection for Weekly/Custom
            if (_frequency == 'weekly' || _frequency == 'custom')
              _buildDaySelector(),

            const SizedBox(height: 24),

            // Start Date
            const Text(
              'Start Date',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectStartDate(),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMM dd, yyyy').format(_startDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // End Date Option
            CheckboxListTile(
              title: const Text('Set End Date'),
              value: _hasEndDate,
              onChanged: (value) {
                setState(() {
                  _hasEndDate = value ?? false;
                  if (!_hasEndDate) _endDate = null;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            if (_hasEndDate) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectEndDate(),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _endDate != null
                            ? DateFormat('MMM dd, yyyy').format(_endDate!)
                            : 'Select End Date',
                        style: TextStyle(
                          fontSize: 16,
                          color: _endDate != null ? Colors.black : Colors.grey,
                        ),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),

            // Price Summary
            _buildPriceSummary(),
            const SizedBox(height: 24),

            // Create Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createSubscription,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Create Subscription',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencySelector() {
    return Column(
      children: [
        _buildFrequencyOption('daily', 'Daily', 'Delivered every day'),
        _buildFrequencyOption('weekly', 'Weekly', 'Select specific days of the week'),
        _buildFrequencyOption('custom', 'Custom Days', 'Choose particular days'),
      ],
    );
  }

  Widget _buildFrequencyOption(String value, String title, String subtitle) {
    return InkWell(
      onTap: () {
        setState(() {
          _frequency = value;
          if (_frequency == 'daily') {
            _selectedDays = [];
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _frequency,
              onChanged: (val) {
                setState(() {
                  _frequency = val!;
                  if (_frequency == 'daily') {
                    _selectedDays = [];
                  }
                });
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _frequency == 'weekly'
              ? 'Select Days of the Week'
              : 'Select Delivery Days',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _weekDays.map((day) {
            final isSelected = _selectedDays.contains(day['value']);
            return FilterChip(
              label: Text(day['name']),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedDays.add(day['value']);
                    _selectedDays.sort();
                  } else {
                    _selectedDays.remove(day['value']);
                  }
                });
              },
              selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              checkmarkColor: Theme.of(context).primaryColor,
            );
          }).toList(),
        ),
        if (_selectedDays.isEmpty && (_frequency == 'weekly' || _frequency == 'custom'))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Please select at least one day',
              style: TextStyle(color: Colors.red.shade700, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildPriceSummary() {
    final pricePerDelivery = _quantity * widget.product.pricePerUnit;

    // Calculate estimated monthly cost based on frequency
    double estimatedMonthlyCost = 0;
    if (_frequency == 'daily') {
      estimatedMonthlyCost = pricePerDelivery * 30;
    } else if (_frequency == 'weekly' && _selectedDays.isNotEmpty) {
      estimatedMonthlyCost = pricePerDelivery * _selectedDays.length * 4;
    } else if (_frequency == 'custom' && _selectedDays.isNotEmpty) {
      estimatedMonthlyCost = pricePerDelivery * _selectedDays.length * 4;
    }

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Per Delivery:'),
                Text(
                  '₹${pricePerDelivery.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Estimated Monthly:'),
                Text(
                  '₹${estimatedMonthlyCost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _createSubscription() async {
    if (_formKey.currentState?.validate() ?? false) {
      if ((_frequency == 'weekly' || _frequency == 'custom') && _selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one day')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        // Convert to multi-product format for new API
        await _apiService.createSubscription({
          'products': [
            {
              'productId': widget.product.id,
              'quantity': _quantity,
            }
          ],
          'frequency': _frequency,
          if (_frequency == 'weekly' || _frequency == 'custom')
            'selectedDays': _selectedDays,
          'startDate': DateFormat('yyyy-MM-dd').format(_startDate),
          if (_hasEndDate && _endDate != null)
            'endDate': DateFormat('yyyy-MM-dd').format(_endDate!),
          'autoRenewal': false,
        });

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subscription created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
}
