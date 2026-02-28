import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/dairy_theme.dart';
import '../../services/api_service.dart';

class DeliveryBoyEarningsScreen extends StatefulWidget {
  const DeliveryBoyEarningsScreen({super.key});

  @override
  State<DeliveryBoyEarningsScreen> createState() => _DeliveryBoyEarningsScreenState();
}

class _DeliveryBoyEarningsScreenState extends State<DeliveryBoyEarningsScreen> {
  bool _isLoading = true;
  String _selectedPeriod = 'month';
  Map<String, dynamic> _earningsData = {};
  List<EarningEntry> _earningsList = [];

  @override
  void initState() {
    super.initState();
    _loadEarnings();
  }

  Future<void> _loadEarnings() async {
    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final response = await apiService.get(
        '/delivery-boy/earnings',
        queryParams: {'period': _selectedPeriod},
      );

      if (response['success'] == true && response['data'] != null) {
        _earningsData = response['data'] as Map<String, dynamic>;
        _earningsList = (response['data']['entries'] as List<dynamic>?)
            ?.map((e) => EarningEntry.fromJson(e))
            .toList() ?? [];
      } else {
        _earningsData = _getDemoEarningsData();
        _earningsList = _getDemoEarningsList();
      }
    } catch (e) {
      _earningsData = _getDemoEarningsData();
      _earningsList = _getDemoEarningsList();
    }

    setState(() => _isLoading = false);
  }

  Map<String, dynamic> _getDemoEarningsData() {
    return {
      'totalEarnings': 15500.0,
      'thisMonth': 4200.0,
      'lastMonth': 3800.0,
      'pendingPayout': 1200.0,
      'totalDeliveries': 320,
      'averagePerDelivery': 48.44,
      'bonusEarned': 500.0,
    };
  }

  List<EarningEntry> _getDemoEarningsList() {
    final now = DateTime.now();
    return List.generate(10, (index) {
      final date = now.subtract(Duration(days: index));
      return EarningEntry(
        date: date,
        deliveries: 12 + (index % 5),
        baseEarning: 400.0 + (index * 20),
        bonus: index % 3 == 0 ? 50.0 : 0.0,
        deductions: 0.0,
        netEarning: 400.0 + (index * 20) + (index % 3 == 0 ? 50.0 : 0.0),
        status: index < 3 ? 'pending' : 'paid',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Earnings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showEarningsInfo,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadEarnings,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Summary Card
                    _buildSummaryCard(),

                    // Period Filter
                    _buildPeriodFilter(),

                    // Stats Grid
                    _buildStatsGrid(),

                    // Earnings List
                    _buildEarningsList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(DairySpacing.md),
      padding: const EdgeInsets.all(DairySpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [DairyColorsLight.primary, DairyColorsLight.primaryDark],
        ),
        borderRadius: DairyRadius.largeBorderRadius,
        boxShadow: DairyColorsLight.elevatedShadow,
      ),
      child: Column(
        children: [
          Text(
            'Total Earnings',
            style: DairyTypography.label(color: Colors.white70),
          ),
          const SizedBox(height: DairySpacing.sm),
          Text(
            '₹${(_earningsData['totalEarnings'] ?? 0).toStringAsFixed(0)}',
            style: DairyTypography.headingLarge(color: Colors.white).copyWith(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DairySpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSummaryItem(
                'This Month',
                '₹${(_earningsData['thisMonth'] ?? 0).toStringAsFixed(0)}',
                Icons.calendar_today,
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.white30,
              ),
              _buildSummaryItem(
                'Pending',
                '₹${(_earningsData['pendingPayout'] ?? 0).toStringAsFixed(0)}',
                Icons.pending_actions,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(value, style: DairyTypography.headingSmall(color: Colors.white)),
        Text(label, style: DairyTypography.caption(color: Colors.white70)),
      ],
    );
  }

  Widget _buildPeriodFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DairySpacing.md),
      child: Row(
        children: [
          _buildFilterChip('week', 'This Week'),
          const SizedBox(width: DairySpacing.sm),
          _buildFilterChip('month', 'This Month'),
          const SizedBox(width: DairySpacing.sm),
          _buildFilterChip('year', 'This Year'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedPeriod == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPeriod = value);
        _loadEarnings();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DairySpacing.md,
          vertical: DairySpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? DairyColorsLight.primary : DairyColorsLight.surface,
          borderRadius: DairyRadius.pillBorderRadius,
          border: Border.all(
            color: isSelected ? DairyColorsLight.primary : DairyColorsLight.border,
          ),
        ),
        child: Text(
          label,
          style: DairyTypography.label(
            color: isSelected ? Colors.white : DairyColorsLight.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.all(DairySpacing.md),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Deliveries',
              '${_earningsData['totalDeliveries'] ?? 0}',
              Icons.local_shipping,
              DairyColorsLight.info,
            ),
          ),
          const SizedBox(width: DairySpacing.sm),
          Expanded(
            child: _buildStatCard(
              'Avg/Delivery',
              '₹${(_earningsData['averagePerDelivery'] ?? 0).toStringAsFixed(0)}',
              Icons.trending_up,
              DairyColorsLight.success,
            ),
          ),
          const SizedBox(width: DairySpacing.sm),
          Expanded(
            child: _buildStatCard(
              'Bonus',
              '₹${(_earningsData['bonusEarned'] ?? 0).toStringAsFixed(0)}',
              Icons.stars,
              DairyColorsLight.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(DairySpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DairyRadius.defaultBorderRadius,
        border: Border.all(color: DairyColorsLight.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: DairySpacing.sm),
          Text(value, style: DairyTypography.headingSmall()),
          Text(
            label,
            style: DairyTypography.caption(color: DairyColorsLight.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsList() {
    return Padding(
      padding: const EdgeInsets.all(DairySpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Earnings History', style: DairyTypography.headingSmall()),
          const SizedBox(height: DairySpacing.md),
          ..._earningsList.map((entry) => _buildEarningEntry(entry)),
        ],
      ),
    );
  }

  Widget _buildEarningEntry(EarningEntry entry) {
    final isPending = entry.status == 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: DairySpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(DairySpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                // Date
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: DairyColorsLight.surface,
                    borderRadius: DairyRadius.defaultBorderRadius,
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('dd').format(entry.date),
                        style: DairyTypography.headingSmall(),
                      ),
                      Text(
                        DateFormat('MMM').format(entry.date),
                        style: DairyTypography.caption(color: DairyColorsLight.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: DairySpacing.md),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.deliveries} deliveries',
                        style: DairyTypography.bodyLarge().copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Base: ₹${entry.baseEarning.toStringAsFixed(0)}${entry.bonus > 0 ? ' + Bonus: ₹${entry.bonus.toStringAsFixed(0)}' : ''}',
                        style: DairyTypography.caption(color: DairyColorsLight.textSecondary),
                      ),
                    ],
                  ),
                ),
                // Amount & Status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${entry.netEarning.toStringAsFixed(0)}',
                      style: DairyTypography.price(),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPending
                            ? DairyColorsLight.warningSurface
                            : DairyColorsLight.successSurface,
                        borderRadius: DairyRadius.pillBorderRadius,
                      ),
                      child: Text(
                        isPending ? 'Pending' : 'Paid',
                        style: DairyTypography.caption(
                          color: isPending
                              ? DairyColorsLight.warning
                              : DairyColorsLight.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEarningsInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How Earnings Work'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoItem('Base Earnings', 'You earn ₹30-50 per successful delivery based on distance.'),
              _buildInfoItem('Bonus', 'Complete 15+ deliveries daily to earn bonus rewards.'),
              _buildInfoItem('On-Time Bonus', 'Additional ₹5 for deliveries completed before 7 AM.'),
              _buildInfoItem('Payouts', 'Earnings are paid weekly every Monday.'),
              _buildInfoItem('Deductions', 'Cancelled or returned orders may result in deductions.'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DairySpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: DairyTypography.label()),
          const SizedBox(height: 4),
          Text(
            description,
            style: DairyTypography.bodySmall(color: DairyColorsLight.textSecondary),
          ),
        ],
      ),
    );
  }
}

class EarningEntry {
  final DateTime date;
  final int deliveries;
  final double baseEarning;
  final double bonus;
  final double deductions;
  final double netEarning;
  final String status;

  EarningEntry({
    required this.date,
    required this.deliveries,
    required this.baseEarning,
    required this.bonus,
    required this.deductions,
    required this.netEarning,
    required this.status,
  });

  factory EarningEntry.fromJson(Map<String, dynamic> json) {
    return EarningEntry(
      date: DateTime.parse(json['date']?.toString() ?? DateTime.now().toIso8601String()),
      deliveries: int.tryParse(json['deliveries']?.toString() ?? '0') ?? 0,
      baseEarning: double.tryParse(json['baseEarning']?.toString() ?? '0') ?? 0,
      bonus: double.tryParse(json['bonus']?.toString() ?? '0') ?? 0,
      deductions: double.tryParse(json['deductions']?.toString() ?? '0') ?? 0,
      netEarning: double.tryParse(json['netEarning']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'pending',
    );
  }
}

