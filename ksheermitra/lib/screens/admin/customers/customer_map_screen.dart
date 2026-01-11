import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../models/user.dart';
import '../../../providers/customer_provider.dart';

class CustomerMapScreen extends StatefulWidget {
  const CustomerMapScreen({super.key});

  @override
  State<CustomerMapScreen> createState() => _CustomerMapScreenState();
}

class _CustomerMapScreenState extends State<CustomerMapScreen> {
  GoogleMapController? _mapController;
  List<User> _customers = [];
  Set<Marker> _markers = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCustomersWithLocations();
  }

  Future<void> _loadCustomersWithLocations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final allCustomers =
          await context.read<CustomerProvider>().loadCustomersWithLocations();
      
      // Filter out customers without valid locations
      final customersWithLocations = allCustomers.where((customer) {
        return customer.latitude != null &&
               customer.longitude != null &&
               customer.latitude != 0 &&
               customer.longitude != 0;
      }).toList();

      if (customersWithLocations.isEmpty) {
        setState(() {
          _customers = [];
          _markers = {};
          _isLoading = false;
          _error = 'No customers with valid locations found';
        });
        return;
      }

      final markers = customersWithLocations.map((customer) {
        return Marker(
          markerId: MarkerId(customer.id),
          position: LatLng(
            customer.latitude!,
            customer.longitude!,
          ),
          infoWindow: InfoWindow(
            title: customer.name ?? 'No Name',
            snippet: '${customer.phone}${customer.address != null ? '\n${customer.address}' : ''}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            customer.isActive
                ? BitmapDescriptor.hueBlue
                : BitmapDescriptor.hueRed,
          ),
          onTap: () {
            _showCustomerDetails(customer);
          },
        );
      }).toSet();

      setState(() {
        _customers = customersWithLocations;
        _markers = markers;
        _isLoading = false;
      });

      // Move camera to show all markers
      if (_mapController != null && customersWithLocations.isNotEmpty) {
        _fitMarkersInView();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading customer locations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _fitMarkersInView() {
    if (_customers.isEmpty || _mapController == null) return;

    double minLat = _customers.first.latitude!;
    double maxLat = _customers.first.latitude!;
    double minLng = _customers.first.longitude!;
    double maxLng = _customers.first.longitude!;

    for (var customer in _customers) {
      if (customer.latitude != null && customer.longitude != null) {
        if (customer.latitude! < minLat) minLat = customer.latitude!;
        if (customer.latitude! > maxLat) maxLat = customer.latitude!;
        if (customer.longitude! < minLng) minLng = customer.longitude!;
        if (customer.longitude! > maxLng) maxLng = customer.longitude!;
      }
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        50, // padding
      ),
    );
  }

  void _showCustomerDetails(User customer) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customer.name ?? 'Unknown Customer',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(customer.phone),
              ],
            ),
            if (customer.email != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.email, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(customer.email!),
                ],
              ),
            ],
            if (customer.address != null) ...[
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(child: Text(customer.address!)),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  customer.isActive ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: customer.isActive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  customer.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: customer.isActive ? Colors.green : Colors.red,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Map'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadCustomersWithLocations,
            ),
        ],
      ),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: $_error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadCustomersWithLocations,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            )
          else if (_customers.isEmpty)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No customers with locations',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _customers.first.latitude ?? 12.9716,
                  _customers.first.longitude ?? 77.5946,
                ),
                zoom: 12,
              ),
              markers: _markers,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              mapType: MapType.normal,
              onMapCreated: (controller) {
                _mapController = controller;
                _fitMarkersInView();
              },
            ),
          if (!_isLoading && _customers.isNotEmpty)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.people, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        '${_customers.length} customers on map',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.my_location, size: 20),
                        onPressed: _fitMarkersInView,
                        tooltip: 'Show all',
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
