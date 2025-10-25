import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/delivery_models.dart';
import '../../services/delivery_service.dart';
import 'assign_area_screen.dart';

class DeliveryBoyDetailScreen extends StatefulWidget {
  final DeliveryBoy deliveryBoy;

  const DeliveryBoyDetailScreen({Key? key, required this.deliveryBoy})
      : super(key: key);

  @override
  State<DeliveryBoyDetailScreen> createState() =>
      _DeliveryBoyDetailScreenState();
}

class _DeliveryBoyDetailScreenState extends State<DeliveryBoyDetailScreen> {
  final DeliveryService _deliveryService = DeliveryService();
  DeliveryBoy? _deliveryBoy;
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _deliveryBoy = widget.deliveryBoy;
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() => _isLoading = true);

    try {
      final details = await _deliveryService.getDeliveryBoyDetails(_deliveryBoy!.id);
      setState(() {
        _deliveryBoy = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading details: $e')),
        );
      }
    }
  }

  Future<void> _navigateToAssignArea() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssignAreaScreen(deliveryBoy: _deliveryBoy!),
      ),
    );

    if (result == true) {
      _loadDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_deliveryBoy?.name ?? 'Delivery Boy Details'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit screen
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Card
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
                            radius: 50,
                            backgroundColor: Colors.blue[100],
                            child: Text(
                              _deliveryBoy!.name[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _deliveryBoy!.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _deliveryBoy!.isActive
                                  ? Colors.green[100]
                                  : Colors.red[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _deliveryBoy!.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color: _deliveryBoy!.isActive
                                    ? Colors.green[900]
                                    : Colors.red[900],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Divider(height: 32),
                          _buildInfoRow(Icons.phone, 'Phone', _deliveryBoy!.phone),
                          if (_deliveryBoy!.email != null) ...[
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.email, 'Email', _deliveryBoy!.email!),
                          ],
                          if (_deliveryBoy!.address != null) ...[
                            const SizedBox(height: 12),
                            _buildInfoRow(
                                Icons.home, 'Address', _deliveryBoy!.address!),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Area Assignment Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.map, color: Colors.blue),
                              const SizedBox(width: 8),
                              const Text(
                                'Assigned Area',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_deliveryBoy!.area != null) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _deliveryBoy!.area!.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  if (_deliveryBoy!.area!.description != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      _deliveryBoy!.area!.description!,
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_deliveryBoy!.area!.customers?.length ?? 0} Customers',
                                        style: TextStyle(color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _navigateToAssignArea,
                              icon: const Icon(Icons.edit),
                              label: const Text('Change Area'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange[200]!),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.warning_amber,
                                      size: 48, color: Colors.orange[700]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No area assigned yet',
                                    style: TextStyle(
                                      color: Colors.orange[900],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Assign an area to start deliveries',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _navigateToAssignArea,
                              icon: const Icon(Icons.add_location),
                              label: const Text('Assign Area'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(48),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Location Map
                  if (_deliveryBoy!.latitude != null &&
                      _deliveryBoy!.longitude != null) ...[
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.blue),
                                const SizedBox(width: 8),
                                const Text(
                                  'Base Location',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 200,
                            clipBehavior: Clip.antiAlias,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                  _deliveryBoy!.latitude!,
                                  _deliveryBoy!.longitude!,
                                ),
                                zoom: 15,
                              ),
                              markers: {
                                Marker(
                                  markerId: const MarkerId('base_location'),
                                  position: LatLng(
                                    _deliveryBoy!.latitude!,
                                    _deliveryBoy!.longitude!,
                                  ),
                                  icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueBlue,
                                  ),
                                  infoWindow: InfoWindow(
                                    title: _deliveryBoy!.name,
                                    snippet: 'Base Location',
                                  ),
                                ),
                              },
                              zoomControlsEnabled: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
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
}

