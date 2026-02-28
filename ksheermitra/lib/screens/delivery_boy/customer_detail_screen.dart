import 'package:flutter/material.dart';
import '../../models/delivery_models.dart';
import '../../services/delivery_service.dart';
import '../../core/delivery_verification/delivery_verification.dart';

class CustomerDetailScreen extends StatefulWidget {
  final Customer customer;

  const CustomerDetailScreen({Key? key, required this.customer}) : super(key: key);

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final DeliveryService _deliveryService = DeliveryService();
  bool _isUpdating = false;
  bool _showGpsVerification = false;

  Future<void> _updateStatus(String status) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm ${status == 'delivered' ? 'Delivery' : 'Missed'}'),
        content: Text(
          status == 'delivered'
              ? 'Mark this delivery as completed? Customer will receive WhatsApp confirmation.'
              : 'Mark this delivery as missed? Customer will be notified.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'delivered' ? Colors.green : Colors.red,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isUpdating = true);

    try {
      await _deliveryService.updateDeliveryStatus(
        customerId: widget.customer.id,
        status: status,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Delivery marked as $status. WhatsApp notification sent!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
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
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalAmount = 0;

    if (widget.customer.subscriptions != null) {
      for (var subscription in widget.customer.subscriptions!) {
        if (subscription.products != null) {
          for (var sp in subscription.products!) {
            if (sp.product != null) {
              totalAmount += sp.quantity * sp.product!.pricePerUnit;
            }
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer.name),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Customer Info Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.blue[100],
                          child: Text(
                            widget.customer.name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.customer.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        if (widget.customer.deliveryStatus != null)
                          _buildStatusChip(widget.customer.deliveryStatus!),
                        const Divider(height: 32),
                        _buildInfoRow(
                          Icons.phone,
                          'Phone',
                          widget.customer.phone,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.location_on,
                          'Address',
                          widget.customer.address ?? 'No address',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Subscriptions
                if (widget.customer.subscriptions != null &&
                    widget.customer.subscriptions!.isNotEmpty) ...[
                  const Text(
                    'Active Subscriptions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...widget.customer.subscriptions!.expand((subscription) {
                    return subscription.products?.map((sp) {
                      final product = sp.product;
                      if (product == null) return const SizedBox.shrink();

                      final itemTotal = sp.quantity * product.pricePerUnit;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.orange[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    _getProductEmoji(product.name),
                                    style: const TextStyle(fontSize: 30),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${sp.quantity} ${product.unit}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      '₹${product.pricePerUnit}/${product.unit}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '₹${itemTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList() ?? [];
                  }),
                  const SizedBox(height: 16),

                  // Total Amount Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green[400]!, Colors.green[600]!],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              'To Collect Today',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '₹${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 100), // Space for buttons
              ],
            ),
          ),

          // Bottom action buttons
          if (widget.customer.deliveryStatus == 'pending')
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: _showGpsVerification && _hasValidLocation()
                    ? _buildGpsVerificationWidget()
                    : _buildActionButtons(),
              ),
            ),

          if (_isUpdating)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Updating delivery status...'),
                        Text(
                          'Sending WhatsApp notification',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'delivered':
        color = Colors.green;
        text = 'Delivered';
        icon = Icons.check_circle;
        break;
      case 'missed':
        color = Colors.red;
        text = 'Missed';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.blue;
        text = 'Pending';
        icon = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _getProductEmoji(String productName) {
    final name = productName.toLowerCase();
    if (name.contains('milk')) return '🥛';
    if (name.contains('curd') || name.contains('dahi')) return '🥣';
    if (name.contains('butter') || name.contains('ghee')) return '🧈';
    if (name.contains('paneer')) return '🧀';
    if (name.contains('lassi')) return '🥤';
    return '📦';
  }

  bool _hasValidLocation() {
    return widget.customer.latitude != null &&
           widget.customer.longitude != null &&
           widget.customer.latitude != 0.0 &&
           widget.customer.longitude != 0.0;
  }

  Widget _buildActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Show GPS verification option if customer has valid location
        if (_hasValidLocation())
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _showGpsVerification = true),
              icon: const Icon(Icons.gps_fixed),
              label: const Text('Verify with GPS'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isUpdating ? null : () => _updateStatus('missed'),
                icon: const Icon(Icons.cancel, color: Colors.white),
                label: const Text(
                  'Missed',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isUpdating ? null : () => _updateStatus('delivered'),
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: const Text(
                  'Delivered',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGpsVerificationWidget() {
    // Create a DeliveryOrder from the customer data
    final order = DeliveryOrder(
      id: widget.customer.deliveryId ?? widget.customer.id,
      customerId: widget.customer.id,
      customerName: widget.customer.name,
      customerPhone: widget.customer.phone,
      deliveryAddress: widget.customer.address ?? '',
      destination: DeliveryLocation(
        latitude: widget.customer.latitude!,
        longitude: widget.customer.longitude!,
      ),
      allowedRadiusMeters: 100.0, // 100 meter radius
      status: DeliveryOrderStatus.pending,
      items: const [],
      totalAmount: 0,
      deliveryDate: DateTime.now(),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Back button to return to normal buttons
        TextButton.icon(
          onPressed: () => setState(() => _showGpsVerification = false),
          icon: const Icon(Icons.arrow_back, size: 18),
          label: const Text('Back to manual options'),
        ),
        const SizedBox(height: 8),
        // GPS Verification Widget
        ProductionDeliveryVerificationWidget(
          order: order,
          config: DeliveryVerificationConfig(
            showDistanceIndicator: true,
            deliverButtonText: 'Verify & Deliver',
            outsideButtonText: 'Move closer to customer',
            onDeliverySuccess: () {
              // Delivery verified successfully via GPS
              Navigator.pop(context, true);
            },
            onDeliveryFailed: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Verification failed: $error'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
