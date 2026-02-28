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
                      const SizedBox(height: 12),
                      _buildCategorySection('Selected Days', 'selected_days', Icons.date_range),
                      const SizedBox(height: 12),
                      _buildCategorySection('Monthly', 'monthly', Icons.calendar_month),
                      const SizedBox(height: 12),
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedCategories[category] = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [DairyColorsLight.success, Color(0xFF66BB6A)]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${subscriptions.length} subscription${subscriptions.length != 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 28,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.local_drink,
                color: isActive ? Colors.green : Colors.orange,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
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
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '₹${subscription.totalCostPerDelivery.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ' • ${_getFrequencyText(subscription)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
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
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.green
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    subscription.status.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'View Details',
                  style: const TextStyle(
                    fontSize: 12,
                    color: DairyColorsLight.primary,
                    fontWeight: FontWeight.w600,
                  ),
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
