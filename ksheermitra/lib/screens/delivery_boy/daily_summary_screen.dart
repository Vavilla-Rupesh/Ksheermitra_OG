import 'package:flutter/material.dart';
import '../../config/dairy_theme.dart';
import '../../models/delivery_models.dart';
import '../../services/delivery_service.dart';

class DailySummaryScreen extends StatefulWidget {
  const DailySummaryScreen({Key? key}) : super(key: key);

  @override
  State<DailySummaryScreen> createState() => _DailySummaryScreenState();
}

class _DailySummaryScreenState extends State<DailySummaryScreen> {
  final DeliveryService _deliveryService = DeliveryService();
  DeliveryStats? _stats;
  bool _isLoading = true;
  bool _isGeneratingInvoice = false;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() => _isLoading = true);

    try {
      final stats = await _deliveryService.getDeliveryStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading summary: $e')),
        );
      }
    }
  }

  Future<void> _generateInvoice() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Day & Generate Invoice'),
        content: const Text(
          'This will generate a PDF invoice and send it to the admin via WhatsApp. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Generate Invoice'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isGeneratingInvoice = true);

    try {
      await _deliveryService.generateDailyInvoice();

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600], size: 32),
                const SizedBox(width: 12),
                const Text('Success!'),
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
                const Text('📄 PDF created with all delivery details'),
                const SizedBox(height: 8),
                const Text('📱 WhatsApp sent to admin'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Great work today! Your deliveries have been recorded.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  if (context.mounted) {
                    Navigator.pop(context); // Close screen
                  }
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingInvoice = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalDeliveries = (_stats?.pending ?? 0) +
                           (_stats?.delivered ?? 0) +
                           (_stats?.missed ?? 0);
    final completionRate = totalDeliveries > 0
        ? ((_stats?.delivered ?? 0) / totalDeliveries * 100).toStringAsFixed(1)
        : '0.0';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Summary'),
        backgroundColor: DairyColorsLight.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(DairySpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Date Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DairyRadius.lg),
                      side: const BorderSide(color: DairyColorsLight.border, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(DairySpacing.lg),
                      child: Column(
                        children: [
                          Icon(Icons.calendar_today, size: 44, color: DairyColorsLight.primary),
                          const SizedBox(height: DairySpacing.md),
                          Text(
                            DateTime.now().toString().split(' ')[0],
                            style: DairyTypography.headingLarge(),
                          ),
                          const SizedBox(height: DairySpacing.xs),
                          Text(
                            _getDayOfWeek(),
                            style: DairyTypography.body(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: DairySpacing.md),

                  // Stats Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Pending',
                          _stats?.pending.toString() ?? '0',
                          Icons.pending,
                          DairyColorsLight.info,
                        ),
                      ),
                      const SizedBox(width: DairySpacing.md),
                      Expanded(
                        child: _buildStatCard(
                          'Delivered',
                          _stats?.delivered.toString() ?? '0',
                          Icons.check_circle,
                          DairyColorsLight.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DairySpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Missed',
                          _stats?.missed.toString() ?? '0',
                          Icons.cancel,
                          DairyColorsLight.error,
                        ),
                      ),
                      const SizedBox(width: DairySpacing.md),
                      Expanded(
                        child: _buildStatCard(
                          'Total',
                          totalDeliveries.toString(),
                          Icons.local_shipping,
                          DairyColorsLight.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DairySpacing.md),

                  // Completion Rate Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DairyRadius.lg),
                      side: const BorderSide(color: DairyColorsLight.border, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(DairySpacing.lg),
                      child: Column(
                        children: [
                          Text(
                            'Completion Rate',
                            style: DairyTypography.body(),
                          ),
                          const SizedBox(height: DairySpacing.md),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: CircularProgressIndicator(
                                  value: double.parse(completionRate) / 100,
                                  strokeWidth: 12,
                                  backgroundColor: DairyColorsLight.surfaceVariant,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    DairyColorsLight.success,
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    '$completionRate%',
                                    style: DairyTypography.headingLarge(color: DairyColorsLight.success),
                                  ),
                                  Text(
                                    'Complete',
                                    style: DairyTypography.caption(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: DairySpacing.md),

                  // Amount Collected Card
                  Container(
                    padding: const EdgeInsets.all(DairySpacing.lg),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [DairyColorsLight.success, Color(0xFF16A34A)],
                      ),
                      borderRadius: BorderRadius.circular(DairyRadius.lg),
                      boxShadow: [
                        BoxShadow(
                          color: DairyColorsLight.success.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.currency_rupee, color: Colors.white, size: 28),
                            const SizedBox(width: DairySpacing.sm),
                            Text(
                              'Total Collected',
                              style: DairyTypography.bodyLarge(color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: DairySpacing.md),
                        Text(
                          '₹${_stats?.collectedAmount.toStringAsFixed(2) ?? '0.00'}',
                          style: DairyTypography.headingXLarge(color: Colors.white).copyWith(fontSize: 40),
                        ),
                        const SizedBox(height: DairySpacing.sm),
                        Text(
                          'From ${_stats?.delivered ?? 0} deliveries',
                          style: DairyTypography.bodySmall(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: DairySpacing.lg),

                  // Performance Message
                  if ((_stats?.pending ?? 0) == 0 && totalDeliveries > 0)
                    Container(
                      padding: const EdgeInsets.all(DairySpacing.md),
                      decoration: BoxDecoration(
                        color: DairyColorsLight.successSurface,
                        borderRadius: BorderRadius.circular(DairyRadius.lg),
                        border: Border.all(color: DairyColorsLight.success.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.stars, color: DairyColorsLight.success, size: 28),
                          const SizedBox(width: DairySpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Excellent Work!',
                                  style: DairyTypography.headingSmall(),
                                ),
                                const SizedBox(height: DairySpacing.xs),
                                Text(
                                  'All deliveries completed for today',
                                  style: DairyTypography.bodySmall(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  if ((_stats?.pending ?? 0) > 0)
                    Container(
                      padding: const EdgeInsets.all(DairySpacing.md),
                      decoration: BoxDecoration(
                        color: DairyColorsLight.warningSurface,
                        borderRadius: BorderRadius.circular(DairyRadius.lg),
                        border: Border.all(color: DairyColorsLight.warning.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: DairyColorsLight.warning, size: 28),
                          const SizedBox(width: DairySpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pending Deliveries',
                                  style: DairyTypography.headingSmall(),
                                ),
                                const SizedBox(height: DairySpacing.xs),
                                Text(
                                  '${_stats?.pending ?? 0} deliveries still pending',
                                  style: DairyTypography.bodySmall(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 100), // Space for button
                ],
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(DairySpacing.md),
        decoration: BoxDecoration(
          color: DairyColorsLight.card,
          border: const Border(
            top: BorderSide(color: DairyColorsLight.border, width: 1),
          ),
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: _isGeneratingInvoice ? null : _generateInvoice,
            icon: _isGeneratingInvoice
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Icon(Icons.receipt_long, color: Colors.white, size: 20),
            label: Text(
              _isGeneratingInvoice ? 'Generating...' : 'End Day & Generate Invoice',
              style: DairyTypography.button(),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: DairyColorsLight.primary,
              padding: const EdgeInsets.symmetric(vertical: DairySpacing.buttonPaddingV),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DairyRadius.button),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DairyRadius.lg),
        side: const BorderSide(color: DairyColorsLight.border, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DairySpacing.md),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: DairySpacing.sm),
            Text(
              value,
              style: DairyTypography.headingLarge(color: color),
            ),
            const SizedBox(height: DairySpacing.xs),
            Text(
              label,
              style: DairyTypography.caption(),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayOfWeek() {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[DateTime.now().weekday - 1];
  }
}

