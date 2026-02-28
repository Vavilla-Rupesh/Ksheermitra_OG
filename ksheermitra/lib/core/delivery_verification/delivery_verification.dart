/// Delivery Verification Module
///
/// A production-ready delivery verification system with:
/// - Real-time GPS tracking
/// - Geofence validation using Haversine formula
/// - Backend verification for security
/// - Support for ADB GPS injection
///
/// ## Architecture
///
/// This module follows clean architecture principles:
///
/// ```
/// delivery_verification/
/// ├── domain/           # Business logic layer
/// │   ├── entities/     # Core data models
/// │   └── services/     # Abstract service contracts
/// ├── data/             # Data layer
/// │   └── services/     # Service implementations
/// └── presentation/     # UI layer
///     ├── providers/    # State management
///     └── screens/      # UI screens and widgets
/// ```
///
/// ## Usage
///
/// ### Production Setup
///
/// ```dart
/// import 'package:ksheermitra/core/delivery_verification/delivery_verification.dart';
///
/// // Create provider with real location service
/// final provider = DeliveryVerificationProvider(
///   locationService: RealLocationService(),
/// );
///
/// // Use with Provider
/// ChangeNotifierProvider(
///   create: (_) => provider,
///   child: DeliveryVerificationScreen(order: order),
/// );
/// ```
///
/// ### ADB GPS Updates
///
/// The RealLocationService automatically receives GPS updates from ADB:
///
/// ```bash
/// # Set emulator location
/// adb emu geo fix 77.5946 12.9716
///
/// # The app will receive this location and update UI accordingly
/// ```
///
/// ## Security
///
/// - Frontend validation is for UX only
/// - Backend re-validates all delivery verifications
/// - GPS coordinates and timestamps are logged
/// - Distance is calculated server-side before order status update
library;

// Domain Layer - Entities
export 'domain/entities/entities.dart';

// Domain Layer - Services
export 'domain/services/services.dart';

// Data Layer - Service Implementations
export 'data/services/services.dart';

// Dependency Injection
export 'di/di.dart';

// Presentation Layer - Providers
export 'presentation/providers/delivery_verification_provider.dart';

// Presentation Layer - Screens
export 'presentation/screens/delivery_verification_screen.dart';

// Presentation Layer - Widgets
export 'presentation/screens/widgets/widgets.dart';
export 'presentation/widgets/production_delivery_verification_widget.dart';
