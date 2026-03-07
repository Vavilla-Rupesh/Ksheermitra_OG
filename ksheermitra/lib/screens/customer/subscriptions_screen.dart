import 'package:flutter/material.dart';
import '../../models/subscription.dart';
import '../../services/customer_api_service.dart';
import '../../config/dairy_theme.dart';
import '../../widgets/premium_widgets.dart';
import '../../widgets/subscription_detail_popup.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  final CustomerApiService _apiService = CustomerApiService();
  List<Subscription> _subscriptions = [];
  bool _isLoading = true;

  // Track which categories are expanded
  final Map<String, bool> _expandedCategories = {
    'daily': false,
    'selected_days': false,
    'monthly': false,
    'custom': false,
  };

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    setState(() => _isLoading = true);
    try {
      final subscriptions = await _apiService.getSubscriptions();
      setState(() {
        _subscriptions = subscriptions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading subscriptions: $e')),
        );
      }
    }
  }

  List<Subscription> _getSubscriptionsByCategory(String category) {
    switch (category) {
      case 'daily':
        return _subscriptions.where((s) => s.frequency == 'daily').toList();
      case 'selected_days':
        return _subscriptions.where((s) =>
          (s.frequency == 'weekly' || s.frequency == 'custom') &&
          s.selectedDays != null &&
          s.selectedDays!.isNotEmpty
        ).toList();
      case 'monthly':
        return _subscriptions.where((s) => s.frequency == 'monthly').toList();
      case 'custom':
        return _subscriptions.where((s) => s.frequency == 'daterange').toList();
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const PremiumLoadingWidget(message: 'Loading subscriptions...')
          : _subscriptions.isEmpty
              ? PremiumEmptyState(
                  icon: Icons.subscriptions_outlined,
                  title: 'No Active Subscriptions',
                  message: 'Start a subscription to get regular deliveries',
                  actionText: 'Browse Products',
                  onAction: () {
                    Navigator.pushNamed(context, '/products');
                  },
                )
              : RefreshIndicator(
                  onRefresh: _loadSubscriptions,
                  child: ListView(
                    padding: const EdgeInsets.all(DairySpacing.md),
                    children: [
                      _buildCategorySection('Daily', 'daily', Icons.wb_sunny),
                      const SizedBox(height: DairySpacing.md),
                      _buildCategorySection('Selected Days', 'selected_days', Icons.date_range),
                      const SizedBox(height: DairySpacing.md),
                      _buildCategorySection('Monthly', 'monthly', Icons.calendar_month),
                      const SizedBox(height: DairySpacing.md),
                      _buildCategorySection('Custom', 'custom', Icons.tune),
                    ],
                  ),
                ),
    );
  }

  Widget _buildCategorySection(String title, String category, IconData icon) {
    final subscriptions = _getSubscriptionsByCategory(category);
    final isExpanded = _expandedCategories[category] ?? false;

    if (subscriptions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DairyRadius.lg),
        side: const BorderSide(color: DairyColorsLight.border, width: 1),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedCategories[category] = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(DairyRadius.lg),
            child: Padding(
              padding: const EdgeInsets.all(DairySpacing.md),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(DairySpacing.sm + 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [DairyColorsLight.success, Color(0xFF66BB6A)]),
                      borderRadius: BorderRadius.circular(DairyRadius.button),
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: DairySpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: DairyTypography.headingSmall(),
                        ),
                        const SizedBox(height: DairySpacing.xs),
                        Text(
                          '${subscriptions.length} subscription${subscriptions.length != 1 ? 's' : ''}',
                          style: DairyTypography.caption(),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 24,
                    color: DairyColorsLight.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            ...subscriptions.map((subscription) => _buildSubscriptionItem(subscription)),
          ],
        ],
      ),
    );
  }

  Widget _buildSubscriptionItem(Subscription subscription) {
    final isActive = subscription.status.toLowerCase() == 'active';

    return InkWell(
      onTap: () => _showSubscriptionDetails(subscription),
      child: Container(
        padding: const EdgeInsets.all(DairySpacing.md),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: DairyColorsLight.border,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(DairySpacing.sm),
              decoration: BoxDecoration(
                color: isActive
                    ? DairyColorsLight.success.withValues(alpha: 0.1)
                    : DairyColorsLight.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DairyRadius.sm),
              ),
              child: Icon(
                Icons.local_drink,
                color: isActive ? DairyColorsLight.success : DairyColorsLight.warning,
                size: 20,
              ),
            ),
            const SizedBox(width: DairySpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subscription.products?.isNotEmpty == true
                        ? (subscription.products!.length == 1
                            ? subscription.products![0].product?.name ?? 'Product'
                            : '${subscription.products!.length} Products')
                        : 'Product',
                    style: DairyTypography.productName(),
                  ),
                  const SizedBox(height: DairySpacing.xs),
                  Row(
                    children: [
                      Text(
                        '₹${subscription.totalCostPerDelivery.toStringAsFixed(2)}',
                        style: DairyTypography.label(color: DairyColorsLight.success),
                      ),
                      Text(
                        ' • ${_getFrequencyText(subscription)}',
                        style: DairyTypography.caption(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DairySpacing.sm,
                    vertical: DairySpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? DairyColorsLight.success
                        : DairyColorsLight.warning,
                    borderRadius: BorderRadius.circular(DairyRadius.pill),
                  ),
                  child: Text(
                    subscription.status.toUpperCase(),
                    style: DairyTypography.badge(),
                  ),
                ),
                const SizedBox(height: DairySpacing.sm),
                Text(
                  'View Details',
                  style: DairyTypography.label(color: DairyColorsLight.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getFrequencyText(Subscription subscription) {
    if (subscription.frequency == 'daily') {
      return 'Daily';
    } else if (subscription.frequency == 'weekly' && subscription.selectedDays != null) {
      return 'Weekly (${subscription.selectedDays!.length} days)';
    } else if (subscription.frequency == 'custom' && subscription.selectedDays != null) {
      return 'Custom days';
    } else if (subscription.frequency == 'monthly') {
      return 'Monthly';
    }
    return subscription.frequency;
  }

  void _showSubscriptionDetails(Subscription subscription) {
    showDialog(
      context: context,
      builder: (context) => SubscriptionDetailPopup(subscription: subscription),
    );
  }
}
