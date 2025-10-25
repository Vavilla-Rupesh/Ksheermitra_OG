import 'package:flutter/material.dart';
import '../../models/delivery_boy.dart';
import '../../services/admin_service.dart';
import 'add_delivery_boy_screen.dart';
import 'delivery_boy_details_screen.dart';
import 'area_assignment_screen.dart';

class DeliveryBoyListScreen extends StatefulWidget {
  const DeliveryBoyListScreen({Key? key}) : super(key: key);

  @override
  State<DeliveryBoyListScreen> createState() => _DeliveryBoyListScreenState();
}

class _DeliveryBoyListScreenState extends State<DeliveryBoyListScreen> {
  final AdminService _adminService = AdminService();
  List<DeliveryBoy> _deliveryBoys = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDeliveryBoys();
  }

  Future<void> _loadDeliveryBoys() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final deliveryBoys = await _adminService.getDeliveryBoys();
      setState(() {
        _deliveryBoys = deliveryBoys;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleActiveStatus(DeliveryBoy deliveryBoy) async {
    try {
      await _adminService.updateDeliveryBoy(
        id: deliveryBoy.id,
        isActive: !deliveryBoy.isActive,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            deliveryBoy.isActive ? 'Delivery boy deactivated' : 'Delivery boy activated',
          ),
          backgroundColor: Colors.green,
        ),
      );

      _loadDeliveryBoys();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Boys'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDeliveryBoys,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddDeliveryBoyScreen(),
            ),
          );

          if (result == true) {
            _loadDeliveryBoys();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Delivery Boy'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDeliveryBoys,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_deliveryBoys.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delivery_dining, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No delivery boys yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first delivery boy to get started',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDeliveryBoys,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _deliveryBoys.length,
        itemBuilder: (context, index) {
          final deliveryBoy = _deliveryBoys[index];
          return _buildDeliveryBoyCard(deliveryBoy);
        },
      ),
    );
  }

  Widget _buildDeliveryBoyCard(DeliveryBoy deliveryBoy) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeliveryBoyDetailsScreen(
                deliveryBoyId: deliveryBoy.id,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: deliveryBoy.isActive
                        ? Colors.green.shade100
                        : Colors.grey.shade300,
                    child: Icon(
                      Icons.delivery_dining,
                      color: deliveryBoy.isActive ? Colors.green : Colors.grey,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                deliveryBoy.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: deliveryBoy.isActive
                                    ? Colors.green.shade100
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                deliveryBoy.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: deliveryBoy.isActive
                                      ? Colors.green.shade700
                                      : Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.phone, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              deliveryBoy.phone,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (deliveryBoy.area != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, size: 20, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assigned Area',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              deliveryBoy.area!.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, size: 20, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'No area assigned yet',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (deliveryBoy.area == null)
                    TextButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AreaAssignmentScreen(
                              deliveryBoy: deliveryBoy,
                            ),
                          ),
                        );

                        if (result == true) {
                          _loadDeliveryBoys();
                        }
                      },
                      icon: const Icon(Icons.map, size: 18),
                      label: const Text('Assign Area'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _toggleActiveStatus(deliveryBoy),
                    icon: Icon(
                      deliveryBoy.isActive ? Icons.block : Icons.check_circle,
                      size: 18,
                    ),
                    label: Text(deliveryBoy.isActive ? 'Deactivate' : 'Activate'),
                    style: TextButton.styleFrom(
                      foregroundColor: deliveryBoy.isActive ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
