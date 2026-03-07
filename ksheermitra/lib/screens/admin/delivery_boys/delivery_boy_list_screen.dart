import 'package:flutter/material.dart';
import '../../../config/dairy_theme.dart';
import 'package:provider/provider.dart';
import '../../../models/user.dart';
import '../../../providers/delivery_boy_provider.dart';
import 'delivery_boy_form_screen.dart';

class DeliveryBoyListScreen extends StatefulWidget {
  const DeliveryBoyListScreen({super.key});

  @override
  State<DeliveryBoyListScreen> createState() => _DeliveryBoyListScreenState();
}

class _DeliveryBoyListScreenState extends State<DeliveryBoyListScreen> {
  String _filter = 'all'; // all, active, inactive

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliveryBoyProvider>().loadDeliveryBoys();
    });
  }

  List<User> _getFilteredDeliveryBoys(DeliveryBoyProvider provider) {
    if (_filter == 'active') {
      return provider.activeDeliveryBoys;
    } else if (_filter == 'inactive') {
      return provider.deliveryBoys.where((db) => !db.isActive).toList();
    } else {
      return provider.deliveryBoys;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Boys'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'active', child: Text('Active Only')),
              const PopupMenuItem(
                  value: 'inactive', child: Text('Inactive Only')),
            ],
          ),
        ],
      ),
      body: Consumer<DeliveryBoyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => provider.loadDeliveryBoys(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final deliveryBoys = _getFilteredDeliveryBoys(provider);

          if (deliveryBoys.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delivery_dining_outlined,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No delivery boys yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first delivery boy',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadDeliveryBoys(),
            child: ListView.builder(
              itemCount: deliveryBoys.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final deliveryBoy = deliveryBoys[index];
                return _buildDeliveryBoyCard(deliveryBoy, provider);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToDeliveryBoyForm(null),
        icon: const Icon(Icons.add),
        label: const Text('Add Delivery Boy'),
      ),
    );
  }

  Widget _buildDeliveryBoyCard(User deliveryBoy, DeliveryBoyProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: deliveryBoy.isActive ? Colors.green : Colors.grey,
          child: Text(
            deliveryBoy.name?.substring(0, 1).toUpperCase() ?? 'D',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          deliveryBoy.name ?? 'No Name',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(deliveryBoy.phone),
              ],
            ),
            if (deliveryBoy.address != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      deliveryBoy.address!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: deliveryBoy.isActive
                    ? Colors.green.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(DairyRadius.md),
              ),
              child: Text(
                deliveryBoy.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: deliveryBoy.isActive ? Colors.green : Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
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
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(deliveryBoy.isActive ? Icons.block : Icons.check_circle,
                      size: 20),
                  SizedBox(width: 8),
                  Text(deliveryBoy.isActive ? 'Deactivate' : 'Activate'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _navigateToDeliveryBoyForm(deliveryBoy);
            } else if (value == 'toggle') {
              _toggleDeliveryBoyStatus(deliveryBoy, provider);
            }
          },
        ),
      ),
    );
  }

  void _navigateToDeliveryBoyForm(User? deliveryBoy) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeliveryBoyFormScreen(deliveryBoy: deliveryBoy),
      ),
    );

    if (result == true && mounted) {
      context.read<DeliveryBoyProvider>().loadDeliveryBoys();
    }
  }

  Future<void> _toggleDeliveryBoyStatus(
      User deliveryBoy, DeliveryBoyProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            deliveryBoy.isActive ? 'Deactivate?' : 'Activate?'),
        content: Text(
          deliveryBoy.isActive
              ? 'This delivery boy will not be able to receive new deliveries.'
              : 'This delivery boy will be able to receive deliveries.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await provider.updateDeliveryBoy(
        id: deliveryBoy.id,
        isActive: !deliveryBoy.isActive,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Status updated successfully'
                  : 'Failed to update status',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}
