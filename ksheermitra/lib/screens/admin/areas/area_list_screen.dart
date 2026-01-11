import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/area.dart';
import '../../../providers/area_provider.dart';
import '../../../providers/delivery_boy_provider.dart';
import 'area_form_screen.dart';
import 'area_map_screen.dart';

class AreaListScreen extends StatefulWidget {
  const AreaListScreen({super.key});

  @override
  State<AreaListScreen> createState() => _AreaListScreenState();
}

class _AreaListScreenState extends State<AreaListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AreaProvider>().loadAreas();
      context.read<DeliveryBoyProvider>().loadDeliveryBoys();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Areas'),
      ),
      body: Consumer<AreaProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => provider.loadAreas(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.areas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No areas yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first area',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadAreas(),
            child: ListView.builder(
              itemCount: provider.areas.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final area = provider.areas[index];
                return _buildAreaCard(area);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAreaOptions,
        icon: const Icon(Icons.add),
        label: const Text('Add Area'),
      ),
    );
  }

  void _showAddAreaOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Add New Area',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.purple,
                child: Icon(Icons.map, color: Colors.white),
              ),
              title: const Text('Draw on Map'),
              subtitle: const Text('Create area by drawing boundary on map'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _navigateToMapScreen(null);
              },
            ),
            const Divider(),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.add, color: Colors.white),
              ),
              title: const Text('Quick Add'),
              subtitle: const Text('Create area with basic details only'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _navigateToAreaForm(null);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaCard(Area area) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: area.isActive ? Colors.purple : Colors.grey,
          child: const Icon(
            Icons.map,
            color: Colors.white,
          ),
        ),
        title: Text(
          area.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (area.description != null) ...[
              Text(
                area.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
            ],
            if (area.deliveryBoy != null) ...[
              Row(
                children: [
                  const Icon(Icons.delivery_dining, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('Delivery Boy: ${area.deliveryBoy!.name}'),
                ],
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                const Icon(Icons.people, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${area.customerCount} customers'),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: area.isActive
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    area.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: area.isActive ? Colors.green : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
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
                  Text('Edit Details'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'map',
              child: Row(
                children: [
                  Icon(Icons.map, size: 20),
                  SizedBox(width: 8),
                  Text('Edit Boundary'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'assign',
              child: Row(
                children: [
                  Icon(Icons.person_add, size: 20),
                  SizedBox(width: 8),
                  Text('Assign Customers'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _navigateToAreaForm(area);
            } else if (value == 'map') {
              _navigateToMapScreen(area);
            } else if (value == 'assign') {
              _navigateToAssignCustomers(area);
            }
          },
        ),
      ),
    );
  }

  void _navigateToAreaForm(Area? area) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AreaFormScreen(area: area),
      ),
    );

    if (result == true && mounted) {
      context.read<AreaProvider>().loadAreas();
    }
  }

  void _navigateToMapScreen(Area? area) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AreaMapScreen(area: area),
      ),
    );

    if (result == true && mounted) {
      context.read<AreaProvider>().loadAreas();
    }
  }

  void _navigateToAssignCustomers(Area area) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Customer assignment coming soon')),
    );
  }
}
