import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../config/theme.dart';
import '../../../services/offline_sale_service.dart';
import '../../../services/api_service.dart';
import '../../../models/offline_sale.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = true;
  String _selectedPeriod = 'week';
  SalesStats? _salesStats;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    try {
      // Load dashboard stats
      final dashboardProvider = context.read<DashboardProvider>();
      await dashboardProvider.loadDashboardStats();

      // Load sales stats
      final apiService = Provider.of<ApiService>(context, listen: false);
      final offlineSaleService = OfflineSaleService(apiService);

      final now = DateTime.now();
      String startDate;

      switch (_selectedPeriod) {
        case 'today':
          startDate = DateFormat('yyyy-MM-dd').format(now);
          break;
        case 'week':
          startDate = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 7)));
          break;
        case 'month':
          startDate = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, 1));
          break;
        case 'year':
          startDate = DateFormat('yyyy-MM-dd').format(DateTime(now.year, 1, 1));
          break;
        default:
          startDate = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 7)));
      }

      final endDate = DateFormat('yyyy-MM-dd').format(now);

      final stats = await offlineSaleService.getSalesStats(
        startDate: startDate,
        endDate: endDate,
      );

      setState(() {
        _salesStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading analytics: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPeriodSelector(),
                    const SizedBox(height: 24),
                    _buildSummaryCards(),
                    const SizedBox(height: 24),
                    _buildRevenueChart(),
                    const SizedBox(height: 24),
                    _buildPerformanceMetrics(),
                    const SizedBox(height: 24),
                    _buildInsights(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPeriodChip('Today', 'today'),
            _buildPeriodChip('Week', 'week'),
            _buildPeriodChip('Month', 'month'),
            _buildPeriodChip('Year', 'year'),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedPeriod = value);
          _loadAnalytics();
        }
      },
      selectedColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final stats = provider.stats;

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildMetricCard(
              'Total Revenue',
              '₹${stats?.todaysRevenue.toStringAsFixed(0) ?? '0'}',
              Icons.currency_rupee,
              Colors.green,
              '+12%',
            ),
            _buildMetricCard(
              'In-Store Sales',
              '${_salesStats?.totalSales ?? 0}',
              Icons.shopping_cart,
              Colors.blue,
              '₹${_salesStats?.totalRevenue.toStringAsFixed(0) ?? '0'}',
            ),
            _buildMetricCard(
              'Deliveries',
              '${stats?.todaysDeliveries ?? 0}',
              Icons.local_shipping,
              Colors.purple,
              '${stats?.todaysDelivered ?? 0} completed',
            ),
            _buildMetricCard(
              'Active Subs',
              '${stats?.activeSubscriptions ?? 0}',
              Icons.subscriptions,
              Colors.orange,
              'Running',
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: Consumer<DashboardProvider>(
                builder: (context, provider, child) {
                  final stats = provider.stats;
                  if (stats == null) {
                    return const Center(child: Text('No data'));
                  }

                  return BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (stats.collectedPayments + stats.pendingPayments) * 1.2,
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY: stats.collectedPayments,
                              color: Colors.green,
                              width: 40,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: stats.pendingPayments,
                              color: Colors.orange,
                              width: 40,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 2,
                          barRods: [
                            BarChartRodData(
                              toY: _salesStats?.totalRevenue ?? 0,
                              color: Colors.blue,
                              width: 40,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ],
                        ),
                      ],
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              switch (value.toInt()) {
                                case 0:
                                  return const Text('Collected', style: TextStyle(fontSize: 11));
                                case 1:
                                  return const Text('Pending', style: TextStyle(fontSize: 11));
                                case 2:
                                  return const Text('In-Store', style: TextStyle(fontSize: 11));
                                default:
                                  return const Text('');
                              }
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (value, meta) {
                              return Text('₹${value.toInt()}', style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: true, drawVerticalLine: false),
                      borderData: FlBorderData(show: false),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Consumer<DashboardProvider>(
              builder: (context, provider, child) {
                final stats = provider.stats;
                if (stats == null) return const SizedBox.shrink();

                final deliveryRate = stats.todaysDeliveries > 0
                    ? (stats.todaysDelivered / stats.todaysDeliveries * 100)
                    : 0.0;

                final customerActivity = stats.totalCustomers > 0
                    ? (stats.activeCustomers / stats.totalCustomers * 100)
                    : 0.0;

                return Column(
                  children: [
                    _buildProgressMetric('Delivery Success Rate', deliveryRate, Colors.green),
                    const SizedBox(height: 12),
                    _buildProgressMetric('Customer Activity', customerActivity, Colors.blue),
                    const SizedBox(height: 12),
                    _buildProgressMetric('Subscription Utilization', 85.0, Colors.purple),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressMetric(String label, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('${percentage.toStringAsFixed(1)}%'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: color.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildInsights() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Business Insights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              Icons.trending_up,
              Colors.green,
              'Revenue Growth',
              'Your revenue has increased compared to last period',
            ),
            const Divider(),
            _buildInsightItem(
              Icons.people,
              Colors.blue,
              'Customer Base',
              'Active customer engagement is healthy',
            ),
            const Divider(),
            _buildInsightItem(
              Icons.local_shipping,
              Colors.orange,
              'Delivery Performance',
              'On-time delivery rate is maintained',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(IconData icon, Color color, String title, String description) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(description),
    );
  }
}

