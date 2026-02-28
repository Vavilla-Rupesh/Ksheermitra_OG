/// Location Status Card Widget
///
/// Displays real-time location status and distance to destination.
library;

import 'package:flutter/material.dart';
import 'package:ksheermitra/core/delivery_verification/domain/entities/delivery_location.dart';
import 'package:ksheermitra/core/delivery_verification/domain/services/geofence_util.dart';
import 'package:ksheermitra/core/delivery_verification/presentation/providers/delivery_verification_provider.dart';

/// Card showing current location status and distance to destination
class LocationStatusCard extends StatelessWidget {
  final DeliveryVerificationState state;
  final GeofenceCheckResult? geofenceResult;
  final DeliveryLocation? currentLocation;
  final DeliveryLocation destination;
  final double allowedRadius;

  const LocationStatusCard({
    super.key,
    required this.state,
    this.geofenceResult,
    this.currentLocation,
    required this.destination,
    required this.allowedRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Distance Indicator
            _buildDistanceIndicator(),

            const SizedBox(height: 16),

            // Progress towards geofence
            if (geofenceResult != null)
              _buildProgressBar(),

            const SizedBox(height: 12),

            // Location details
            _buildLocationDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildDistanceIndicator() {
    if (geofenceResult == null) {
      return Column(
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 8),
          Text(
            'Getting location...',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      );
    }

    final distance = geofenceResult!.distance;
    final isWithin = geofenceResult!.isWithinRadius;

    return Column(
      children: [
        // Distance circle
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isWithin
                ? Colors.green.withAlpha(26)
                : Colors.orange.withAlpha(26),
            border: Border.all(
              color: isWithin ? Colors.green : Colors.orange,
              width: 3,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatDistance(distance),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isWithin ? Colors.green : Colors.orange,
                ),
              ),
              Text(
                distance >= 1000 ? 'km' : 'm',
                style: TextStyle(
                  fontSize: 14,
                  color: isWithin ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isWithin
              ? 'You are within the delivery zone!'
              : 'Move closer to delivery location',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isWithin ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    final distance = geofenceResult!.distance;
    // Cap progress at 200% (2x the allowed radius)
    final progress = (distance / allowedRadius).clamp(0.0, 2.0);
    final progressInverse = (1 - (progress / 2)).clamp(0.0, 1.0);
    final isWithin = geofenceResult!.isWithinRadius;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Distance to destination',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              'Zone: ${allowedRadius.toInt()}m',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progressInverse,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(
              isWithin ? Colors.green : Colors.orange,
            ),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationDetails() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Current location
          Row(
            children: [
              Icon(Icons.my_location, size: 16, color: Colors.blue[700]),
              const SizedBox(width: 8),
              const Text(
                'Your location:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Text(
                currentLocation != null
                    ? '${currentLocation!.latitude.toStringAsFixed(5)}, ${currentLocation!.longitude.toStringAsFixed(5)}'
                    : 'Unknown',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Destination
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.red[700]),
              const SizedBox(width: 8),
              const Text(
                'Destination:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Text(
                '${destination.latitude.toStringAsFixed(5)}, ${destination.longitude.toStringAsFixed(5)}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          // Accuracy indicator
          if (currentLocation?.accuracy != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.gps_fixed,
                  size: 16,
                  color: currentLocation!.isHighAccuracy
                      ? Colors.green[700]
                      : Colors.orange[700],
                ),
                const SizedBox(width: 8),
                const Text(
                  'GPS Accuracy:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Text(
                  '±${currentLocation!.accuracy!.toStringAsFixed(0)}m',
                  style: TextStyle(
                    fontSize: 11,
                    color: currentLocation!.isHighAccuracy
                        ? Colors.green[700]
                        : Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return (meters / 1000).toStringAsFixed(1);
    }
    return meters.toStringAsFixed(0);
  }
}

