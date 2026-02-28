import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/dairy_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/premium_widgets.dart';

class DeliveryBoyHistoryScreen extends StatefulWidget {
  const DeliveryBoyHistoryScreen({super.key});

  @override
  State<DeliveryBoyHistoryScreen> createState() => _DeliveryBoyHistoryScreenState();
}

class _DeliveryBoyHistoryScreenState extends State<DeliveryBoyHistoryScreen> {
  bool _isLoading = true;
  List<DailyDeliverySummary> _deliverySummaries = [];
  String _selectedFilter = 'week';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final response = await apiService.get(
        '/delivery-boy/history',
        queryParams: {'filter': _selectedFilter},
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as List<dynamic>;
        _deliverySummaries = data.map((d) => DailyDeliverySummary.fromJson(d)).toList();
      } else {
        _deliverySummaries = [];
      }
    } catch (e) {
      _deliverySummaries = [];
    }

    setState(() => _isLoading = false);
  }


  @override
  Widget build(BuildContext context) {
    // Calculate totals
    final totalDeliveries = _deliverySummaries.fold<int>(0, (sum, s) => sum + s.totalDeliveries);
    final totalCompleted = _deliverySummaries.fold<int>(0, (sum, s) => sum + s.completed);
    final totalAmount = _deliverySummaries.fold<double>(0, (sum, s) => sum + s.totalAmount);
    final totalCollected = _deliverySummaries.fold<double>(0, (sum, s) => sum + s.collected);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery History'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadHistory,
              child: Column(
                children: [
                  // Filter Tabs
                  Container(
                    padding: const EdgeInsets.all(DairySpacing.md),
                    color: DairyColorsLight.surface,
                    child: Row(
                      children: [
                        _buildFilterChip('week', 'This Week'),
                        const SizedBox(width: DairySpacing.sm),
                        _buildFilterChip('month', 'This Month'),
                        const SizedBox(width: DairySpacing.sm),
                        _buildFilterChip('all', 'All Time'),
                      ],
                    ),
                  ),

                  // Summary Cards
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DairySpacing.md,
                      vertical: DairySpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'Deliveries',
                            '$totalDeliveries',
                            '$totalCompleted completed',
                            Icons.local_shipping,
                            DairyColorsLight.primary,
                          ),
                        ),
                        const SizedBox(width: DairySpacing.sm),
                        Expanded(
                          child: _buildSummaryCard(
                            'Earnings',
                            '₹${totalCollected.toStringAsFixed(0)}',
                            'of ₹${totalAmount.toStringAsFixed(0)}',
                            Icons.account_balance_wallet,
                            DairyColorsLight.success,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // History List
                  Expanded(
                    child: _deliverySummaries.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 64,
                                  color: DairyColorsLight.textTertiary,
                                ),
                                const SizedBox(height: DairySpacing.md),
                                Text(
                                  'No delivery history',
                                  style: DairyTypography.headingSmall(),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(DairySpacing.md),
                            itemCount: _deliverySummaries.length,
                            itemBuilder: (context, index) {
                              return _buildDaySummaryCard(_deliverySummaries[index]);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilter = value);
        _loadHistory();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DairySpacing.md,
          vertical: DairySpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? DairyColorsLight.primary : Colors.white,
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

  Widget _buildSummaryCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DairySpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: DairyRadius.defaultBorderRadius,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: DairySpacing.sm + 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: DairyTypography.caption(color: DairyColorsLight.textSecondary)),
                  Text(value, style: DairyTypography.headingSmall()),
                  Text(subtitle, style: DairyTypography.caption(color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySummaryCard(DailyDeliverySummary summary) {
    final isToday = DateUtils.isSameDay(summary.date, DateTime.now());
    final completionRate = summary.totalDeliveries > 0
        ? (summary.completed / summary.totalDeliveries * 100).round()
        : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: DairySpacing.sm),
      color: isToday ? DairyColorsLight.primarySurface : null,
      child: InkWell(
        onTap: () => _showDayDetails(summary),
        borderRadius: DairyRadius.defaultBorderRadius,
        child: Padding(
          padding: const EdgeInsets.all(DairySpacing.md),
          child: Column(
            children: [
              // Date Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isToday
                          ? DairyColorsLight.primary
                          : DairyColorsLight.surface,
                      borderRadius: DairyRadius.defaultBorderRadius,
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('dd').format(summary.date),
                          style: DairyTypography.headingSmall(
                            color: isToday ? Colors.white : DairyColorsLight.textPrimary,
                          ),
                        ),
                        Text(
                          DateFormat('MMM').format(summary.date),
                          style: DairyTypography.caption(
                            color: isToday ? Colors.white70 : DairyColorsLight.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: DairySpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isToday
                              ? 'Today'
                              : DateFormat('EEEE').format(summary.date),
                          style: DairyTypography.bodyLarge().copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${summary.completed}/${summary.totalDeliveries} deliveries completed',
                          style: DairyTypography.bodySmall(color: DairyColorsLight.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${summary.collected.toStringAsFixed(0)}',
                        style: DairyTypography.price(),
                      ),
                      Text(
                        '$completionRate%',
                        style: DairyTypography.caption(
                          color: completionRate >= 90
                              ? DairyColorsLight.success
                              : completionRate >= 70
                                  ? DairyColorsLight.warning
                                  : DairyColorsLight.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: DairySpacing.sm),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: summary.totalDeliveries > 0
                      ? summary.completed / summary.totalDeliveries
                      : 0,
                  backgroundColor: DairyColorsLight.border,
                  color: completionRate >= 90
                      ? DairyColorsLight.success
                      : completionRate >= 70
                          ? DairyColorsLight.warning
                          : DairyColorsLight.error,
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDayDetails(DailyDeliverySummary summary) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DairyRadius.xl)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(DairySpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: DairyColorsLight.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: DairySpacing.lg),
            Text(
              DateFormat('EEEE, dd MMMM yyyy').format(summary.date),
              style: DairyTypography.headingSmall(),
            ),
            const SizedBox(height: DairySpacing.lg),

            Row(
              children: [
                Expanded(child: _buildDetailCard('Total', '${summary.totalDeliveries}', Icons.list)),
                const SizedBox(width: DairySpacing.sm),
                Expanded(child: _buildDetailCard('Completed', '${summary.completed}', Icons.check_circle, DairyColorsLight.success)),
                const SizedBox(width: DairySpacing.sm),
                Expanded(child: _buildDetailCard('Pending', '${summary.pending}', Icons.pending, DairyColorsLight.warning)),
              ],
            ),

            const SizedBox(height: DairySpacing.md),

            Container(
              padding: const EdgeInsets.all(DairySpacing.md),
              decoration: BoxDecoration(
                color: DairyColorsLight.surface,
                borderRadius: DairyRadius.defaultBorderRadius,
              ),
              child: Column(
                children: [
                  _buildAmountRow('Total Amount', '₹${summary.totalAmount.toStringAsFixed(2)}'),
                  const Divider(),
                  _buildAmountRow('Collected', '₹${summary.collected.toStringAsFixed(2)}', DairyColorsLight.success),
                  const Divider(),
                  _buildAmountRow('Pending', '₹${(summary.totalAmount - summary.collected).toStringAsFixed(2)}', DairyColorsLight.warning),
                ],
              ),
            ),

            const SizedBox(height: DairySpacing.lg),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon, [Color? color]) {
    return Container(
      padding: const EdgeInsets.all(DairySpacing.md),
      decoration: BoxDecoration(
        color: DairyColorsLight.surface,
        borderRadius: DairyRadius.defaultBorderRadius,
      ),
      child: Column(
        children: [
          Icon(icon, color: color ?? DairyColorsLight.primary),
          const SizedBox(height: 4),
          Text(value, style: DairyTypography.headingSmall()),
          Text(label, style: DairyTypography.caption(color: DairyColorsLight.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: DairyTypography.body()),
          Text(
            value,
            style: DairyTypography.bodyLarge().copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class DailyDeliverySummary {
  final DateTime date;
  final int totalDeliveries;
  final int completed;
  final int pending;
  final double totalAmount;
  final double collected;

  DailyDeliverySummary({
    required this.date,
    required this.totalDeliveries,
    required this.completed,
    required this.pending,
    required this.totalAmount,
    required this.collected,
  });

  factory DailyDeliverySummary.fromJson(Map<String, dynamic> json) {
    return DailyDeliverySummary(
      date: DateTime.parse(json['date']?.toString() ?? DateTime.now().toIso8601String()),
      totalDeliveries: int.tryParse(json['totalDeliveries']?.toString() ?? '0') ?? 0,
      completed: int.tryParse(json['completed']?.toString() ?? '0') ?? 0,
      pending: int.tryParse(json['pending']?.toString() ?? '0') ?? 0,
      totalAmount: double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0,
      collected: double.tryParse(json['collected']?.toString() ?? '0') ?? 0,
    );
  }
}

