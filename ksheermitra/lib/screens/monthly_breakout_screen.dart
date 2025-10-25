import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/monthly_breakout.dart';
import '../services/monthly_breakout_service.dart';

class MonthlyBreakoutScreen extends StatefulWidget {
  final String subscriptionId;

  const MonthlyBreakoutScreen({
    Key? key,
    required this.subscriptionId,
  }) : super(key: key);

  @override
  State<MonthlyBreakoutScreen> createState() => _MonthlyBreakoutScreenState();
}

class _MonthlyBreakoutScreenState extends State<MonthlyBreakoutScreen> {
  final MonthlyBreakoutService _breakoutService = MonthlyBreakoutService();
  MonthlyBreakoutResponse? _breakout;
  bool _isLoading = true;
  String? _error;

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadMonthlyBreakout();
  }

  Future<void> _loadMonthlyBreakout() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final breakout = await _breakoutService.getSubscriptionMonthlyBreakout(
        subscriptionId: widget.subscriptionId,
        year: _selectedDate.year,
        month: _selectedDate.month,
      );

      setState(() {
        _breakout = breakout;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month + delta,
        1,
      );
    });
    _loadMonthlyBreakout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Breakout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _breakout != null ? _generateInvoice : null,
            tooltip: 'Generate Invoice',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildMonthSelector(),
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadMonthlyBreakout,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (_breakout != null)
            Expanded(
              child: Column(
                children: [
                  _buildSummaryCard(),
                  Expanded(child: _buildBreakoutList()),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withAlpha(25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeMonth(-1),
          ),
          Text(
            _breakout?.monthName ?? DateFormat('MMMM yyyy').format(_selectedDate),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    if (_breakout == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryRow(
              'Total Amount',
              _breakout!.totalAmount,
              Colors.blue,
              isBold: true,
            ),
            const Divider(),
            _buildSummaryRow(
              'Delivered',
              _breakout!.deliveredAmount,
              Colors.green,
            ),
            _buildSummaryRow(
              'Pending',
              _breakout!.pendingAmount,
              Colors.orange,
            ),
            if (_breakout!.cancelledAmount > 0)
              _buildSummaryRow(
                'Cancelled',
                _breakout!.cancelledAmount,
                Colors.red,
              ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCountChip(
                  'Delivered: ${_breakout!.deliveredCount}',
                  Colors.green,
                ),
                _buildCountChip(
                  'Pending: ${_breakout!.pendingCount}',
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 16,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: isBold ? 20 : 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountChip(String label, Color color) {
    return Chip(
      label: Text(label),
      backgroundColor: color.withAlpha(25),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildBreakoutList() {
    if (_breakout == null || _breakout!.breakout.isEmpty) {
      return const Center(
        child: Text('No deliveries for this month'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _breakout!.breakout.length,
      itemBuilder: (context, index) {
        final daily = _breakout!.breakout[index];
        return _buildDailyBreakoutCard(daily);
      },
    );
  }

  Widget _buildDailyBreakoutCard(DailyBreakout daily) {
    Color statusColor;
    IconData statusIcon;

    switch (daily.status) {
      case 'delivered':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'missed':
        statusColor = Colors.grey;
        statusIcon = Icons.warning;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: daily.isEditable ? () => _showModifyDialog(daily) : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${daily.dayOfWeek}, ${DateFormat('dd MMM').format(DateTime.parse(daily.date))}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '₹${daily.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: statusColor,
                        ),
                      ),
                      if (daily.isEditable)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.edit, size: 16, color: Colors.blue),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...daily.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text('${item.productName}'),
                          if (item.isOneTime)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple.withAlpha(51),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'One-time',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.purple,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '${item.quantity} ${item.unit} × ₹${item.pricePerUnit}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )),
              if (daily.notes != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Note: ${daily.notes}',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showModifyDialog(DailyBreakout daily) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modify Delivery - ${DateFormat('dd MMM').format(DateTime.parse(daily.date))}'),
        content: const Text(
          'This feature will allow you to modify products for this delivery. '
          'Would you like to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to product modification screen
              // Navigator.push(context, MaterialPageRoute(...));
            },
            child: const Text('Modify'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateInvoice() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await _breakoutService.generateMonthlyInvoice(
        year: _selectedDate.year,
        month: _selectedDate.month,
      );

      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invoice generated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
