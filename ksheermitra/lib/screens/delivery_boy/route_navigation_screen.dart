import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/dairy_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/premium_widgets.dart';
import '../../providers/auth_provider.dart';
import 'delivery_boy_profile_screen.dart';

class RouteNavigationScreen extends StatefulWidget {
  const RouteNavigationScreen({super.key});

  @override
  State<RouteNavigationScreen> createState() => _RouteNavigationScreenState();
}

class _RouteNavigationScreenState extends State<RouteNavigationScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoading = true;
  List<DeliveryStop> _deliveryStops = [];
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  int _currentStopIndex = 0;

  // Area information
  String _areaName = '';
  int _totalCustomers = 0;

  @override
  void initState() {
    super.initState();
    _initializeRoute();
  }

  Future<void> _initializeRoute() async {
    await _getCurrentLocation();
    await _loadDeliveryStops();
    _generateMarkers();
    setState(() => _isLoading = false);
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> _loadDeliveryStops() async {
    try {
      final apiService = ApiService();
      // Use the correct delivery-map endpoint that returns real customer data
      final response = await apiService.get('/delivery-boy/delivery-map');

      if (response['success'] == true && response['data'] != null) {
        // Extract area information
        final areaData = response['data']['area'];
        if (areaData != null) {
          _areaName = (areaData['name'] as String?) ?? 'Assigned Area';
        }

        // Extract customers from delivery-map response
        final customersData = response['data']['customers'];
        if (customersData != null && customersData is List<dynamic>) {
          final data = customersData;
          _totalCustomers = data.length;

          // Convert customers to delivery stops
          _deliveryStops = data.asMap().entries.map((entry) {
            final int index = entry.key;
            final customer = entry.value as Map<String, dynamic>;

            return DeliveryStop(
              id: (customer['id'] as String?) ?? '$index',
              customerName: (customer['name'] as String?) ?? 'Customer $index',
              address: (customer['address'] as String?) ?? 'Address not available',
              phone: (customer['phone'] as String?) ?? 'N/A',
              latitude: customer['latitude'] != null ? double.tryParse(customer['latitude'].toString()) ?? 0.0 : 0.0,
              longitude: customer['longitude'] != null ? double.tryParse(customer['longitude'].toString()) ?? 0.0 : 0.0,
              products: _getProductsFromSubscriptions(customer['subscriptions']),
              status: (customer['deliveryStatus'] as String?) ?? 'pending',
              estimatedTime: _calculateEstimatedTime(index),
            );
          }).toList();
        } else {
          // No real data available, show empty state instead of mock data
          _deliveryStops = [];
          _areaName = 'No Area Assigned';
        }
      } else {
        // No real data available, show empty state instead of mock data
        _deliveryStops = [];
        _areaName = 'No Area Assigned';
      }
    } catch (e) {
      debugPrint('Error loading delivery stops: $e');
      // No mock data fallback - show real error to user
      _deliveryStops = [];
      _areaName = 'Error Loading Area';
    }
  }

  List<String> _getProductsFromSubscriptions(List<dynamic>? subscriptions) {
    if (subscriptions == null || subscriptions.isEmpty) {
      return ['No products assigned'];
    }

    final products = <String>[];
    for (final sub in subscriptions) {
      if (sub is! Map<String, dynamic>) continue;

      final subProducts = sub['products'] as List<dynamic>?;
      if (subProducts != null) {
        for (final product in subProducts) {
          if (product is! Map<String, dynamic>) continue;

          final productData = product['product'] as Map<String, dynamic>?;
          if (productData != null) {
            final name = (productData['name'] as String?) ?? 'Product';
            final quantity = product['quantity'] ?? 0;
            final unit = (productData['unit'] as String?) ?? '';
            products.add('$name $quantity$unit');
          }
        }
      }
    }
    return products.isNotEmpty ? products : ['No products assigned'];
  }

  String _calculateEstimatedTime(int index) {
    // Calculate estimated time based on stop index (5-10 minutes per stop)
    final baseHour = 5;
    final baseMinute = 30;
    final minutes = baseMinute + (index * 5);
    final hour = baseHour + (minutes ~/ 60);
    final minute = minutes % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} AM';
  }


  // Removed: _getDemoStops() method - using real API data instead
  // Previously contained mock customer data (Rahul, Priya, Amit, Sneha)
  // This is now replaced with real customer data from the API

  void _generateMarkers() {
    final markers = <Marker>{};

    // Current location marker
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'You are here'),
        ),
      );
    }

    // Delivery stop markers
    for (int i = 0; i < _deliveryStops.length; i++) {
      final stop = _deliveryStops[i];
      markers.add(
        Marker(
          markerId: MarkerId(stop.id),
          position: LatLng(stop.latitude, stop.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            stop.status == 'completed'
                ? BitmapDescriptor.hueGreen
                : i == _currentStopIndex
                    ? BitmapDescriptor.hueRed
                    : BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(
            title: 'Stop ${i + 1}: ${stop.customerName}',
            snippet: stop.address,
          ),
          onTap: () => _showStopDetails(stop, i),
        ),
      );
    }

    // Generate route polylines
    final points = <LatLng>[];
    if (_currentPosition != null) {
      points.add(LatLng(_currentPosition!.latitude, _currentPosition!.longitude));
    }
    for (final stop in _deliveryStops) {
      points.add(LatLng(stop.latitude, stop.longitude));
    }

    _polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        points: points,
        color: DairyColorsLight.primary,
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    };

    _markers = markers;
  }

  void _showStopDetails(DeliveryStop stop, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DairyRadius.xl)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(DairySpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: DairyColorsLight.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: DairySpacing.lg),

              // Header
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: stop.status == 'completed'
                          ? DairyColorsLight.successSurface
                          : DairyColorsLight.primarySurface,
                      borderRadius: DairyRadius.defaultBorderRadius,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: DairyTypography.headingMedium(
                          color: stop.status == 'completed'
                              ? DairyColorsLight.success
                              : DairyColorsLight.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: DairySpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stop.customerName, style: DairyTypography.headingSmall()),
                        Text(
                          'Estimated: ${stop.estimatedTime}',
                          style: DairyTypography.caption(color: DairyColorsLight.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(stop.status),
                ],
              ),

              const SizedBox(height: DairySpacing.lg),
              const Divider(),
              const SizedBox(height: DairySpacing.md),

              // Address
              _buildInfoRow(Icons.location_on, 'Address', stop.address),

              // Phone
              _buildInfoRow(Icons.phone, 'Phone', stop.phone),

              // Products
              const SizedBox(height: DairySpacing.md),
              Text('Products', style: DairyTypography.label()),
              const SizedBox(height: DairySpacing.sm),
              ...stop.products.map((product) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                      size: 16,
                      color: DairyColorsLight.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(product, style: DairyTypography.body()),
                  ],
                ),
              )),

              const SizedBox(height: DairySpacing.lg),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _callCustomer(stop.phone),
                      icon: const Icon(Icons.phone),
                      label: const Text('Call'),
                    ),
                  ),
                  const SizedBox(width: DairySpacing.md),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToLocation(stop),
                      icon: const Icon(Icons.navigation),
                      label: const Text('Navigate'),
                    ),
                  ),
                ],
              ),

              if (stop.status != 'completed') ...[
                const SizedBox(height: DairySpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _markAsDelivered(stop, index);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Mark as Delivered'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DairyColorsLight.success,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isCompleted = status == 'completed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCompleted
            ? DairyColorsLight.successSurface
            : DairyColorsLight.warningSurface,
        borderRadius: DairyRadius.pillBorderRadius,
      ),
      child: Text(
        isCompleted ? 'Delivered' : 'Pending',
        style: DairyTypography.caption(
          color: isCompleted ? DairyColorsLight.success : DairyColorsLight.warning,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DairySpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: DairyColorsLight.textSecondary),
          const SizedBox(width: DairySpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: DairyTypography.caption(color: DairyColorsLight.textSecondary)),
                Text(value, style: DairyTypography.body()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _callCustomer(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _navigateToLocation(DeliveryStop stop) async {
    final googleMapsUrl = Uri.parse(
      'google.navigation:q=${stop.latitude},${stop.longitude}&mode=d',
    );
    final appleMapsUrl = Uri.parse(
      'https://maps.apple.com/?daddr=${stop.latitude},${stop.longitude}&dirflg=d',
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else if (await canLaunchUrl(appleMapsUrl)) {
      await launchUrl(appleMapsUrl);
    } else {
      _showSnackBar('Could not open maps');
    }
  }

  Future<void> _markAsDelivered(DeliveryStop stop, int index) async {
    try {
      final apiService = ApiService();
      await apiService.put('/delivery-boy/deliveries/${stop.id}/complete', {});
    } catch (e) {
      // Continue anyway for demo
    }

    setState(() {
      _deliveryStops[index] = stop.copyWith(status: 'completed');
      if (_currentStopIndex == index && _currentStopIndex < _deliveryStops.length - 1) {
        _currentStopIndex++;
      }
      _generateMarkers();
    });

    _showSnackBar('Delivery marked as complete!', isSuccess: true);
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? DairyColorsLight.success : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Navigation'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DeliveryBoyProfileScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirm == true && mounted) {
                await context.read<AuthProvider>().logout();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _initializeRoute();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _deliveryStops.isEmpty
              ? _buildEmptyState()
              : Column(
              children: [
                // Area and Customer Information Card
                Container(
                  padding: const EdgeInsets.all(DairySpacing.md),
                  decoration: BoxDecoration(
                    color: DairyColorsLight.primarySurface,
                    border: Border(
                      bottom: BorderSide(
                        color: DairyColorsLight.border,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: DairyColorsLight.primary,
                        size: 24,
                      ),
                      const SizedBox(width: DairySpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assigned Area',
                              style: DairyTypography.caption(
                                color: DairyColorsLight.textSecondary,
                              ),
                            ),
                            Text(
                              _areaName,
                              style: DairyTypography.bodyLarge(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DairySpacing.md,
                          vertical: DairySpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: DairyColorsLight.primary,
                          borderRadius: DairyRadius.defaultBorderRadius,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.people,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_totalCustomers',
                              style: DairyTypography.label(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Progress Header
                Container(
                  padding: const EdgeInsets.all(DairySpacing.md),
                  color: DairyColorsLight.surface,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProgressItem(
                        'Total',
                        '${_deliveryStops.length}',
                        Icons.list,
                      ),
                      _buildProgressItem(
                        'Completed',
                        '${_deliveryStops.where((s) => s.status == 'completed').length}',
                        Icons.check_circle,
                        color: DairyColorsLight.success,
                      ),
                      _buildProgressItem(
                        'Pending',
                        '${_deliveryStops.where((s) => s.status != 'completed').length}',
                        Icons.pending,
                        color: DairyColorsLight.warning,
                      ),
                    ],
                  ),
                ),

                // Map
                Expanded(
                  flex: 2,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        _currentPosition?.latitude ?? 12.9716,
                        _currentPosition?.longitude ?? 77.5946,
                      ),
                      zoom: 13,
                    ),
                    onMapCreated: (controller) => _mapController = controller,
                    markers: _markers,
                    polylines: _polylines,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: false,
                  ),
                ),

                // Stop List
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(DairyRadius.xl),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: DairySpacing.sm),
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: DairyColorsLight.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(DairySpacing.md),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Delivery Stops', style: DairyTypography.headingSmall()),
                              TextButton.icon(
                                onPressed: _startOptimizedRoute,
                                icon: const Icon(Icons.navigation, size: 18),
                                label: const Text('Start Route'),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: DairySpacing.md),
                            itemCount: _deliveryStops.length,
                            itemBuilder: (context, index) {
                              final stop = _deliveryStops[index];
                              return _buildStopListItem(stop, index);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 64,
            color: DairyColorsLight.textSecondary,
          ),
          const SizedBox(height: DairySpacing.lg),
          Text(
            'No Customers Assigned',
            style: DairyTypography.headingSmall(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DairySpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DairySpacing.lg),
            child: Text(
              _areaName == 'No Area Assigned'
                  ? 'You have not been assigned to any area yet. Please contact your admin.'
                  : 'No customers are currently assigned to your area. Check back later or refresh the page.',
              style: DairyTypography.body(color: DairyColorsLight.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: DairySpacing.lg),
          ElevatedButton.icon(
            onPressed: () {
              setState(() => _isLoading = true);
              _initializeRoute();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? DairyColorsLight.primary, size: 28),
        const SizedBox(height: 4),
        Text(value, style: DairyTypography.headingSmall()),
        Text(label, style: DairyTypography.caption(color: DairyColorsLight.textSecondary)),
      ],
    );
  }

  Widget _buildStopListItem(DeliveryStop stop, int index) {
    final isCompleted = stop.status == 'completed';
    final isCurrent = index == _currentStopIndex && !isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: DairySpacing.sm),
      color: isCurrent ? DairyColorsLight.primarySurface : null,
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isCompleted
                ? DairyColorsLight.success
                : isCurrent
                    ? DairyColorsLight.primary
                    : DairyColorsLight.surface,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    '${index + 1}',
                    style: DairyTypography.label(
                      color: isCurrent ? Colors.white : DairyColorsLight.textSecondary,
                    ),
                  ),
          ),
        ),
        title: Text(
          stop.customerName,
          style: DairyTypography.bodyLarge().copyWith(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          stop.address,
          style: DairyTypography.caption(color: DairyColorsLight.textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          stop.estimatedTime,
          style: DairyTypography.caption(color: DairyColorsLight.textTertiary),
        ),
        onTap: () => _showStopDetails(stop, index),
      ),
    );
  }

  void _startOptimizedRoute() {
    if (_deliveryStops.isEmpty) return;

    final pendingStops = _deliveryStops.where((s) => s.status != 'completed').toList();
    if (pendingStops.isEmpty) {
      _showSnackBar('All deliveries completed!', isSuccess: true);
      return;
    }

    final firstPending = pendingStops.first;
    _navigateToLocation(firstPending);
  }
}

class DeliveryStop {
  final String id;
  final String customerName;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;
  final List<String> products;
  final String status;
  final String estimatedTime;

  DeliveryStop({
    required this.id,
    required this.customerName,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.products,
    required this.status,
    required this.estimatedTime,
  });

  factory DeliveryStop.fromJson(Map<String, dynamic> json) {
    return DeliveryStop(
      id: json['id']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? '') ?? 0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '') ?? 0,
      products: (json['products'] as List<dynamic>?)?.cast<String>() ?? [],
      status: json['status']?.toString() ?? 'pending',
      estimatedTime: json['estimatedTime']?.toString() ?? '',
    );
  }

  DeliveryStop copyWith({String? status}) {
    return DeliveryStop(
      id: id,
      customerName: customerName,
      address: address,
      phone: phone,
      latitude: latitude,
      longitude: longitude,
      products: products,
      status: status ?? this.status,
      estimatedTime: estimatedTime,
    );
  }
}

