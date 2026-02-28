/// Delivery Verification Provider
///
/// Manages the state for delivery verification including:
/// - Real-time location tracking
/// - Geofence validation
/// - Backend verification
/// - Error handling
library;

import 'dart:async';
import 'package:flutter/foundation.dart';

// Domain entities
import '../../domain/entities/delivery_location.dart';
import '../../domain/entities/delivery_order.dart';
import '../../domain/entities/delivery_verification_result.dart';

// Domain services
import '../../domain/services/location_service.dart';
import '../../domain/services/geofence_util.dart';

// Data services
import '../../data/services/delivery_api_service.dart';

/// State representing the current delivery verification status
enum DeliveryVerificationState {
  /// Initial state, not tracking
  idle,

  /// Checking permissions and service status
  initializing,

  /// Actively tracking location
  tracking,

  /// Location is within geofence, can deliver
  withinGeofence,

  /// Location is outside geofence
  outsideGeofence,

  /// Verifying delivery with backend
  verifying,

  /// Delivery verified and completed
  verified,

  /// GPS is disabled
  gpsDisabled,

  /// Permission denied
  permissionDenied,

  /// Permission permanently denied
  permissionDeniedForever,

  /// Error state
  error,
}

/// Provider for managing delivery verification state.
///
/// Usage:
/// ```dart
/// final provider = DeliveryVerificationProvider(
///   locationService: RealLocationService(),
/// );
///
/// // Start tracking for a specific order
/// await provider.startTracking(order);
///
/// // Listen to state changes
/// provider.addListener(() {
///   if (provider.state == DeliveryVerificationState.withinGeofence) {
///     // Enable "Mark Delivered" button
///   }
/// });
///
/// // Complete delivery when button is pressed
/// final result = await provider.verifyAndCompleteDelivery();
/// ```
class DeliveryVerificationProvider extends ChangeNotifier {
  /// The location service (can be real or mock)
  final LocationService _locationService;

  /// The delivery API service
  final DeliveryApiService _apiService;

  /// Current verification state
  DeliveryVerificationState _state = DeliveryVerificationState.idle;

  /// Current agent location
  DeliveryLocation? _currentLocation;

  /// The delivery order being verified
  DeliveryOrder? _currentOrder;

  /// Current geofence check result
  GeofenceCheckResult? _geofenceResult;

  /// Last verification result
  DeliveryVerificationResult? _lastVerificationResult;

  /// Error message if any
  String? _errorMessage;

  /// Subscription to location stream
  StreamSubscription<DeliveryLocation>? _locationSubscription;

  /// Whether the provider has been disposed
  bool _isDisposed = false;

  /// Creates the provider with required services
  ///
  /// For production:
  /// ```dart
  /// DeliveryVerificationProvider(
  ///   locationService: RealLocationService(),
  /// )
  /// ```
  ///
  /// For testing:
  /// ```dart
  /// DeliveryVerificationProvider(
  ///   locationService: MockLocationService(),
  /// )
  /// ```
  DeliveryVerificationProvider({
    required LocationService locationService,
    DeliveryApiService? apiService,
  })  : _locationService = locationService,
        _apiService = apiService ?? DeliveryApiService();

  // ============================================================
  // Getters
  // ============================================================

  /// Current verification state
  DeliveryVerificationState get state => _state;

  /// Current agent location
  DeliveryLocation? get currentLocation => _currentLocation;

  /// Current order being tracked
  DeliveryOrder? get currentOrder => _currentOrder;

  /// Current geofence check result
  GeofenceCheckResult? get geofenceResult => _geofenceResult;

  /// Last verification result from backend
  DeliveryVerificationResult? get lastVerificationResult => _lastVerificationResult;

  /// Error message if in error state
  String? get errorMessage => _errorMessage;

  /// Whether "Mark Delivered" button should be enabled
  bool get canMarkDelivered => _state == DeliveryVerificationState.withinGeofence;

  /// Whether currently tracking location
  bool get isTracking =>
      _state == DeliveryVerificationState.tracking ||
      _state == DeliveryVerificationState.withinGeofence ||
      _state == DeliveryVerificationState.outsideGeofence;

  /// Distance to destination in meters (null if not tracking)
  double? get distanceToDestination => _geofenceResult?.distance;

  /// Allowed radius in meters
  double get allowedRadius => _currentOrder?.allowedRadiusMeters ?? 100.0;

  // ============================================================
  // Public Methods
  // ============================================================

  /// Starts tracking location for the given delivery order.
  ///
  /// This will:
  /// 1. Check if GPS is enabled
  /// 2. Request permission if needed
  /// 3. Start listening to location updates
  /// 4. Update geofence status on each location change
  Future<void> startTracking(DeliveryOrder order) async {
    if (_isDisposed) return;

    _currentOrder = order;
    _state = DeliveryVerificationState.initializing;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check service status
      final serviceStatus = await _locationService.checkServiceStatus();
      if (serviceStatus == LocationServiceStatus.disabled) {
        _state = DeliveryVerificationState.gpsDisabled;
        _errorMessage = 'GPS is disabled. Please enable location services.';
        notifyListeners();
        return;
      }

      // Check permission
      var permissionStatus = await _locationService.checkPermission();
      if (permissionStatus == LocationPermissionStatus.denied) {
        permissionStatus = await _locationService.requestPermission();
      }

      if (permissionStatus == LocationPermissionStatus.denied) {
        _state = DeliveryVerificationState.permissionDenied;
        _errorMessage = 'Location permission denied. Please grant access.';
        notifyListeners();
        return;
      }

      if (permissionStatus == LocationPermissionStatus.deniedForever) {
        _state = DeliveryVerificationState.permissionDeniedForever;
        _errorMessage = 'Location permission permanently denied. Please enable in settings.';
        notifyListeners();
        return;
      }

      // Start tracking
      _state = DeliveryVerificationState.tracking;
      notifyListeners();

      // Get initial position
      try {
        final position = await _locationService.getCurrentPosition();
        _updateLocation(position);
      } catch (e) {
        // Will get updates from stream
      }

      // Subscribe to location stream
      _locationSubscription?.cancel();
      _locationSubscription = _locationService.getPositionStream().listen(
        _updateLocation,
        onError: _handleLocationError,
      );
    } on LocationServiceException catch (e) {
      _handleLocationException(e);
    } catch (e) {
      _state = DeliveryVerificationState.error;
      _errorMessage = 'Failed to start tracking: $e';
      notifyListeners();
    }
  }

  /// Stops tracking location
  void stopTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _state = DeliveryVerificationState.idle;
    _currentLocation = null;
    _geofenceResult = null;
    notifyListeners();
  }

  /// Verifies delivery with backend and marks as complete.
  ///
  /// This should only be called when [canMarkDelivered] is true.
  ///
  /// Returns [DeliveryVerificationResult] with success or failure details.
  ///
  /// IMPORTANT: The backend will re-validate the distance. This frontend
  /// validation is only for UX purposes.
  Future<DeliveryVerificationResult> verifyAndCompleteDelivery({String? notes}) async {
    if (_isDisposed) {
      return DeliveryVerificationResult.unknown(
        errorMessage: 'Provider has been disposed',
      );
    }

    if (_currentOrder == null) {
      return DeliveryVerificationResult.unknown(
        errorMessage: 'No order selected for delivery',
      );
    }

    if (_currentLocation == null) {
      return DeliveryVerificationResult.unknown(
        errorMessage: 'Current location not available',
      );
    }

    // Frontend check (for UX only - backend will re-verify)
    if (_state != DeliveryVerificationState.withinGeofence) {
      return DeliveryVerificationResult.outsideRadius(
        agentLocation: _currentLocation!,
        destinationLocation: _currentOrder!.destination,
        distanceMeters: _geofenceResult?.distance ?? 0,
        allowedRadiusMeters: _currentOrder!.allowedRadiusMeters,
        deliveryId: _currentOrder!.id,
      );
    }

    _state = DeliveryVerificationState.verifying;
    notifyListeners();

    try {
      // Send to backend for verification
      // BACKEND WILL RE-CHECK DISTANCE - this is the security layer
      final result = await _apiService.verifyAndCompleteDelivery(
        deliveryId: _currentOrder!.id,
        agentLocation: _currentLocation!,
        notes: notes,
      );

      _lastVerificationResult = result;

      if (result.isSuccess) {
        _state = DeliveryVerificationState.verified;
      } else {
        // Backend rejected - update state based on rejection reason
        switch (result.status) {
          case VerificationStatus.outsideRadius:
            _state = DeliveryVerificationState.outsideGeofence;
            _errorMessage = result.message;
            break;
          case VerificationStatus.networkError:
            _state = DeliveryVerificationState.error;
            _errorMessage = result.message;
            break;
          default:
            _state = DeliveryVerificationState.error;
            _errorMessage = result.message;
        }
      }

      notifyListeners();
      return result;
    } catch (e) {
      _state = DeliveryVerificationState.error;
      _errorMessage = 'Verification failed: $e';
      notifyListeners();

      return DeliveryVerificationResult.unknown(
        errorMessage: _errorMessage,
      );
    }
  }

  /// Opens device location settings
  Future<void> openLocationSettings() async {
    await _locationService.openLocationSettings();
  }

  /// Opens app settings for permission management
  Future<void> openAppSettings() async {
    await _locationService.openAppSettings();
  }

  /// Retries tracking after an error
  Future<void> retry() async {
    if (_currentOrder != null) {
      await startTracking(_currentOrder!);
    }
  }

  /// Resets the provider to initial state
  void reset() {
    stopTracking();
    _currentOrder = null;
    _lastVerificationResult = null;
    _errorMessage = null;
    _state = DeliveryVerificationState.idle;
    notifyListeners();
  }

  // ============================================================
  // Private Methods
  // ============================================================

  /// Updates location and checks geofence
  void _updateLocation(DeliveryLocation location) {
    if (_isDisposed) return;

    _currentLocation = location;

    if (_currentOrder != null && _currentOrder!.hasValidDestination) {
      // Check geofence
      _geofenceResult = GeofenceUtil.checkGeofence(
        location,
        _currentOrder!.destination,
        _currentOrder!.allowedRadiusMeters,
      );

      // Update state based on geofence check
      if (_geofenceResult!.isWithinRadius) {
        _state = DeliveryVerificationState.withinGeofence;
      } else {
        _state = DeliveryVerificationState.outsideGeofence;
      }
    }

    notifyListeners();

    // Optionally update server with current location
    _apiService.updateAgentLocation(location);
  }

  /// Handles location stream errors
  void _handleLocationError(dynamic error) {
    if (_isDisposed) return;

    if (error is LocationServiceException) {
      _handleLocationException(error);
    } else {
      _state = DeliveryVerificationState.error;
      _errorMessage = 'Location error: $error';
      notifyListeners();
    }
  }

  /// Handles location service exceptions
  void _handleLocationException(LocationServiceException e) {
    switch (e.error) {
      case LocationServiceError.serviceDisabled:
        _state = DeliveryVerificationState.gpsDisabled;
        _errorMessage = e.message;
        break;
      case LocationServiceError.permissionDenied:
        _state = DeliveryVerificationState.permissionDenied;
        _errorMessage = e.message;
        break;
      case LocationServiceError.permissionDeniedForever:
        _state = DeliveryVerificationState.permissionDeniedForever;
        _errorMessage = e.message;
        break;
      case LocationServiceError.timeout:
        _state = DeliveryVerificationState.error;
        _errorMessage = e.message;
        break;
      case LocationServiceError.unknown:
        _state = DeliveryVerificationState.error;
        _errorMessage = e.message;
        break;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _locationSubscription?.cancel();
    _locationService.dispose();
    super.dispose();
  }
}

