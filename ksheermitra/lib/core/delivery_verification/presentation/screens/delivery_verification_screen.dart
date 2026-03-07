/// Delivery Verification Screen
///
/// A complete screen for verifying and completing deliveries with
/// real-time GPS tracking and geofence validation.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ksheermitra/config/dairy_theme.dart';
import '../providers/delivery_verification_provider.dart';
import '../../domain/entities/entities.dart';
import 'widgets/widgets.dart';

/// Main screen for delivery verification.
///
/// Shows:
/// - Order details
/// - Real-time distance to destination
/// - Geofence status indicator
/// - Mark Delivered button (enabled only within geofence)
/// - Error states with retry options
class DeliveryVerificationScreen extends StatefulWidget {
  /// The delivery order to verify
  final DeliveryOrder order;

  const DeliveryVerificationScreen({
    super.key,
    required this.order,
  });

  @override
  State<DeliveryVerificationScreen> createState() => _DeliveryVerificationScreenState();
}

class _DeliveryVerificationScreenState extends State<DeliveryVerificationScreen> {
  @override
  void initState() {
    super.initState();
    // Start tracking when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliveryVerificationProvider>().startTracking(widget.order);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Delivery'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<DeliveryVerificationProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Status Header
              _buildStatusHeader(provider),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Order Info Card
                      OrderInfoCard(order: widget.order),

                      const SizedBox(height: 16),

                      // Location Status Card
                      LocationStatusCard(
                        state: provider.state,
                        geofenceResult: provider.geofenceResult,
                        currentLocation: provider.currentLocation,
                        destination: widget.order.destination,
                        allowedRadius: widget.order.allowedRadiusMeters,
                      ),

                      const SizedBox(height: 16),

                      // Error/Action Cards
                      _buildStateSpecificContent(provider),
                    ],
                  ),
                ),
              ),

              // Bottom Action Button
              _buildBottomAction(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusHeader(DeliveryVerificationProvider provider) {
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
        backgroundColor = Colors.teal;
        icon = Icons.hourglass_bottom;
        text = 'Verifying Delivery...';
        break;
      case DeliveryVerificationState.verified:
        backgroundColor = Colors.green;
        icon = Icons.verified;
        text = 'Delivery Verified!';
        break;
      case DeliveryVerificationState.gpsDisabled:
      case DeliveryVerificationState.permissionDenied:
      case DeliveryVerificationState.permissionDeniedForever:
      case DeliveryVerificationState.error:
        backgroundColor = Colors.red;
        icon = Icons.error;
        text = 'Location Error';
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
      color: backgroundColor,
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
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateSpecificContent(DeliveryVerificationProvider provider) {
    switch (provider.state) {
      case DeliveryVerificationState.gpsDisabled:
        return ErrorActionCard(
          icon: Icons.location_off,
          title: 'GPS Disabled',
          message: 'Please enable GPS to verify your location.',
          actionLabel: 'Open Settings',
          onAction: () => provider.openLocationSettings(),
        );

      case DeliveryVerificationState.permissionDenied:
        return ErrorActionCard(
          icon: Icons.no_accounts,
          title: 'Permission Denied',
          message: 'Location permission is required to verify deliveries.',
          actionLabel: 'Grant Permission',
          onAction: () => provider.retry(),
        );

      case DeliveryVerificationState.permissionDeniedForever:
        return ErrorActionCard(
          icon: Icons.block,
          title: 'Permission Blocked',
          message: 'Location permission was permanently denied. Please enable it in app settings.',
          actionLabel: 'Open App Settings',
          onAction: () => provider.openAppSettings(),
        );

      case DeliveryVerificationState.error:
        return ErrorActionCard(
          icon: Icons.error_outline,
          title: 'Error',
          message: provider.errorMessage ?? 'An error occurred.',
          actionLabel: 'Retry',
          onAction: () => provider.retry(),
        );

      case DeliveryVerificationState.verified:
        return SuccessCard(
          result: provider.lastVerificationResult,
        );

      case DeliveryVerificationState.outsideGeofence:
        return DistanceInfoCard(
          geofenceResult: provider.geofenceResult!,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomAction(DeliveryVerificationProvider provider) {
    if (provider.state == DeliveryVerificationState.verified) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DairyRadius.md),
              ),
            ),
            child: const Text(
              'Done',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DeliveryButton(
          canDeliver: provider.canMarkDelivered,
          isLoading: provider.state == DeliveryVerificationState.verifying,
          onPressed: () async {
            final result = await provider.verifyAndCompleteDelivery();
            if (!result.isSuccess && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          distanceMeters: provider.distanceToDestination,
          allowedRadiusMeters: provider.allowedRadius,
        ),
      ),
    );
  }
}

