import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';
import '../../../models/offline_sale.dart';
import '../../../services/offline_sale_service.dart';
import '../../../services/api_service.dart';
import 'create_offline_sale_screen.dart';
import 'offline_sale_detail_screen.dart';

class OfflineSalesListScreen extends StatefulWidget {
  const OfflineSalesListScreen({super.key});

  @override
  State<OfflineSalesListScreen> createState() => _OfflineSalesListScreenState();
}

class _OfflineSalesListScreenState extends State<OfflineSalesListScreen> {
  List<OfflineSale> _sales = [];
  SalesStats? _stats;
  bool _isLoading = false;
  String? _error;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _loadSales();
    _loadStats();
  }

  Future<void> _loadSales() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final offlineSaleService = OfflineSaleService(apiService);

      final sales = await offlineSaleService.getOfflineSales(
        startDate: _dateRange?.start.toIso8601String().split('T')[0],
        endDate: _dateRange?.end.toIso8601String().split('T')[0],
      );

      setState(() {
        _sales = sales;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStats() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final offlineSaleService = OfflineSaleService(apiService);

      final stats = await offlineSaleService.getSalesStats(
        startDate: _dateRange?.start.toIso8601String().split('T')[0],
        endDate: _dateRange?.end.toIso8601String().split('T')[0],
      );

      setState(() {
        _stats = stats;
      });
    } catch (e) {
      // Stats are optional, don't show error
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
      _loadSales();
      _loadStats();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _dateRange = null;
    });
    _loadSales();
    _loadStats();
  }

  Future<void> _navigateToCreateSale() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateOfflineSaleScreen(),
      ),
    );

    if (result == true) {
      _loadSales();
      _loadStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.mainBackground,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              if (_stats != null) _buildStatsCard(),
              _buildFilterBar(),
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateSale,
        icon: const Icon(Icons.add),
        label: const Text('New Sale'),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.appBarGradient,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            const Expanded(
              child: Text(
                'Offline Sales',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                _loadSales();
                _loadStats();
              },
              icon: const Icon(Icons.refresh, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Total Sales',
                _stats!.totalSales.toString(),
                Icons.shopping_cart,
                AppTheme.primaryColor,
              ),
              Container(width: 1, height: 40, color: DairyColorsLight.border),
              _buildStatItem(
                'Revenue',
                '₹${_stats!.totalRevenue.toStringAsFixed(0)}',
                Icons.currency_rupee,
                Colors.green,
              ),
              Container(width: 1, height: 40, color: DairyColorsLight.border),
              _buildStatItem(
                'Avg Sale',
                '₹${_stats!.averageSaleAmount.toStringAsFixed(0)}',
                Icons.trending_up,
                Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: DairyColorsLight.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _selectDateRange,
              icon: const Icon(Icons.date_range),
              label: Text(
                _dateRange == null
                    ? 'Filter by Date'
                    : '${DateFormat('MMM d').format(_dateRange!.start)} - ${DateFormat('MMM d').format(_dateRange!.end)}',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ),
          if (_dateRange != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: _clearDateFilter,
              icon: const Icon(Icons.clear),
              color: Colors.red,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSales,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_sales.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No sales found',
              style: TextStyle(
                fontSize: 18,
                color: DairyColorsLight.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first in-store sale',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadSales();
        await _loadStats();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _sales.length,
        itemBuilder: (context, index) {
          final sale = _sales[index];
          return _buildSaleCard(sale);
        },
      ),
    );
  }

  Widget _buildSaleCard(OfflineSale sale) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OfflineSaleDetailScreen(saleId: sale.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    sale.saleNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  _buildPaymentBadge(sale.paymentMethod),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: DairyColorsLight.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d, yyyy • HH:mm').format(sale.createdAt),
                    style: TextStyle(
                      color: DairyColorsLight.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sale.customerName ?? 'Walk-in Customer',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        '${sale.items.length} items',
                        style: TextStyle(
                          fontSize: 12,
                          color: DairyColorsLight.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '₹${sale.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentBadge(String method) {
    Color color;
    IconData icon;

    switch (method) {
      case 'cash':
        color = Colors.green;
        icon = Icons.money;
        break;
      case 'card':
        color = Colors.blue;
        icon = Icons.credit_card;
        break;
      case 'upi':
        color = Colors.purple;
        icon = Icons.qr_code;
        break;
      default:
        color = Colors.grey;
        icon = Icons.payment;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DairyRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            method.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

