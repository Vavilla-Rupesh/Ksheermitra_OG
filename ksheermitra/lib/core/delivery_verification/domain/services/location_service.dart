/// Abstract Location Service
///
/// Defines the contract for location services used in delivery verification.
/// This abstraction allows for easy testing with mock implementations
/// and supports different location providers (real GPS, mock GPS, ADB injection).
library;

import '../entities/delivery_location.dart';

/// Result of a permission request
enum LocationPermissionStatus {
  /// Permission granted
  granted,

  /// Permission denied by user
  denied,

  /// Permission denied forever (user selected "don't ask again")
  deniedForever,

  /// Permission restricted by system (e.g., parental controls)
  restricted,
}

/// Status of location services on the device
enum LocationServiceStatus {
  /// Location services are enabled
  enabled,

  /// Location services are disabled
  disabled,

  /// Status is unknown
  unknown,
}

/// Abstract class defining the location service contract.
///
/// Implementations:
/// - [RealLocationService] - Uses actual device GPS via Geolocator
/// - [MockLocationService] - Emits predefined coordinates for testing
///
/// Usage:
/// ```dart
/// final locationService = RealLocationService();
/// // or for testing:
/// final locationService = MockLocationService();
///
/// // Get current position
/// final position = await locationService.getCurrentPosition();
///
/// // Listen to position stream
/// locationService.getPositionStream().listen((position) {
///   print('New position: ${position.latitude}, ${position.longitude}');
/// });
/// ```
abstract class LocationService {
  /// Returns a stream of position updates.
  ///
  /// The stream emits new positions whenever the device location changes
  /// based on the configured accuracy and distance filter.
  ///
  /// For real GPS: Updates come from device sensors
  /// For mock: Updates come from predefined coordinates
  /// For ADB: Updates come from emulator GPS injection
  ///
  /// Throws [LocationServiceException] if location services are disabled
  /// or permissions are not granted.
  Stream<DeliveryLocation> getPositionStream();

  /// Gets the current device position.
  ///
  /// Returns the most accurate position available within the timeout period.
  ///
  /// Throws [LocationServiceException] if:
  /// - Location services are disabled
  /// - Permissions are not granted
  /// - Request times out
  Future<DeliveryLocation> getCurrentPosition();

  /// Checks if location services are enabled on the device.
  ///
  /// Returns [LocationServiceStatus.enabled] if GPS/location is available,
  /// [LocationServiceStatus.disabled] if turned off by user.
  Future<LocationServiceStatus> checkServiceStatus();

  /// Requests location permission from the user.
  ///
  /// Returns [LocationPermissionStatus] indicating the result.
  /// On Android, this may show a system dialog.
  Future<LocationPermissionStatus> requestPermission();

  /// Checks the current permission status without requesting.
  ///
  /// Useful for checking status before showing UI elements.
  Future<LocationPermissionStatus> checkPermission();

  /// Opens the device location settings.
  ///
  /// Useful when location services are disabled and user needs to enable them.
  /// Returns true if the settings were opened successfully.
  Future<bool> openLocationSettings();

  /// Opens the app settings page.
  ///
  /// Useful when permission is permanently denied and user needs to
  /// manually enable it in app settings.
  /// Returns true if the settings were opened successfully.
  Future<bool> openAppSettings();

  /// Gets the last known position without requesting a new fix.
  ///
  /// This is faster than [getCurrentPosition] but may be stale.
  /// Returns null if no cached position is available.
  Future<DeliveryLocation?> getLastKnownPosition();

  /// Disposes of any resources held by the service.
  ///
  /// Call this when the service is no longer needed to free resources
  /// and stop any active location subscriptions.
  void dispose();
}

/// Exception thrown by location services
class LocationServiceException implements Exception {
  /// The error type
  final LocationServiceError error;

  /// Human-readable error message
  final String message;

  /// Original exception that caused this error (if any)
  final dynamic originalException;

  const LocationServiceException({
    required this.error,
    required this.message,
    this.originalException,
  });

  @override
  String toString() => 'LocationServiceException: $message (${error.name})';
}

/// Types of location service errors
enum LocationServiceError {
  /// Location services are disabled
  serviceDisabled,

  /// Location permission denied
  permissionDenied,

  /// Location permission permanently denied
  permissionDeniedForever,

  /// Location request timed out
  timeout,

  /// Unknown error
  unknown,
}

