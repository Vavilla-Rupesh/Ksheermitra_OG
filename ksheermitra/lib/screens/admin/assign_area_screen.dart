import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/delivery_models.dart';
import '../../services/delivery_service.dart';

class AssignAreaScreen extends StatefulWidget {
  final DeliveryBoy deliveryBoy;

  const AssignAreaScreen({Key? key, required this.deliveryBoy})
      : super(key: key);

  @override
  State<AssignAreaScreen> createState() => _AssignAreaScreenState();
}

class _AssignAreaScreenState extends State<AssignAreaScreen> {
  final DeliveryService _deliveryService = DeliveryService();
  List<Area> _areas = [];
  Area? _selectedArea;
  bool _isLoading = true;
  bool _isSaving = false;
  GoogleMapController? _mapController;
  Set<Polygon> _polygons = {};
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  Future<void> _loadAreas() async {
    setState(() => _isLoading = true);

    try {
      final areas = await _deliveryService.getAllAreas();
      setState(() {
        _areas = areas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading areas: $e')),
        );
      }
    }
  }

  void _onAreaSelected(Area? area) {
    setState(() {
      _selectedArea = area;
      _updateMap();
    });
  }

  void _updateMap() {
    if (_selectedArea == null) {
      setState(() {
        _polygons.clear();
        _markers.clear();
      });
      return;
    }

    // Add polygon if boundaries exist
    if (_selectedArea!.boundaries != null &&
        _selectedArea!.boundaries!.isNotEmpty) {
      final polygonPoints = _selectedArea!.boundaries!
          .map((point) => LatLng(point.lat, point.lng))
          .toList();

      setState(() {
        _polygons = {
          Polygon(
            polygonId: PolygonId(_selectedArea!.id),
            points: polygonPoints,
            strokeColor: Colors.blue,
            strokeWidth: 2,
            fillColor: Colors.blue.withOpacity(0.2),
          ),
        };
      });

      // Move camera to center
      if (_selectedArea!.centerLatitude != null &&
          _selectedArea!.centerLongitude != null) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(
              _selectedArea!.centerLatitude!,
              _selectedArea!.centerLongitude!,
            ),
            13,
          ),
        );
      }
    }

    // Add customers as markers
    if (_selectedArea!.customers != null) {
      final customerMarkers = _selectedArea!.customers!
          .where((c) => c.latitude != null && c.longitude != null)
          .map((customer) => Marker(
                markerId: MarkerId(customer.id),
                position: LatLng(customer.latitude!, customer.longitude!),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueOrange,
                ),
                infoWindow: InfoWindow(
                  title: customer.name,
                  snippet: customer.address,
                ),
              ))
          .toSet();

      setState(() {
        _markers = customerMarkers;
      });
    }
  }

  Future<void> _assignArea() async {
    if (_selectedArea == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an area'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _deliveryService.assignAreaToDeliveryBoy(
        areaId: _selectedArea!.id,
        deliveryBoyId: widget.deliveryBoy.id,
        boundaries: _selectedArea!.boundaries,
        centerLatitude: _selectedArea!.centerLatitude,
        centerLongitude: _selectedArea!.centerLongitude,
        mapLink: _selectedArea!.mapLink,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Area assigned successfully! WhatsApp notification sent.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Area to ${widget.deliveryBoy.name}'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Area dropdown
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Select Area',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Area>(
                        value: _selectedArea,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.map),
                        ),
                        hint: const Text('Choose an area'),
                        items: _areas.map((area) {
                          return DropdownMenuItem<Area>(
                            value: area,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  area.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (area.customers != null)
                                  Text(
                                    '${area.customers!.length} customers',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: _onAreaSelected,
                      ),
                      if (_selectedArea != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.info, size: 16, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedArea!.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_selectedArea!.description != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _selectedArea!.description!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_selectedArea!.customers?.length ?? 0} customers in this area',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Map
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(17.385044, 78.486671),
                      zoom: 12,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                      _updateMap();
                    },
                    polygons: _polygons,
                    markers: _markers,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: true,
                  ),
                ),

                // Assign button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _assignArea,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Assign Area & Send Notification',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}

