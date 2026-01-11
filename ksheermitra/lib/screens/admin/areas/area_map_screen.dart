import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../models/area.dart';
import '../../../providers/area_provider.dart';
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
    }
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
    _markers = _polygonPoints.asMap().entries.map((entry) {
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
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
    }).toSet();
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

    if (result == null) return;

    setState(() => _isSaving = true);

    final provider = context.read<AreaProvider>();
    final center = _calculateCenter(_polygonPoints);

    bool success;
    if (widget.area == null) {
      success = await provider.createArea(
        name: result['name'],
        description: result['description'],
        boundaries: _polygonPoints,
        centerLatitude: center.latitude,
        centerLongitude: center.longitude,
        deliveryBoyId: result['deliveryBoyId'],
      );
    } else {
      success = await provider.updateAreaBoundaries(
        id: widget.area!.id,
        boundaries: _polygonPoints,
        centerLatitude: center.latitude,
        centerLongitude: center.longitude,
      );
    }

    setState(() => _isSaving = false);

    if (mounted) {
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
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${provider.error ?? 'Failed to save area'}'),
            backgroundColor: Colors.red,
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
            onPressed: () => Navigator.pop(context, {}),
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
              Navigator.pop(context, {
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
