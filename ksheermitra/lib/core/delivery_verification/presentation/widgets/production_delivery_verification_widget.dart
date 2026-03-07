/// Production Delivery Verification Widget
///
/// A standalone widget that handles the complete delivery verification flow
/// including GPS tracking, geofence validation, and backend verification.
///
/// This widget can be embedded in any screen to enable delivery verification.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ksheermitra/config/dairy_theme.dart';
import 'package:ksheermitra/core/delivery_verification/presentation/providers/delivery_verification_provider.dart';
import 'package:ksheermitra/core/delivery_verification/domain/entities/delivery_location.dart';
import 'package:ksheermitra/core/delivery_verification/domain/entities/delivery_order.dart';
import 'package:ksheermitra/core/delivery_verification/di/service_locator.dart';

/// Configuration for the delivery verification widget
class DeliveryVerificationConfig {
  /// Custom allowed radius (overrides order's radius if set)
  final double? customAllowedRadiusMeters;

  /// Whether to show the distance indicator
  final bool showDistanceIndicator;

  /// Whether to show the map preview
  final bool showMapPreview;

  /// Custom button text when within geofence
  final String deliverButtonText;

  /// Custom button text when outside geofence
  final String outsideButtonText;

  /// Callback when delivery is successfully verified
  final VoidCallback? onDeliverySuccess;

  /// Callback when delivery verification fails
  final Function(String errorMessage)? onDeliveryFailed;

  /// Custom primary color
  final Color? primaryColor;

  const DeliveryVerificationConfig({
    this.customAllowedRadiusMeters,
    this.showDistanceIndicator = true,
    this.showMapPreview = false,
    this.deliverButtonText = 'Mark Delivered',
    this.outsideButtonText = 'Move Closer to Deliver',
    this.onDeliverySuccess,
    this.onDeliveryFailed,
    this.primaryColor,
  });
}

/// Production-ready delivery verification widget.
///
/// Usage:
/// ```dart
/// ProductionDeliveryVerificationWidget(
///   order: deliveryOrder,
///   config: DeliveryVerificationConfig(
///     onDeliverySuccess: () {
///       // Navigate or show success
///     },
///   ),
/// )
/// ```
class ProductionDeliveryVerificationWidget extends StatefulWidget {
  /// The delivery order to verify
  final DeliveryOrder order;

  /// Widget configuration
  final DeliveryVerificationConfig config;

  const ProductionDeliveryVerificationWidget({
    super.key,
    required this.order,
    this.config = const DeliveryVerificationConfig(),
  });

  @override
  State<ProductionDeliveryVerificationWidget> createState() =>
      _ProductionDeliveryVerificationWidgetState();
}

class _ProductionDeliveryVerificationWidgetState
    extends State<ProductionDeliveryVerificationWidget> {
  late DeliveryVerificationProvider _provider;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeProvider();
  }

  void _initializeProvider() {
    // Use service locator for proper DI
    _provider = DeliveryVerificationProvider(
      locationService: ServiceLocator.locationService,
      apiService: ServiceLocator.deliveryApiService,
    );
    _isInitialized = true;

    // Start tracking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.startTracking(widget.order);
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  Color get _primaryColor =>
      widget.config.primaryColor ?? Theme.of(context).primaryColor;

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return ChangeNotifierProvider<DeliveryVerificationProvider>.value(
      value: _provider,
      child: Consumer<DeliveryVerificationProvider>(
        builder: (context, provider, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status Banner
              _buildStatusBanner(provider),

              // Distance Indicator
              if (widget.config.showDistanceIndicator)
                _buildDistanceIndicator(provider),

              // Error State Handling
              if (_isErrorState(provider.state)) _buildErrorCard(provider),

              // Action Button
              const SizedBox(height: 16),
              _buildActionButton(provider),
            ],
          );
        },
      ),
    );
  }

  bool _isErrorState(DeliveryVerificationState state) {
    return state == DeliveryVerificationState.gpsDisabled ||
        state == DeliveryVerificationState.permissionDenied ||
        state == DeliveryVerificationState.permissionDeniedForever ||
        state == DeliveryVerificationState.error;
  }

  Widget _buildStatusBanner(DeliveryVerificationProvider provider) {
    Color backgroundColor;
    IconData icon;
    String text;

    switch (provider.state) {
      case DeliveryVerificationState.withinGeofence:
        backgroundColor = Colors.green;
        icon = Icons.check_circle;
        text = 'Within Delivery Zone';
        break;
      case DeliveryVerificationState.outsideGeofence:
        backgroundColor = Colors.orange;
        icon = Icons.warning;
        text = 'Outside Delivery Zone';
        break;
      case DeliveryVerificationState.tracking:
        backgroundColor = Colors.blue;
        icon = Icons.my_location;
        text = 'Tracking Location...';
        break;
      case DeliveryVerificationState.verifying:
        backgroundColor = _primaryColor;
        icon = Icons.hourglass_bottom;
        text = 'Verifying Delivery...';
        break;
      case DeliveryVerificationState.verified:
        backgroundColor = Colors.green;
        icon = Icons.verified;
        text = 'Delivery Verified!';
        break;
      case DeliveryVerificationState.gpsDisabled:
        backgroundColor = Colors.red;
        icon = Icons.location_off;
        text = 'GPS Disabled';
        break;
      case DeliveryVerificationState.permissionDenied:
      case DeliveryVerificationState.permissionDeniedForever:
        backgroundColor = Colors.red;
        icon = Icons.no_accounts;
        text = 'Permission Required';
        break;
      case DeliveryVerificationState.error:
        backgroundColor = Colors.red;
        icon = Icons.error;
        text = 'Error';
        break;
      case DeliveryVerificationState.initializing:
      case DeliveryVerificationState.idle:
        backgroundColor = Colors.grey;
        icon = Icons.location_searching;
        text = 'Initializing...';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceIndicator(DeliveryVerificationProvider provider) {
    final distance = provider.distanceToDestination;
    final allowedRadius = widget.config.customAllowedRadiusMeters ??
        widget.order.allowedRadiusMeters;

    if (distance == null) {
      return const SizedBox.shrink();
    }

    final isWithin = distance <= allowedRadius;
    final distanceText = distance >= 1000
        ? '${(distance / 1000).toStringAsFixed(2)} km'
        : '${distance.toStringAsFixed(0)} m';

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(DairyRadius.md),
        border: Border.all(
          color: isWithin ? Colors.green : Colors.orange,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.straighten,
                color: isWithin ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                'Distance to Customer',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            distanceText,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isWithin ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isWithin
                ? 'You are within delivery range'
                : 'Move ${(distance - allowedRadius).toStringAsFixed(0)}m closer',
            style: TextStyle(
              fontSize: 12,
              color: isWithin ? Colors.green[700] : Colors.orange[700],
            ),
          ),
          const SizedBox(height: 8),
          // Progress indicator
          LinearProgressIndicator(
            value: isWithin ? 1.0 : (allowedRadius / distance).clamp(0.0, 1.0),
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              isWithin ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Allowed radius: ${allowedRadius.toStringAsFixed(0)}m',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(DeliveryVerificationProvider provider) {
    String title;
    String message;
    String buttonText;
    VoidCallback onAction;

    switch (provider.state) {
      case DeliveryVerificationState.gpsDisabled:
        title = 'GPS Disabled';
        message = 'Please enable GPS to verify your delivery location.';
        buttonText = 'Open Settings';
        onAction = () => provider.openLocationSettings();
        break;
      case DeliveryVerificationState.permissionDenied:
        title = 'Permission Denied';
        message = 'Location permission is required to verify deliveries.';
        buttonText = 'Grant Permission';
        onAction = () => provider.retry();
        break;
      case DeliveryVerificationState.permissionDeniedForever:
        title = 'Permission Blocked';
        message =
            'Location permission was permanently denied. Please enable it in app settings.';
        buttonText = 'Open App Settings';
        onAction = () => provider.openAppSettings();
        break;
      default:
        title = 'Error';
        message = provider.errorMessage ?? 'An error occurred.';
        buttonText = 'Retry';
        onAction = () => provider.retry();
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(DairyRadius.md),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 40),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(DeliveryVerificationProvider provider) {
    final canDeliver = provider.canMarkDelivered;
    final isVerifying = provider.state == DeliveryVerificationState.verifying;
    final isVerified = provider.state == DeliveryVerificationState.verified;

    if (isVerified) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(DairyRadius.md),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              'Delivery Completed!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: canDeliver && !isVerifying
            ? () => _handleDeliveryAction(provider)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canDeliver ? Colors.green : Colors.grey,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DairyRadius.md),
          ),
          elevation: canDeliver ? 4 : 0,
        ),
        child: isVerifying
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Verifying...'),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(canDeliver ? Icons.check : Icons.location_on),
                  const SizedBox(width: 8),
                  Text(
                    canDeliver
                        ? widget.config.deliverButtonText
                        : widget.config.outsideButtonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _handleDeliveryAction(
      DeliveryVerificationProvider provider) async {
    final result = await provider.verifyAndCompleteDelivery();

    if (result.isSuccess) {
      widget.config.onDeliverySuccess?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery verified successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      widget.config.onDeliveryFailed?.call(result.message ?? 'Unknown error');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Verification failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Simplified verification button for quick integration
///
/// Usage:
/// ```dart
/// DeliveryVerificationButton(
///   deliveryId: 'delivery-123',
///   customerLatitude: 12.9716,
///   customerLongitude: 77.5946,
///   onSuccess: () {
///     // Handle success
///   },
/// )
/// ```
class DeliveryVerificationButton extends StatelessWidget {
  final String deliveryId;
  final String customerName;
  final double customerLatitude;
  final double customerLongitude;
  final double allowedRadiusMeters;
  final VoidCallback? onSuccess;
  final Function(String)? onError;

  const DeliveryVerificationButton({
    super.key,
    required this.deliveryId,
    required this.customerName,
    required this.customerLatitude,
    required this.customerLongitude,
    this.allowedRadiusMeters = 100.0,
    this.onSuccess,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    final order = DeliveryOrder(
      id: deliveryId,
      customerId: '',
      customerName: customerName,
      deliveryAddress: '',
      destination: DeliveryLocation(
        latitude: customerLatitude,
        longitude: customerLongitude,
      ),
      allowedRadiusMeters: allowedRadiusMeters,
      status: DeliveryOrderStatus.pending,
      items: const [],
      totalAmount: 0,
      deliveryDate: DateTime.now(),
    );

    return ProductionDeliveryVerificationWidget(
      order: order,
      config: DeliveryVerificationConfig(
        onDeliverySuccess: onSuccess,
        onDeliveryFailed: onError,
        showDistanceIndicator: true,
      ),
    );
  }
}

