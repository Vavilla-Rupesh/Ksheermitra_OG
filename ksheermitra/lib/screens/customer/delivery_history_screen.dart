import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/delivery.dart';
import '../../services/customer_api_service.dart';
import '../../config/dairy_theme.dart';
import '../../widgets/premium_widgets.dart';

class DeliveryHistoryScreen extends StatefulWidget {
  const DeliveryHistoryScreen({super.key});

  @override
  State<DeliveryHistoryScreen> createState() => _DeliveryHistoryScreenState();
}

class _DeliveryHistoryScreenState extends State<DeliveryHistoryScreen> {
  final CustomerApiService _apiService = CustomerApiService();
  List<Delivery> _deliveries = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadDeliveries();
  }

  Future<void> _loadDeliveries() async {
    setState(() => _isLoading = true);
    try {
      final deliveries = await _apiService.getDeliveryHistory();
      setState(() {
        _deliveries = deliveries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading deliveries: $e')),
        );
      }
    }
  }

  List<Delivery> get _filteredDeliveries {
    if (_selectedFilter == 'all') return _deliveries;
    return _deliveries.where((d) => d.status == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _isLoading
                ? const PremiumLoadingWidget(message: 'Loading delivery history...')
                : _filteredDeliveries.isEmpty
                    ? PremiumEmptyState(
                        icon: Icons.local_shipping_outlined,
                        title: 'No Delivery History',
                        message: _selectedFilter == 'all'
                            ? 'You don\'t have any deliveries yet'
                            : 'No $_selectedFilter deliveries found',
                      )
                    : RefreshIndicator(
                        onRefresh: _loadDeliveries,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(AppTheme.space16),
                          itemCount: _filteredDeliveries.length,
                          itemBuilder: (context, index) {
                            final delivery = _filteredDeliveries[index];
                            return _buildDeliveryCard(delivery);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text('Filter: ', style: AppTheme.labelText),
          const SizedBox(width: AppTheme.space8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'All'),
                  _buildFilterChip('delivered', 'Delivered'),
                  _buildFilterChip('pending', 'Pending'),
                  _buildFilterChip('missed', 'Missed'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.space8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedFilter = value);
        },
        selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
        checkmarkColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildDeliveryCard(Delivery delivery) {
    final isDelivered = delivery.status.toLowerCase() == 'delivered';
    final isPending = delivery.status.toLowerCase() == 'pending';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.space12),
      child: PremiumCard(
        onTap: () => _showDeliveryDetails(delivery),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.space12),
                  decoration: BoxDecoration(
                    gradient: isDelivered
                        ? AppTheme.deliveredGradient
                        : isPending
                            ? AppTheme.pendingGradient
                            : LinearGradient(
                                colors: [AppTheme.errorRed, AppTheme.errorRed.withValues(alpha: 0.7)],
                              ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Icon(
                    isDelivered
                        ? Icons.check_circle
                        : isPending
                            ? Icons.local_shipping
                            : Icons.cancel,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppTheme.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMM dd, yyyy').format(delivery.deliveryDate),
                        style: AppTheme.h5,
                      ),
                      const SizedBox(height: AppTheme.space4),
                      if (delivery.product != null)
                        Text(
                          delivery.product!.name,
                          style: AppTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                if (isDelivered)
                  PremiumBadge.delivered('Delivered')
                else if (isPending)
                  PremiumBadge.pending('Pending')
                else
                  PremiumBadge.error('Missed'),
              ],
            ),

            if (delivery.product != null) ...[
              const SizedBox(height: AppTheme.space12),
              Container(
                height: 1,
                color: AppTheme.textTertiary.withValues(alpha: 0.2),
              ),
              const SizedBox(height: AppTheme.space12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    delivery.product!.name,
                    style: AppTheme.bodyMedium,
                  ),
                  Text(
                    '${delivery.quantity.toInt()} ${delivery.product!.unit}',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],

            if (delivery.deliveryBoy != null) ...[
              const SizedBox(height: AppTheme.space12),
              Container(
                height: 1,
                color: AppTheme.textTertiary.withValues(alpha: 0.2),
              ),
              const SizedBox(height: AppTheme.space12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.space8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: AppTheme.space8),
                  Text(
                    'Delivered by ${delivery.deliveryBoy!.name ?? 'Delivery Boy'}',
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeliveryDetails(Delivery delivery) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLarge)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppTheme.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.space20),
              Text('Delivery Details', style: AppTheme.h3),
              const SizedBox(height: AppTheme.space24),

              // Status
              Row(
                children: [
                  Text('Status: ', style: AppTheme.bodyLarge),
                  if (delivery.status.toLowerCase() == 'delivered')
                    PremiumBadge.delivered(delivery.status)
                  else if (delivery.status.toLowerCase() == 'pending')
                    PremiumBadge.pending(delivery.status)
                  else
                    PremiumBadge.error(delivery.status),
                ],
              ),

              const SizedBox(height: AppTheme.space16),
              const Divider(),
              const SizedBox(height: AppTheme.space16),

              // Item Details
              Text('Item Delivered:', style: AppTheme.h5),
              const SizedBox(height: AppTheme.space12),
              if (delivery.product != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.space8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(delivery.product!.name, style: AppTheme.bodyMedium),
                      Text(
                        '${delivery.quantity.toInt()} ${delivery.product!.unit}',
                        style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: AppTheme.space24),
              SizedBox(
                width: double.infinity,
                child: PremiumButton(
                  text: 'Close',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
