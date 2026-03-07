import 'package:flutter/material.dart';
import '../../config/dairy_theme.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/delivery_models.dart';
import '../../services/delivery_service.dart';
import 'customer_detail_screen.dart';
import 'daily_summary_screen.dart';
import 'dart:async';

class DeliveryMapScreen extends StatefulWidget {
  const DeliveryMapScreen({Key? key}) : super(key: key);

  @override
  State<DeliveryMapScreen> createState() => _DeliveryMapScreenState();
}

class _DeliveryMapScreenState extends State<DeliveryMapScreen> {
  final DeliveryService _deliveryService = DeliveryService();
  GoogleMapController? _mapController;

  Area? _area;
  List<Customer> _customers = [];
  Set<Polygon> _polygons = {};
  Set<Marker> _markers = {};
  DeliveryStats? _stats;

  bool _isLoading = true;
  String? _errorMessage;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadDeliveryMap();
    // Auto-refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadDeliveryMap(silent: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadDeliveryMap({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final mapData = await _deliveryService.getDeliveryMap();
      final stats = await _deliveryService.getDeliveryStats();

      final areaData = mapData['data']['area'];
      final customersData = mapData['data']['customers'] as List;

      final area = Area.fromJson(areaData);
      final customers = customersData.map((c) => Customer.fromJson(c)).toList();

      setState(() {
        _area = area;
        _customers = customers;
        _stats = stats;
        _isLoading = false;
        _updateMapElements();
      });
    } catch (e) {
      if (!silent) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _updateMapElements() {
    // Add area boundary polygon
    if (_area?.boundaries != null && _area!.boundaries!.isNotEmpty) {
      final polygonPoints = _area!.boundaries!
          .map((point) => LatLng(point.lat, point.lng))
          .toList();

      _polygons = {
        Polygon(
          polygonId: PolygonId(_area!.id),
          points: polygonPoints,
          strokeColor: Colors.blue,
          strokeWidth: 3,
          fillColor: Colors.blue.withOpacity(0.1),
        ),
      };
    }

    // Add customer markers with color coding
    _markers = _customers
        .where((c) => c.latitude != null && c.longitude != null)
        .map((customer) {
      BitmapDescriptor markerColor;

      // Color coding based on delivery status
      switch (customer.deliveryStatus) {
        case 'delivered':
          markerColor = BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen, // Green for delivered
          );
          break;
        case 'missed':
          markerColor = BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed, // Red for missed
          );
          break;
        default:
          markerColor = BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue, // Blue for pending
          );
      }

      return Marker(
        markerId: MarkerId(customer.id),
        position: LatLng(customer.latitude!, customer.longitude!),
        icon: markerColor,
        infoWindow: InfoWindow(
          title: customer.name,
          snippet: 'Tap for details',
        ),
        onTap: () => _showCustomerBottomSheet(customer),
      );
    }).toSet();

    // Move camera to center of area
    if (_area?.centerLatitude != null && _area?.centerLongitude != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_area!.centerLatitude!, _area!.centerLongitude!),
          13,
        ),
      );
    }
  }

  void _showCustomerBottomSheet(Customer customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
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
                  const SizedBox(height: 20),

                  // Customer name and status
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: _getStatusColor(customer.deliveryStatus),
                        child: Text(
                          customer.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildStatusChip(customer.deliveryStatus),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Address
                  _buildInfoCard(
                    Icons.location_on,
                    'Address',
                    customer.address ?? 'No address',
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),

                  // Phone
                  _buildInfoCard(
                    Icons.phone,
                    'Phone',
                    customer.phone,
                    Colors.green,
                  ),
                  const SizedBox(height: 20),

                  // Subscriptions
                  if (customer.subscriptions != null &&
                      customer.subscriptions!.isNotEmpty) ...[
                    const Text(
                      'Today\'s Subscriptions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...customer.subscriptions!.expand<Widget>((subscription) {
                      return subscription.products?.map<Widget>((sp) {
                        final product = sp.product;
                        if (product == null) return const SizedBox.shrink();

                        final amount = sp.quantity * product.pricePerUnit;
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange[100],
                              child: Text(
                                _getProductEmoji(product.name),
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                            title: Text(
                              product.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${sp.quantity} ${product.unit} @ ₹${product.pricePerUnit}/${product.unit}',
                            ),
                            trailing: Text(
                              '₹${amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        );
                      }).toList() ?? <Widget>[];
                    }),
                    const Divider(height: 32),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(DairyRadius.md),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Today',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₹${customer.todayAmount?.toStringAsFixed(2) ?? '0.00'}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: customer.deliveryStatus == 'pending'
                              ? () {
                                  Navigator.pop(context);
                                  _navigateToCustomerDetail(customer);
                                }
                              : null,
                          icon: const Icon(Icons.info),
                          label: const Text('View Details'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: DairyColorsLight.textSecondary,
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
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DairyRadius.md),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'delivered':
        return Colors.green;
      case 'missed':
        return Colors.red;
      default:
        return Colors.blue;
    }
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

  void _navigateToCustomerDetail(Customer customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerDetailScreen(customer: customer),
      ),
    ).then((_) => _loadDeliveryMap(silent: true));
  }

  void _navigateToSummary() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DailySummaryScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Delivery Map'),
            if (_area != null)
              Text(
                _area!.name,
                style: const TextStyle(fontSize: 14),
              ),
          ],
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDeliveryMap,
          ),
          IconButton(
            icon: const Icon(Icons.summarize),
            onPressed: _navigateToSummary,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _loadDeliveryMap,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Area Information Card
                    if (_area != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.blue[200]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.blue[700],
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Assigned Area',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _area!.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[700],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.people,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_customers.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Map and overlays
                    Expanded(
                      child: Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: const CameraPosition(
                              target: LatLng(17.385044, 78.486671),
                              zoom: 12,
                            ),
                            onMapCreated: (controller) {
                              _mapController = controller;
                              _updateMapElements();
                            },
                            polygons: _polygons,
                            markers: _markers,
                            myLocationButtonEnabled: true,
                            myLocationEnabled: true,
                            zoomControlsEnabled: true,
                            compassEnabled: true,
                          ),

                          // Stats overlay
                          if (_stats != null)
                            Positioned(
                              top: 16,
                              left: 16,
                              right: 16,
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(DairyRadius.md),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildStatItem(
                                        'Pending',
                                        _stats!.pending.toString(),
                                        Colors.blue,
                                      ),
                                      Container(
                                        width: 1,
                                        height: 30,
                                        color: DairyColorsLight.border,
                                      ),
                                      _buildStatItem(
                                        'Delivered',
                                        _stats!.delivered.toString(),
                                        Colors.green,
                                      ),
                                      Container(
                                        width: 1,
                                        height: 30,
                                        color: DairyColorsLight.border,
                                      ),
                                      _buildStatItem(
                                        'Missed',
                                        _stats!.missed.toString(),
                                        Colors.red,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          // Legend
                          Positioned(
                            bottom: 16,
                            left: 16,
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(DairyRadius.md),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Status',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildLegendItem('🔵', 'Pending'),
                                    _buildLegendItem('🟢', 'Delivered'),
                                    _buildLegendItem('🔴', 'Missed'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: DairyColorsLight.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String emoji, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
