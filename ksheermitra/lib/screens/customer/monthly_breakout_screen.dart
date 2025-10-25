import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/monthly_breakout.dart';
import '../../services/customer_api_service.dart';

class MonthlyBreakoutScreen extends StatefulWidget {
  const MonthlyBreakoutScreen({super.key});

  @override
  State<MonthlyBreakoutScreen> createState() => _MonthlyBreakoutScreenState();
}

class _MonthlyBreakoutScreenState extends State<MonthlyBreakoutScreen> {
  final CustomerApiService _apiService = CustomerApiService();

  late int _selectedYear;
  late int _selectedMonth;

  CustomerMonthlyBreakout? _breakout;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _loadMonthlyBreakout();
  }

  Future<void> _loadMonthlyBreakout() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final breakout = await _apiService.getCustomerMonthlyBreakout(
        _selectedYear,
        _selectedMonth,
      );

      setState(() {
        _breakout = breakout;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading monthly breakout: $e';
        _isLoading = false;
      });
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth += delta;
      if (_selectedMonth > 12) {
        _selectedMonth = 1;
        _selectedYear++;
      } else if (_selectedMonth < 1) {
        _selectedMonth = 12;
        _selectedYear--;
      }
    });
    _loadMonthlyBreakout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Breakout'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Column(
                  children: [
                    _buildMonthSelector(),
                    if (_breakout != null) ...[
                      _buildSummaryCard(),
                      Expanded(child: _buildSubscriptionsList()),
                    ],
                  ],
                ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeMonth(-1),
          ),
          Text(
            DateFormat('MMMM yyyy').format(
              DateTime(_selectedYear, _selectedMonth),
            ),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Total: ₹${_breakout!.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Delivered: ₹${_breakout!.deliveredAmount.toStringAsFixed(2)}'),
            Text('Pending: ₹${_breakout!.pendingAmount.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionsList() {
    if (_breakout == null || _breakout!.subscriptions.isEmpty) {
      return const Center(child: Text('No subscriptions found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _breakout!.subscriptions.length,
      itemBuilder: (context, index) {
        final subscription = _breakout!.subscriptions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            title: Text('Subscription ${index + 1}'),
            subtitle: Text('₹${subscription.totalAmount.toStringAsFixed(2)}'),
            children: subscription.breakout.map((daily) {
              return ListTile(
                title: Text(DateFormat('dd MMM').format(DateTime.parse(daily.date))),
                subtitle: Text(daily.items.map((i) => i.productName).join(', ')),
                trailing: Text('₹${daily.amount.toStringAsFixed(2)}'),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

