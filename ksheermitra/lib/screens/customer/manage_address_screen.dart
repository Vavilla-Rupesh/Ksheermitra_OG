import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../config/dairy_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/customer_api_service.dart';
import '../../widgets/premium_widgets.dart';

class ManageAddressScreen extends StatefulWidget {
  const ManageAddressScreen({super.key});

  @override
  State<ManageAddressScreen> createState() => _ManageAddressScreenState();
}

class _ManageAddressScreenState extends State<ManageAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();

  final CustomerApiService _apiService = CustomerApiService();
  bool _isLoading = false;
  bool _isDetectingLocation = false;
  double? _latitude;
  double? _longitude;
  String _addressType = 'home';

  @override
  void initState() {
    super.initState();
    _loadCurrentAddress();
  }

  void _loadCurrentAddress() {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _addressController.text = user.address ?? '';
      _latitude = user.latitude;
      _longitude = user.longitude;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _detectCurrentLocation() async {
    setState(() => _isDetectingLocation = true);

    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied. Please enable from settings.');
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      // Get address from coordinates
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = [
          place.street,
          place.subLocality,
          place.locality,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        setState(() {
          _addressController.text = address;
          _cityController.text = place.locality ?? '';
          _pincodeController.text = place.postalCode ?? '';
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location detected successfully!'),
          backgroundColor: DairyColorsLight.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: DairyColorsLight.error,
        ),
      );
    } finally {
      setState(() => _isDetectingLocation = false);
    }
  }

  Future<void> _openMapPicker() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are required to use map picker'),
              backgroundColor: DairyColorsLight.error,
            ),
          );
        }
        return;
      }

      if (mounted) {
        final result = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(
            builder: (context) => MapPickerScreen(
              initialLatitude: _latitude,
              initialLongitude: _longitude,
            ),
          ),
        );

        if (result != null) {
          _latitude = result['latitude'] as double;
          _longitude = result['longitude'] as double;

          // Get address from coordinates
          try {
            final placemarks = await placemarkFromCoordinates(
              _latitude!,
              _longitude!,
            );

            if (placemarks.isNotEmpty) {
              final place = placemarks.first;
              final address = [
                place.street,
                place.subLocality,
                place.locality,
              ].where((e) => e != null && e.isNotEmpty).join(', ');

              setState(() {
                _addressController.text = address;
                _cityController.text = place.locality ?? '';
                _pincodeController.text = place.postalCode ?? '';
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Location selected from map!'),
                  backgroundColor: DairyColorsLight.success,
                ),
              );
            }
          } catch (e) {
            debugPrint('Error getting address from coordinates: $e');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: DairyColorsLight.error,
          ),
        );
      }
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final fullAddress = [
        _addressController.text.trim(),
        if (_landmarkController.text.isNotEmpty) 'Near ${_landmarkController.text.trim()}',
        if (_cityController.text.isNotEmpty) _cityController.text.trim(),
        if (_pincodeController.text.isNotEmpty) '- ${_pincodeController.text.trim()}',
      ].join(', ');

      // Use CustomerApiService to update profile with coordinates
      await _apiService.updateProfile(
        address: fullAddress,
        latitude: _latitude,
        longitude: _longitude,
      );

      if (mounted) {
        // Reload user data in auth provider
        await context.read<AuthProvider>().loadUser();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address saved successfully!'),
            backgroundColor: DairyColorsLight.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving address: $e'),
            backgroundColor: DairyColorsLight.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Address'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DairySpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Detect Location Button
              Card(
                child: InkWell(
                  onTap: _isDetectingLocation ? null : _detectCurrentLocation,
                  borderRadius: DairyRadius.defaultBorderRadius,
                  child: Padding(
                    padding: const EdgeInsets.all(DairySpacing.md),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: DairyColorsLight.primarySurface,
                            borderRadius: DairyRadius.defaultBorderRadius,
                          ),
                          child: _isDetectingLocation
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: DairyColorsLight.primary,
                                  ),
                                )
                              : const Icon(
                                  Icons.my_location,
                                  color: DairyColorsLight.primary,
                                ),
                        ),
                        const SizedBox(width: DairySpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Use Current Location',
                                style: DairyTypography.bodyLarge().copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Automatically detect your address',
                                style: DairyTypography.caption(
                                  color: DairyColorsLight.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: DairySpacing.md),

              // Map Picker Button
              Card(
                child: InkWell(
                  onTap: _openMapPicker,
                  borderRadius: DairyRadius.defaultBorderRadius,
                  child: Padding(
                    padding: const EdgeInsets.all(DairySpacing.md),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: DairyRadius.defaultBorderRadius,
                          ),
                          child: const Icon(
                            Icons.map,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: DairySpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Choose on Map',
                                style: DairyTypography.bodyLarge().copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Select your location from map',
                                style: DairyTypography.caption(
                                  color: DairyColorsLight.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: DairySpacing.lg),

              // Address Type Selection
              Text(
                'Address Type',
                style: DairyTypography.label(),
              ),
              const SizedBox(height: DairySpacing.sm),
              Row(
                children: [
                  _buildAddressTypeChip('home', 'Home', Icons.home),
                  const SizedBox(width: DairySpacing.sm),
                  _buildAddressTypeChip('work', 'Work', Icons.work),
                  const SizedBox(width: DairySpacing.sm),
                  _buildAddressTypeChip('other', 'Other', Icons.location_on),
                ],
              ),

              const SizedBox(height: DairySpacing.lg),

              // Address Field
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Full Address *',
                  hintText: 'House/Flat No., Street, Area',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your address';
                  }
                  if (value.trim().length < 10) {
                    return 'Please enter a complete address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: DairySpacing.md),

              // Landmark Field
              TextFormField(
                controller: _landmarkController,
                decoration: const InputDecoration(
                  labelText: 'Landmark (Optional)',
                  hintText: 'Near school, temple, etc.',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
              ),

              const SizedBox(height: DairySpacing.md),

              // City and Pincode
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        hintText: 'Enter city',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                    ),
                  ),
                  const SizedBox(width: DairySpacing.md),
                  SizedBox(
                    width: 140,
                    child: TextFormField(
                      controller: _pincodeController,
                      decoration: const InputDecoration(
                        labelText: 'Pincode',
                        hintText: '000000',
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: DairySpacing.md),

              // Location Info
              if (_latitude != null && _longitude != null)
                Container(
                  padding: const EdgeInsets.all(DairySpacing.md),
                  decoration: BoxDecoration(
                    color: DairyColorsLight.successSurface,
                    borderRadius: DairyRadius.defaultBorderRadius,
                    border: Border.all(color: DairyColorsLight.success.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: DairyColorsLight.success,
                        size: 20,
                      ),
                      const SizedBox(width: DairySpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Location Coordinates Saved',
                              style: DairyTypography.label(color: DairyColorsLight.success),
                            ),
                            Text(
                              'Lat: ${_latitude!.toStringAsFixed(4)}, Lng: ${_longitude!.toStringAsFixed(4)}',
                              style: DairyTypography.caption(color: DairyColorsLight.success),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: DairySpacing.xl),

              // Delivery Note
              Container(
                padding: const EdgeInsets.all(DairySpacing.md),
                decoration: BoxDecoration(
                  color: DairyColorsLight.infoSurface,
                  borderRadius: DairyRadius.defaultBorderRadius,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: DairyColorsLight.info,
                      size: 20,
                    ),
                    const SizedBox(width: DairySpacing.sm),
                    Expanded(
                      child: Text(
                        'This address will be used for all your deliveries. Make sure it\'s accurate for timely delivery.',
                        style: DairyTypography.caption(color: DairyColorsLight.info),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: DairySpacing.xl),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveAddress,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Address'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressTypeChip(String type, String label, IconData icon) {
    final isSelected = _addressType == type;
    return GestureDetector(
      onTap: () => setState(() => _addressType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DairySpacing.md,
          vertical: DairySpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? DairyColorsLight.primary : DairyColorsLight.surface,
          borderRadius: DairyRadius.pillBorderRadius,
          border: Border.all(
            color: isSelected ? DairyColorsLight.primary : DairyColorsLight.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : DairyColorsLight.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: DairyTypography.label(
                color: isSelected ? Colors.white : DairyColorsLight.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// MAP PICKER SCREEN
// ============================================================================

class MapPickerScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const MapPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _mapController;
  late LatLng _selectedLocation;
  Set<Marker> _markers = {};
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    // Initialize with provided location or default to Bangalore
    _selectedLocation = LatLng(
      widget.initialLatitude ?? 12.9716,
      widget.initialLongitude ?? 77.5946,
    );
    _updateMarker();
  }

  void _updateMarker() {
    _markers = {
      Marker(
        markerId: const MarkerId('selected-location'),
        position: _selectedLocation,
        infoWindow: const InfoWindow(title: 'Selected Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    };
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _updateMarker();
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              _selectedLocation.latitude - 0.01,
              _selectedLocation.longitude - 0.01,
            ),
            northeast: LatLng(
              _selectedLocation.latitude + 0.01,
              _selectedLocation.longitude + 0.01,
            ),
          ),
          100, // padding
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location updated to current position'),
          backgroundColor: DairyColorsLight.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: DairyColorsLight.error,
        ),
      );
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location on Map'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            markers: _markers,
            onTap: (LatLng location) {
              setState(() {
                _selectedLocation = location;
                _updateMarker();
              });
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            compassEnabled: true,
          ),

          // Center Pin (Visual indicator)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Icon(
                Icons.location_on,
                color: Colors.red,
                size: 40,
                shadows: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),

          // Top Control Panel
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tap on map to select location',
                        style: DairyTypography.caption(color: DairyColorsLight.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Control Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(DairySpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Selected Coordinates
                  Container(
                    padding: const EdgeInsets.all(DairySpacing.md),
                    decoration: BoxDecoration(
                      color: DairyColorsLight.primarySurface,
                      borderRadius: DairyRadius.defaultBorderRadius,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle, color: DairyColorsLight.success, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Selected Location',
                              style: DairyTypography.label(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          'Latitude: ${_selectedLocation.latitude.toStringAsFixed(6)}',
                          style: DairyTypography.caption(),
                        ),
                        SelectableText(
                          'Longitude: ${_selectedLocation.longitude.toStringAsFixed(6)}',
                          style: DairyTypography.caption(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: DairySpacing.md),

                  // Current Location Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                      icon: _isLoadingLocation
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.my_location),
                      label: const Text('Use Current Location'),
                    ),
                  ),

                  const SizedBox(height: DairySpacing.sm),

                  // Select Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context, {
                          'latitude': _selectedLocation.latitude,
                          'longitude': _selectedLocation.longitude,
                        });
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Confirm Selection'),
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

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

