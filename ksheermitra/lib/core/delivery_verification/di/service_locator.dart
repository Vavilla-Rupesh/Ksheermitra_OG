/// Service Locator for Dependency Injection
///
/// Provides environment-aware service instantiation.
/// Uses RealLocationService with actual GPS in all environments.
/// Supports ADB GPS injection for emulator testing.
library;

import 'package:flutter/foundation.dart';
import 'package:ksheermitra/core/delivery_verification/data/services/real_location_service.dart';
import 'package:ksheermitra/core/delivery_verification/data/services/delivery_api_service.dart';
import 'package:ksheermitra/core/delivery_verification/domain/services/location_service.dart';

/// Environment types for service configuration
enum AppEnvironment {
  /// Production environment - uses real services
  production,

  /// Development environment - uses real services with debug logging
  development,


  /// Emulator environment - uses real GPS (supports ADB injection)
  emulator,
}

/// Service locator for dependency injection.
///
/// Usage:
/// ```dart
/// // Initialize at app startup
/// ServiceLocator.initialize(AppEnvironment.production);
///
/// // Get services
/// final locationService = ServiceLocator.locationService;
/// final apiService = ServiceLocator.deliveryApiService;
/// ```
class ServiceLocator {
  static AppEnvironment _environment = AppEnvironment.production;
  static LocationService? _locationService;
  static DeliveryApiService? _deliveryApiService;

  // Prevent instantiation
  ServiceLocator._();

  /// Initializes the service locator with the specified environment.
  ///
  /// Call this once at app startup, typically in main.dart
  static void initialize(AppEnvironment environment) {
    _environment = environment;
    _locationService = null;
    _deliveryApiService = null;

    debugPrint('ServiceLocator initialized with environment: ${environment.name}');
  }

  /// Gets the current environment
  static AppEnvironment get environment => _environment;

  /// Whether running in production mode
  static bool get isProduction => _environment == AppEnvironment.production;

  /// Gets the location service (RealLocationService).
  ///
  /// Uses actual GPS in all environments:
  /// - Production: Real device GPS
  /// - Development: Real device GPS with debug logging
  /// - Emulator: Supports ADB GPS injection
  static LocationService get locationService {
    _locationService ??= _createLocationService();
    return _locationService!;
  }

  /// Gets the delivery API service
  static DeliveryApiService get deliveryApiService {
    _deliveryApiService ??= DeliveryApiService();
    return _deliveryApiService!;
  }

  /// Creates the location service
  static LocationService _createLocationService() {
    // All environments use RealLocationService
    // Emulator mode supports ADB GPS injection via RealLocationService
    return RealLocationService();
  }

  /// Resets all services
  static void reset() {
    _locationService?.dispose();
    _locationService = null;
    _deliveryApiService = null;
  }
}

