import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../models/area.dart';
import '../../../models/user.dart';
import '../../../config/app_config.dart';
import '../../../config/theme.dart';
import '../../../providers/area_provider.dart';
import '../../../services/admin_api_service.dart';
import '../../../widgets/premium_widgets.dart';

class AddAreaWithCustomersMapScreen extends StatefulWidget {
  const AddAreaWithCustomersMapScreen({super.key});

  @override
  State<AddAreaWithCustomersMapScreen> createState() =>
      _AddAreaWithCustomersMapScreenState();
}

class _AddAreaWithCustomersMapScreenState
    extends State<AddAreaWithCustomersMapScreen> {
  GoogleMapController? _mapController;
  final List<LatLng> _polygonPoints = [];
  Set<Polygon> _polygons = {};
  Set<Marker> _markers = {};
  List<User> _customers = [];
  List<Area> _previousAreas = [];
  bool _isDrawingMode = true;
  bool _isSaving = false;
  bool _isLoadingCustomers = true;
  String? _loadError;

  LatLng _center = const LatLng(20.5937, 78.9629); // India center
  late LatLng _defaultLocation;

  @override
  void initState() {
    super.initState();
    _defaultLocation = LatLng(
      AppConfig.defaultLatitude,
      AppConfig.defaultLongitude,
    );
    _loadCustomerLocations();
    _loadPreviousAreas();
  }

  /// Load previously created areas
  Future<void> _loadPreviousAreas() async {
    try {
      final provider = context.read<AreaProvider>();
      _previousAreas = provider.areas;
      
      // Display existing areas as blocked polygons
      _displayPreviousAreas();
    } catch (e) {
      debugPrint('Error loading previous areas: $e');
    }
  }

  /// Display previous areas as grayed-out polygons
  void _displayPreviousAreas() {
    for (final area in _previousAreas) {
      if (area.boundaries != null && area.boundaries!.length >= 3) {
        _polygons.add(
          Polygon(
            polygonId: PolygonId('previous_area_${area.id}'),
            points: area.boundaries!,
            strokeColor: Colors.grey.withValues(alpha: 0.5),
            strokeWidth: 2,
            fillColor: Colors.grey.withValues(alpha: 0.1),
            geodesic: false,
          ),
        );
      }
    }

    setState(() {});
  }

  Future<void> _loadCustomerLocations() async {
    setState(() {
      _isLoadingCustomers = true;
      _loadError = null;
    });

    try {
      final adminApi = AdminApiService();
      _customers = await adminApi.getCustomersWithLocations();

      setState(() {
        _isLoadingCustomers = false;
      });

      // Set center to first customer or default location
      if (_customers.isNotEmpty) {
        final first = _customers.first;
        if (first.latitude != null && first.longitude != null) {
          _center =
              LatLng(first.latitude as double, first.longitude as double);
          if (mounted && _mapController != null) {
            _mapController!.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: _center, zoom: 14),
              ),
            );
          }
        }
      } else {
        _center = _defaultLocation;
      }

      _updateCustomerMarkers();
      _updateDefaultLocationMarker();
    } catch (e) {
      setState(() {
        _isLoadingCustomers = false;
        _loadError = 'Failed to load customer locations: ${e.toString()}';
      });
      debugPrint('Error loading customers: $e');
    }
  }

  void _updateCustomerMarkers() {
    final customerMarkers = _customers
        .where((c) => c.latitude != null && c.longitude != null)
        .map((customer) {
      return Marker(
        markerId: MarkerId('customer_${customer.id}'),
        position: LatLng(customer.latitude as double, customer.longitude as double),
        infoWindow: InfoWindow(
          title: customer.name ?? 'Customer',
          snippet: customer.address ?? customer.phone,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
    }).toSet();

    _markers = {...customerMarkers};
  }

  void _updateDefaultLocationMarker() {
    _markers.add(
      Marker(
        markerId: const MarkerId('default_location'),
        position: _defaultLocation,
        infoWindow: const InfoWindow(
          title: 'Default Location',
          snippet: 'Default delivery center location',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
  }

  LatLng _calculateCenter(List<LatLng> points) {
    if (points.isEmpty) return _center;
    double lat = 0, lng = 0;
    for (var point in points) {
      lat += point.latitude;
      lng += point.longitude;
    }
    return LatLng(lat / points.length, lng / points.length);
  }

  void _updatePolygon() {
    final updatedPolygons = <Polygon>{};

    // Add previous areas as grayed-out polygons
    for (final area in _previousAreas) {
      if (area.boundaries != null && area.boundaries!.length >= 3) {
        updatedPolygons.add(
          Polygon(
            polygonId: PolygonId('previous_area_${area.id}'),
            points: area.boundaries!,
            strokeColor: Colors.grey.withValues(alpha: 0.5),
            strokeWidth: 2,
            fillColor: Colors.grey.withValues(alpha: 0.1),
            geodesic: false,
          ),
        );
      }
    }

    // Add current area being drawn
    if (_polygonPoints.length >= 3) {
      updatedPolygons.add(
        Polygon(
          polygonId: const PolygonId('area_boundary'),
          points: _polygonPoints,
          strokeColor: AppTheme.primaryColor,
          strokeWidth: 3,
          fillColor: AppTheme.primaryColor.withValues(alpha: 0.2),
        ),
      );
    }

    setState(() {
      _polygons = updatedPolygons;
      _updatePolygonMarkers();
    });
  }

  void _updatePolygonMarkers() {
    final polygonMarkers = _polygonPoints.asMap().entries.map((entry) {
      return Marker(
        markerId: MarkerId('point_${entry.key}'),
        position: entry.value,
        draggable: true,
        onDragEnd: (newPosition) {
          setState(() {
            _polygonPoints[entry.key] = newPosition;
            _updatePolygon();
          });
        },
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );
    }).toSet();

    _markers = {
      ..._markers.where((m) => m.markerId.value.startsWith('customer_') ||
          m.markerId.value == 'default_location'),
      ...polygonMarkers,
    };
  }

  void _onMapTap(LatLng position) {
    if (_isDrawingMode) {
      setState(() {
        _polygonPoints.add(position);
        _updatePolygon();
      });
    }
  }

  void _clearPolygon() {
    setState(() {
      _polygonPoints.clear();
      _polygons.clear();
      _updateCustomerMarkers();
      _updateDefaultLocationMarker();
    });
  }

  void _undoLastPoint() {
    if (_polygonPoints.isNotEmpty) {
      setState(() {
        _polygonPoints.removeLast();
        _updatePolygon();
      });
    }
  }

  /// Check if a point is inside a polygon using ray casting algorithm
  bool _isPointInPolygon(LatLng point, List<LatLng> polygonPoints) {
    int count = 0;
    for (int i = 0; i < polygonPoints.length; i++) {
      LatLng p1 = polygonPoints[i];
      LatLng p2 = polygonPoints[(i + 1) % polygonPoints.length];

      if ((p1.longitude <= point.longitude && point.longitude < p2.longitude ||
              p2.longitude <= point.longitude && point.longitude < p1.longitude) &&
          point.latitude <
              (p2.latitude - p1.latitude) *
                      (point.longitude - p1.longitude) /
                      (p2.longitude - p1.longitude) +
                  p1.latitude) {
        count++;
      }
    }
    return count % 2 == 1;
  }

  /// Get customers within the drawn polygon
  List<String> _getCustomersInArea(List<LatLng> polygonPoints) {
    final customersInArea = <String>[];

    for (final customer in _customers) {
      if (customer.latitude != null && customer.longitude != null) {
        final customerPoint = LatLng(
          customer.latitude as double,
          customer.longitude as double,
        );

        if (_isPointInPolygon(customerPoint, polygonPoints)) {
          customersInArea.add(customer.id);
        }
      }
    }

    return customersInArea;
  }

  Future<void> _saveArea() async {
    if (_polygonPoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please draw at least 3 points to create an area'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show dialog to get area name
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AreaDetailsDialog(area: null),
    );

    // Handle null result (cancelled)
    if (result == null) return;

    // Validate result is a Map and cast properly
    final Map<String, dynamic> resultData = Map<String, dynamic>.from(result);

    setState(() => _isSaving = true);

    final provider = context.read<AreaProvider>();
    final center = _calculateCenter(_polygonPoints);

    bool success = await provider.createArea(
      name: resultData['name'] as String? ?? 'Area',
      description: resultData['description'] as String?,
      boundaries: _polygonPoints,
      centerLatitude: center.latitude,
      centerLongitude: center.longitude,
      deliveryBoyId: resultData['deliveryBoyId'] as String?,
    );

    if (!mounted) return;

    if (success) {
      // Get the created area (it's the last one added to the provider)
      final createdArea = provider.areas.isNotEmpty ? provider.areas.last : null;

      // Find and assign customers within the drawn area
      if (createdArea != null) {
        final customersInArea = _getCustomersInArea(_polygonPoints);

        if (customersInArea.isNotEmpty) {
          // Bulk assign customers to the area
          final assignSuccess = await provider.bulkAssignArea(
            customerIds: customersInArea,
            areaId: createdArea.id,
          );

          if (assignSuccess && mounted) {
            // Reload areas to get updated customer counts
            await provider.loadAreas();
          }
        }
      }
    }

    setState(() => _isSaving = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Area created successfully with customers assigned'),
          backgroundColor: Colors.green,
        ),
      );
      // Pop the screen
      if (mounted && context.mounted) {
        Navigator.pop(context, true);
      }
    } else {
      // Show error dialog
      final error = provider.error ?? 'Failed to save area';
      final isNetworkError = error.contains('Connection') ||
          error.contains('Network') ||
          error.contains('timeout');

      if (mounted && context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: !isNetworkError,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(error),
            actions: [
              if (!isNetworkError)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              if (isNetworkError) ...[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _saveArea(); // Retry
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PremiumAppBar(
        title: 'Add Area - View Customers',
        actions: [
          if (_polygonPoints.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: _undoLastPoint,
              tooltip: 'Undo last point',
            ),
          if (_polygonPoints.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Polygon'),
                    content: const Text('Are you sure you want to clear all points?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      PremiumButton(
                        text: 'Clear',
                        onPressed: () => Navigator.pop(context, true),
                        height: 40,
                      ),
                    ],
                  ),
                );
                if (confirm == true) _clearPolygon();
              },
              tooltip: 'Clear all',
            ),
          IconButton(
            icon: Icon(_isDrawingMode ? Icons.pan_tool : Icons.edit),
            onPressed: () {
              setState(() => _isDrawingMode = !_isDrawingMode);
            },
            tooltip: _isDrawingMode ? 'Pan mode' : 'Drawing mode',
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_isLoadingCustomers)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Loading customer locations...'),
                  if (_loadError != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _loadError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadCustomerLocations,
                      child: const Text('Retry'),
                    ),
                  ]
                ],
              ),
            )
          else
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: AppConfig.mapZoom,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              onTap: _onMapTap,
              polygons: _polygons,
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
            ),

          // Instructions banner
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: PremiumCard(
              gradient: AppTheme.premiumCardGradient,
              shadows: AppTheme.premiumCardShadow,
              child: Row(
                children: [
                  Icon(
                    _isDrawingMode ? Icons.touch_app : Icons.pan_tool,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isDrawingMode
                          ? 'Tap on map to add points. Need at least 3 points.'
                          : 'Pan mode: Drag markers to adjust boundary',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Legend for markers
          Positioned(
            top: 90,
            left: 16,
            right: 16,
            child: PremiumCard(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Customers (${_customers.length})',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Default Location',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Area Points',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Points counter
          if (_polygonPoints.isNotEmpty)
            Positioned(
              top: 200,
              left: 16,
              child: PremiumCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    '${_polygonPoints.length} points',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

          // Save button
          if (_polygonPoints.length >= 3 && !_isLoadingCustomers)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : PremiumButton(
                      text: 'Save Area',
                      icon: Icons.save,
                      onPressed: _saveArea,
                      width: double.infinity,
                    ),
            ),
        ],
      ),
    );
  }
}

class _AreaDetailsDialog extends StatefulWidget {
  final Area? area;

  const _AreaDetailsDialog({this.area});

  @override
  State<_AreaDetailsDialog> createState() => _AreaDetailsDialogState();
}

class _AreaDetailsDialogState extends State<_AreaDetailsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedDeliveryBoyId;

  @override
  void initState() {
    super.initState();
    if (widget.area != null) {
      _nameController.text = widget.area!.name;
      _descriptionController.text = widget.area!.description ?? '';
      _selectedDeliveryBoyId = widget.area!.deliveryBoyId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Area Details'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Area Name *',
                  prefixIcon: Icon(Icons.map),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter area name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        PremiumButton(
          text: 'Save',
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, <String, dynamic>{
                'name': _nameController.text.trim(),
                'description': _descriptionController.text.trim(),
                'deliveryBoyId': _selectedDeliveryBoyId,
              });
            }
          },
          height: 40,
        ),
      ],
    );
  }
}


