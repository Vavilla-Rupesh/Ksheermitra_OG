import 'package:flutter/material.dart';
import '../../../config/dairy_theme.dart';
import 'package:provider/provider.dart';
import '../../../models/user.dart';
import '../../../providers/customer_provider.dart';
import '../../../widgets/subscription_detail_popup.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final String customerId;

  const CustomerDetailsScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  User? _customer;
  bool _isLoading = true;
  String? _error;

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
    _loadCustomerDetails();
  }

  Future<void> _loadCustomerDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final customer = await context
        .read<CustomerProvider>()
        .getCustomerDetails(widget.customerId);

    setState(() {
      _customer = customer;
      _isLoading = false;
      _error = customer == null ? 'Failed to load customer details' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: _customer != null
                ? () {
                    // Call customer
                  }
                : null,
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'whatsapp',
                child: Row(
                  children: [
                    Icon(Icons.message, size: 20),
                    SizedBox(width: 8),
                    Text('Send WhatsApp'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'deactivate',
                child: Row(
                  children: [
                    Icon(Icons.block, size: 20),
                    SizedBox(width: 8),
                    Text('Deactivate'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              // Handle menu actions
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadCustomerDetails,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _buildCustomerDetails(),
    );
  }

  Widget _buildCustomerDetails() {
    if (_customer == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          const Divider(),
          _buildInfoSection(),
          const Divider(),
          _buildSubscriptionsSection(),
          const Divider(),
          _buildDeliveriesSection(),
          const Divider(),
          _buildInvoicesSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              _customer!.name?.substring(0, 1).toUpperCase() ?? 'C',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _customer!.name ?? 'No Name',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _customer!.isActive
                  ? Colors.green
                  : Colors.grey,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _customer!.isActive ? 'Active' : 'Inactive',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.phone, 'Phone', _customer!.phone),
          if (_customer!.email != null)
            _buildInfoRow(Icons.email, 'Email', _customer!.email!),
          if (_customer!.address != null)
            _buildInfoRow(Icons.location_on, 'Address', _customer!.address!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionsSection() {
    final subscriptions = _customer?.subscriptions ?? [];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subscriptions (${subscriptions.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (subscriptions.isEmpty)
            Card(
              child: ListTile(
                leading: const Icon(Icons.subscriptions, color: Colors.orange),
                title: const Text('No active subscriptions'),
                subtitle: const Text('Customer has not created any subscriptions'),
                trailing: const Icon(Icons.add_circle_outline, size: 20),
                onTap: () {
                  // Navigate to create subscription
                },
              ),
            )
          else
            Column(
              children: [
                _buildSubscriptionCategorySection('Daily', subscriptions, 'daily', Icons.wb_sunny),
                const SizedBox(height: 12),
                _buildSubscriptionCategorySection('Selected Days', subscriptions, 'selected_days', Icons.date_range),
                const SizedBox(height: 12),
                _buildSubscriptionCategorySection('Monthly', subscriptions, 'monthly', Icons.calendar_month),
                const SizedBox(height: 12),
                _buildSubscriptionCategorySection('Custom', subscriptions, 'custom', Icons.tune),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCategorySection(
    String title,
    List<dynamic> allSubscriptions,
    String category,
    IconData icon,
  ) {
    final categorySubscriptions = _getSubscriptionsByCategory(allSubscriptions, category);
    final isExpanded = _expandedCategories[category] ?? false;

    if (categorySubscriptions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DairyRadius.md),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedCategories[category] = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(DairyRadius.md),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${categorySubscriptions.length} subscription${categorySubscriptions.length != 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: DairyColorsLight.textSecondary,
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
            ...categorySubscriptions.map((subscription) => InkWell(
              onTap: () => _showSubscriptionDetails(subscription),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: DairyColorsLight.surfaceVariant,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: subscription.isActive
                            ? Colors.green.withValues(alpha: 0.1)
                            : subscription.isPaused
                                ? Colors.orange.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.repeat,
                        color: subscription.isActive
                            ? Colors.green
                            : subscription.isPaused
                                ? Colors.orange
                                : Colors.red,
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
                          Text(
                            '₹${subscription.totalCostPerDelivery.toStringAsFixed(2)}/delivery',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
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
                            color: subscription.isActive
                                ? Colors.green
                                : subscription.isPaused
                                    ? Colors.orange
                                    : Colors.red,
                            borderRadius: BorderRadius.circular(DairyRadius.md),
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
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
          ],
        ],
      ),
    );
  }

  List<dynamic> _getSubscriptionsByCategory(List<dynamic> subscriptions, String category) {
    switch (category) {
      case 'daily':
        return subscriptions.where((s) => s.frequency == 'daily').toList();
      case 'selected_days':
        return subscriptions.where((s) =>
          (s.frequency == 'weekly' || s.frequency == 'custom') &&
          s.selectedDays != null &&
          s.selectedDays!.isNotEmpty
        ).toList();
      case 'monthly':
        return subscriptions.where((s) => s.frequency == 'monthly').toList();
      case 'custom':
        return subscriptions.where((s) => s.frequency == 'daterange').toList();
      default:
        return [];
    }
  }

  void _showSubscriptionDetails(dynamic subscription) {
    showDialog(
      context: context,
      builder: (context) => SubscriptionDetailPopup(subscription: subscription),
    );
  }

  Widget _buildDeliveriesSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Deliveries',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No deliveries yet',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicesSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Invoices',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No invoices yet',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
