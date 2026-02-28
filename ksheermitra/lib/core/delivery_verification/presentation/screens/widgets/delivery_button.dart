/// Delivery Button Widget
///
/// A smart button that shows state based on delivery verification status.
library;

import 'package:flutter/material.dart';

/// Button for marking delivery as complete.
///
/// Features:
/// - Disabled when outside geofence
/// - Shows distance when outside zone
/// - Loading state during verification
/// - Animated state transitions
class DeliveryButton extends StatelessWidget {
  /// Whether the button should be enabled
  final bool canDeliver;

  /// Whether verification is in progress
  final bool isLoading;

  /// Callback when button is pressed
  final VoidCallback onPressed;

  /// Current distance to destination in meters
  final double? distanceMeters;

  /// Allowed radius in meters
  final double allowedRadiusMeters;

  const DeliveryButton({
    super.key,
    required this.canDeliver,
    required this.isLoading,
    required this.onPressed,
    this.distanceMeters,
    required this.allowedRadiusMeters,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Warning text when outside zone
          if (!canDeliver && distanceMeters != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Move ${(distanceMeters! - allowedRadiusMeters).toStringAsFixed(0)}m closer to deliver',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Main button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: (canDeliver && !isLoading) ? onPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canDeliver ? Colors.green : Colors.grey[400],
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                disabledForegroundColor: Colors.grey[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: canDeliver ? 4 : 0,
              ),
              child: isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Verifying...',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          canDeliver ? Icons.check_circle : Icons.location_off,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          canDeliver ? 'Mark Delivered' : 'Outside Delivery Zone',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
}

