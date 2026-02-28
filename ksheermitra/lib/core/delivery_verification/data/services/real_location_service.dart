/// Real Location Service Implementation
///
/// Uses the Geolocator package to provide actual GPS location data.
/// This implementation works with both physical device GPS and
/// emulator GPS injection (via ADB commands).
library;

import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:ksheermitra/core/delivery_verification/domain/entities/delivery_location.dart';
import 'package:ksheermitra/core/delivery_verification/domain/services/location_service.dart';

/// Real GPS-based implementation of [LocationService].
///
/// This service:
/// - Uses the Geolocator package for GPS access
/// - Supports ADB emulator GPS injection (`adb emu geo fix`)
/// - Handles all permission and service status checks
/// - Provides both streaming and one-shot position access
///
/// Configuration:
/// - Accuracy: High (best available)
/// - Distance filter: 5 meters (minimum movement to trigger update)
/// - Timeout: 15 seconds for position requests
class RealLocationService implements LocationService {
  /// Stream controller for broadcasting position updates
  StreamController<DeliveryLocation>? _positionStreamController;

  /// Subscription to Geolocator position stream
  StreamSubscription<Position>? _positionSubscription;

  /// Whether the service has been disposed
  bool _isDisposed = false;

  /// Location settings for high-accuracy GPS
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5, // Minimum distance (meters) before update
  );

  /// Timeout duration for position requests
  static const Duration _positionTimeout = Duration(seconds: 15);

  @override
  Stream<DeliveryLocation> getPositionStream() {
    if (_isDisposed) {
      throw const LocationServiceException(
        error: LocationServiceError.unknown,
        message: 'Location service has been disposed',
      );
    }

    // Create or reuse stream controller
    _positionStreamController ??= StreamController<DeliveryLocation>.broadcast(
      onListen: _startListening,
      onCancel: _checkIfShouldStopListening,
    );

    return _positionStreamController!.stream;
  }

  /// Starts listening to Geolocator position updates
  Future<void> _startListening() async {
    if (_positionSubscription != null) return;

    try {
      // Check service and permissions first
      await _ensureServiceAndPermission();

      // Start listening to position stream
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: _locationSettings,
      ).listen(
        (Position position) {
          if (!_isDisposed && _positionStreamController != null) {
            _positionStreamController!.add(_convertPosition(position));
          }
        },
        onError: (error) {
          if (!_isDisposed && _positionStreamController != null) {
            _positionStreamController!.addError(
              _handleGeolocatorError(error),
            );
          }
        },
      );
    } catch (e) {
      if (!_isDisposed && _positionStreamController != null) {
        _positionStreamController!.addError(
          _handleGeolocatorError(e),
        );
      }
    }
  }

  /// Checks if we should stop listening (no more listeners)
  void _checkIfShouldStopListening() {
    if (_positionStreamController?.hasListener == false) {
      _positionSubscription?.cancel();
      _positionSubscription = null;
    }
  }

  @override
  Future<DeliveryLocation> getCurrentPosition() async {
    if (_isDisposed) {
      throw const LocationServiceException(
        error: LocationServiceError.unknown,
        message: 'Location service has been disposed',
      );
    }

    try {
      // Check service and permissions first
      await _ensureServiceAndPermission();

      // Get current position with timeout
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        _positionTimeout,
        onTimeout: () {
          throw const LocationServiceException(
            error: LocationServiceError.timeout,
            message: 'Location request timed out. Please try again in an open area.',
          );
        },
      );

      return _convertPosition(position);
    } on LocationServiceException {
      rethrow;
    } catch (e) {
      throw _handleGeolocatorError(e);
    }
  }

  @override
  Future<LocationServiceStatus> checkServiceStatus() async {
    try {
      final isEnabled = await Geolocator.isLocationServiceEnabled();
      return isEnabled
          ? LocationServiceStatus.enabled
          : LocationServiceStatus.disabled;
    } catch (e) {
      return LocationServiceStatus.unknown;
    }
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      return _convertPermission(permission);
    } catch (e) {
      return LocationPermissionStatus.denied;
    }
  }

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return _convertPermission(permission);
    } catch (e) {
      return LocationPermissionStatus.denied;
    }
  }

  @override
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<DeliveryLocation?> getLastKnownPosition() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position == null) return null;
      return _convertPosition(position);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _positionStreamController?.close();
    _positionStreamController = null;
  }

  /// Ensures location service is enabled and permission is granted
  Future<void> _ensureServiceAndPermission() async {
    // Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceException(
        error: LocationServiceError.serviceDisabled,
        message: 'Location services are disabled. Please enable GPS.',
      );
    }

    // Check permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Request permission
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        throw const LocationServiceException(
          error: LocationServiceError.permissionDenied,
          message: 'Location permission denied. Please grant access.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationServiceException(
        error: LocationServiceError.permissionDeniedForever,
        message: 'Location permission permanently denied. Please enable in app settings.',
      );
    }
  }

  /// Converts Geolocator Position to DeliveryLocation
  DeliveryLocation _convertPosition(Position position) {
    return DeliveryLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      timestamp: position.timestamp,
      altitude: position.altitude,
      heading: position.heading,
      speed: position.speed,
    );
  }

  /// Converts Geolocator permission to our enum
  LocationPermissionStatus _convertPermission(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return LocationPermissionStatus.granted;
      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.denied;
    }
  }

  /// Handles Geolocator errors and converts to LocationServiceException
  LocationServiceException _handleGeolocatorError(dynamic error) {
    if (error is LocationServiceException) {
      return error;
    }

    if (error is PermissionDeniedException) {
      return LocationServiceException(
        error: LocationServiceError.permissionDenied,
        message: 'Location permission denied.',
        originalException: error,
      );
    }

    if (error is LocationServiceDisabledException) {
      return LocationServiceException(
        error: LocationServiceError.serviceDisabled,
        message: 'Location services are disabled.',
        originalException: error,
      );
    }

    if (error is TimeoutException) {
      return LocationServiceException(
        error: LocationServiceError.timeout,
        message: 'Location request timed out.',
        originalException: error,
      );
    }

    return LocationServiceException(
      error: LocationServiceError.unknown,
      message: error.toString(),
      originalException: error,
    );
  }
}

