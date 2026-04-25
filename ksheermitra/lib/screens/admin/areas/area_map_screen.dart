import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../models/area.dart';
import '../../../models/user.dart';
import '../../../providers/area_provider.dart';
import '../../../services/admin_api_service.dart';
import '../../../config/theme.dart';
import '../../../widgets/premium_widgets.dart';

class AreaMapScreen extends StatefulWidget {
  final Area? area;

  const AreaMapScreen({super.key, this.area});

  @override
  State<AreaMapScreen> createState() => _AreaMapScreenState();
}

class _AreaMapScreenState extends State<AreaMapScreen> {
  GoogleMapController? _mapController;
  final List<LatLng> _polygonPoints = [];
  Set<Polygon> _polygons = {};
  Set<Marker> _markers = {};
  List<User> _customers = [];
  List<User> _customersInArea = [];
  bool _isLoadingCustomers = false;
  LatLng _center = const LatLng(20.5937, 78.9629); // India center
  bool _isDrawingMode = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.area?.boundaries != null && widget.area!.boundaries!.isNotEmpty) {
      _polygonPoints.addAll(widget.area!.boundaries!);
      _updatePolygon();
      _center = _calculateCenter(_polygonPoints);
      _isDrawingMode = false;
      // Load customers for editing view
      _loadCustomers();
    }
  }

  /// Check if a point is inside a polygon using ray casting algorithm
  bool _isPointInPolygon(LatLng point, List<LatLng> polygonPoints) {
    if (polygonPoints.length < 3) return false;
    
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

  /// Load all customers and find those in current area
  Future<void> _loadCustomers() async {
    setState(() => _isLoadingCustomers = true);

    try {
      final adminApi = AdminApiService();
      final allCustomers = await adminApi.getCustomersWithLocations();

      setState(() {
        _customers = allCustomers;
        _isLoadingCustomers = false;
      });

      // Update markers to show customers based on polygon detection
      _updateMarkersWithCustomers();
    } catch (e) {
      setState(() => _isLoadingCustomers = false);
      debugPrint('Error loading customers: $e');
    }
  }

  /// Update markers to include customer and boundary markers
  void _updateMarkersWithCustomers() {
    // Find customers inside the polygon based on coordinates
    if (_polygonPoints.length >= 3) {
      for (final customer in _customers) {
        if (customer.latitude != null && customer.longitude != null) {
          final customerPoint = LatLng(
            customer.latitude as double,
            customer.longitude as double,
          );
          
          final isInside = _isPointInPolygon(customerPoint, _polygonPoints);
          
          if (isInside) {
            // Customer is inside - yellow marker
            _markers.add(
              Marker(
                markerId: MarkerId('customer_assigned_${customer.id}'),
                position: customerPoint,
                infoWindow: InfoWindow(
                  title: customer.name ?? 'Customer',
                  snippet: '${customer.address} (Inside)',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
              ),
            );
          } else {
            // Customer is outside - blue marker
            _markers.add(
              Marker(
                markerId: MarkerId('customer_other_${customer.id}'),
                position: customerPoint,
                infoWindow: InfoWindow(
                  title: customer.name ?? 'Customer',
                  snippet: customer.address ?? customer.phone,
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              ),
            );
          }
        }
      }
    }

    setState(() {});
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
    if (_polygonPoints.length >= 3) {
      setState(() {
        _polygons = {
          Polygon(
            polygonId: const PolygonId('area_boundary'),
            points: _polygonPoints,
            strokeColor: AppTheme.primaryColor,
            strokeWidth: 3,
            fillColor: AppTheme.primaryColor.withValues(alpha: 0.2),
          ),
        };
        _updateMarkers();
      });
    }
  }

  void _updateMarkers() {
    final updatedMarkers = <Marker>{};

    // Create boundary point markers
    for (var i = 0; i < _polygonPoints.length; i++) {
      final entry = _polygonPoints[i];
      updatedMarkers.add(
        Marker(
          markerId: MarkerId('point_$i'),
          position: entry,
          draggable: true,
          onDragEnd: (newPosition) {
            setState(() {
              _polygonPoints[i] = newPosition;
              _updatePolygon();
            });
          },
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }

    // Add customer markers based on current polygon
    if (_polygonPoints.length >= 3 && _customers.isNotEmpty) {
      for (final customer in _customers) {
        if (customer.latitude != null && customer.longitude != null) {
          final customerPoint = LatLng(
            customer.latitude as double,
            customer.longitude as double,
          );
          
          final isInside = _isPointInPolygon(customerPoint, _polygonPoints);
          
          if (isInside) {
            // Customer is inside - yellow marker
            updatedMarkers.add(
              Marker(
                markerId: MarkerId('customer_assigned_${customer.id}'),
                position: customerPoint,
                infoWindow: InfoWindow(
                  title: customer.name ?? 'Customer',
                  snippet: '${customer.address} (Inside)',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
              ),
            );
          } else {
            // Customer is outside - blue marker
            updatedMarkers.add(
              Marker(
                markerId: MarkerId('customer_other_${customer.id}'),
                position: customerPoint,
                infoWindow: InfoWindow(
                  title: customer.name ?? 'Customer',
                  snippet: customer.address ?? customer.phone,
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              ),
            );
          }
        }
      }
    }

    // Replace all markers
    _markers = updatedMarkers;
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
      _markers.clear();
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
      builder: (context) => _AreaDetailsDialog(area: widget.area),
    );

    // Handle null result (cancelled)
    if (result == null) return;

    // Validate result is a Map and cast properly
    final Map<String, dynamic> resultData = Map<String, dynamic>.from(result);

    setState(() => _isSaving = true);

    final provider = context.read<AreaProvider>();
    final center = _calculateCenter(_polygonPoints);

    bool success;
    if (widget.area == null) {
      // Creating new area - result has name, description, deliveryBoyId
      success = await provider.createArea(
        name: resultData['name'] as String? ?? 'Area',
        description: resultData['description'] as String?,
        boundaries: _polygonPoints,
        centerLatitude: center.latitude,
        centerLongitude: center.longitude,
        deliveryBoyId: resultData['deliveryBoyId'] as String?,
      );
    } else {
      // Editing existing area - just update boundaries
      success = await provider.updateAreaBoundaries(
        id: widget.area!.id,
        boundaries: _polygonPoints,
        centerLatitude: center.latitude,
        centerLongitude: center.longitude,
      );
    }

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.area == null
                ? 'Area created successfully'
                : 'Area boundaries updated successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
      // Pop the screen outside of any async operations
      if (mounted && context.mounted) {
        Navigator.pop(context, true);
      }
    } else {
      // Show error dialog with retry option for network errors
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
        title: widget.area == null ? 'Draw Area Boundary' : 'Edit Area Boundary',
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
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 14,
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

           // Legend for markers (when editing area)
           if (widget.area != null)
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
                               color: Colors.yellow,
                               shape: BoxShape.circle,
                             ),
                           ),
                           const SizedBox(width: 8),
                           Expanded(
                             child: Text(
                               'Assigned (${_customersInArea.length})',
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
                               color: Colors.blue,
                               shape: BoxShape.circle,
                             ),
                           ),
                           const SizedBox(width: 8),
                           Expanded(
                             child: Text(
                               'Other (${_customers.length - _customersInArea.length})',
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
                               color: Colors.green,
                               shape: BoxShape.circle,
                             ),
                           ),
                           const SizedBox(width: 8),
                           const Expanded(
                             child: Text(
                               'Boundary Points',
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
              top: 90,
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
          if (_polygonPoints.length >= 3)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : PremiumButton(
                      text: widget.area == null ? 'Save Area' : 'Update Boundaries',
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
    if (widget.area != null) {
      // Just confirm for existing area
      return AlertDialog(
        title: const Text('Update Boundaries'),
        content: const Text('Save the new boundary for this area?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          PremiumButton(
            text: 'Update',
            onPressed: () => Navigator.pop(context, <String, dynamic>{}),
            height: 40,
          ),
        ],
      );
    }

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
